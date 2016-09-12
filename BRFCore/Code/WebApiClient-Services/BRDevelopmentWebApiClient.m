//
//  BRDevelopmentWebApiClient.m
//  BRFCore
//
//  Created by Matt on 12/09/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import "BRDevelopmentWebApiClient.h"

#import <BREnvironment/BREnvironment.h>
#import <WebApiClient/WebApiClient-Core.h>

@implementation BRDevelopmentWebApiClient

- (NSString *)resourceDirectoryPath {
	return [[[NSBundle bundleForClass:[BRDevelopmentWebApiClient class]] bundlePath] stringByAppendingPathComponent:@"MockData"];
}

- (NSString *)randomResourceWithPrefix:(NSString *)baseName extension:(NSString *)extension {
	// look for MockData/X resources where Xand return a random matching one
	NSString *dir = [self resourceDirectoryPath];
	NSArray<NSString *> *possible = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:dir error:nil] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
		NSString *name = evaluatedObject;
		return ([name hasPrefix:baseName] && [[name pathExtension] isEqualToString:extension] );
	}]];
	NSUInteger idx = arc4random_uniform((int32_t)possible.count);
	if ( idx < possible.count ) {
		return [possible[idx] stringByDeletingPathExtension];
	}
	return baseName;
}

- (id)responseObjectForRoute:(id<WebApiRoute>)route pathVariables:(id)pathVariables parameters:(id)parameters data:(id<WebApiResource>)data {
	// extending classes can do something more interesting here
	return nil;
}

- (NSString *)resourcePathForRoute:(id<WebApiRoute>)route pathVariables:(id)pathVariables parameters:(id)parameters data:(id<WebApiResource>)data {
	// extending classes can do something more interesting here
	NSString *path = [[self resourceDirectoryPath] stringByAppendingPathComponent:[route.name stringByAppendingPathExtension:@"json"]];
	if ( [[NSFileManager defaultManager] fileExistsAtPath:path] ) {
		return path;
	}
	return nil;
}

- (NSNumber *)throttleRateForRoute:(id<WebApiRoute>)route pathVariables:(id)pathVariables parameters:(id)parameters data:(id<WebApiResource>)data {
	// extending classes can do something more interesting here
	return [[BREnvironment sharedEnvironment] numberForKey:@"Mock-Client-Throttle"];
}

- (void)requestAPI:(NSString *)name withPathVariables:(id)pathVariables parameters:(id)parameters data:(id<WebApiResource>)data
			 queue:(dispatch_queue_t)callbackQueue
		  progress:(nullable WebApiClientRequestProgressBlock)progressCallback
		  finished:(nonnull void (^)(id<WebApiResponse> _Nonnull, NSError * _Nullable))callback {	
	id<WebApiRoute> route = [self routeForName:name error:nil];
	__block id responseObject;
	NSError *error = nil;
	NSString *responseObjectResource = nil;
	NSNumber *throttle = [self throttleRateForRoute:route pathVariables:pathVariables parameters:parameters data:data];
	
	responseObject = [self responseObjectForRoute:route pathVariables:pathVariables parameters:parameters data:data];
	if ( responseObject == nil ) {
		responseObjectResource = [self resourcePathForRoute:route pathVariables:pathVariables parameters:parameters data:data];
	}
	
	void (^handleCallback)(void) = ^{
		if ( !callback ) {
			return;
		}
		dispatch_async(callbackQueue ? callbackQueue : dispatch_get_main_queue(), ^{
			NSMutableDictionary *response = [[NSMutableDictionary alloc] initWithCapacity:2];
			response.routeName = name;
			response.responseObject = responseObject;
			response.statusCode = (error ? 500 : (responseObject || data) ? 200 : 404);
			callback(response, error);
		});
	};
	
	if ( responseObjectResource || data ) {
		if ( route.saveAsResource ) {
			// copy out of app bundle into temp dir, so receivers of file can just move it
			NSString *copyPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[responseObjectResource lastPathComponent]];
			if ( throttle ) {
				dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
					int64_t responseLength = [[FileWebApiResource alloc] initWithURL:[NSURL fileURLWithPath:responseObjectResource] name:[responseObjectResource lastPathComponent] MIMEType:nil].length;
					[self throttleRoute:name length:responseLength rate:[throttle intValue] queue:callbackQueue progress:progressCallback up:NO];
					
					[[NSFileManager defaultManager] copyItemAtPath:responseObjectResource toPath:copyPath error:nil];
					responseObject = [[FileWebApiResource alloc] initWithURL:[NSURL fileURLWithPath:copyPath] name:[responseObjectResource lastPathComponent] MIMEType:nil];
					handleCallback();
				});
			} else {
				[[NSFileManager defaultManager] copyItemAtPath:responseObjectResource toPath:copyPath error:nil];
				responseObject = [[FileWebApiResource alloc] initWithURL:[NSURL fileURLWithPath:copyPath] name:[responseObjectResource lastPathComponent] MIMEType:nil];
			}
		} else if ( data != nil ) {
			// throttle the upload; we assume there is no response body here
			if ( throttle ) {
				dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
					int64_t requestLength = data.length;
					[self throttleRoute:name length:requestLength rate:[throttle intValue] queue:callbackQueue progress:progressCallback up:YES];
					handleCallback();
				});
			}
		} else {
			int64_t responseLength = 0;
			if ( [[responseObjectResource pathExtension] isEqualToString:@"json"] ) {
				responseLength = [[[NSFileManager defaultManager] attributesOfItemAtPath:responseObjectResource error:nil][NSFileSize] longLongValue];
				NSInputStream *input = [NSInputStream inputStreamWithFileAtPath:responseObjectResource];
				[input open];
				responseObject = [NSJSONSerialization JSONObjectWithStream:input options:0 error:&error];
				[input close];
			} else {
				responseObject = [NSData dataWithContentsOfFile:responseObjectResource];
				responseLength = ((NSData *)responseObject).length;
			}
			void (^handleResponse)(void) = ^{
				id<WebApiDataMapper> mapper = [super dataMapperForRoute:route];
				if ( mapper ) {
					NSError *mapperError = nil;
					responseObject = [mapper performMappingWithSourceObject:responseObject route:route error:&mapperError];
				}
			};
			if ( throttle ) {
				dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
					[self throttleRoute:name length:responseLength rate:[throttle intValue] queue:callbackQueue progress:progressCallback up:NO];
					handleResponse();
					handleCallback();
				});
			} else {
				handleResponse();
			}
		}
	}
	if ( !throttle ) {
		handleCallback();
	}
}

- (void)throttleRoute:(NSString *)routeName length:(const int64_t)len rate:(int)rate queue:(dispatch_queue_t)callbackQueue progress:(nullable WebApiClientRequestProgressBlock)progressCallback up:(BOOL)upload {
	int64_t sent = 0;
	NSTimeInterval dt = 0;
	NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
	NSProgress *progress = [NSProgress discreteProgressWithTotalUnitCount:len];
	NSProgress *uploadProgress = (upload ? progress : nil);
	NSProgress *downloadProgress = (upload == NO ? progress : nil);
	progress.kind = NSProgressKindFile;
	[progress setUserInfoObject:NSProgressFileOperationKindDownloading forKey:NSProgressFileOperationKindKey];
	[progress setUserInfoObject:@1 forKey:NSProgressFileTotalCountKey];
	[progress setUserInfoObject:@0 forKey:NSProgressFileCompletedCountKey];
	
	// force a small initial delay always
	[NSThread sleepForTimeInterval:0.2];
	
	while ( sent < len ) {
		NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
		dt = (now - start);
		int64_t chunkLength = (dt * rate);
		sent += chunkLength;
		if ( sent > len ) {
			sent = len;
		}
		if ( sent == len ) {
			[progress setUserInfoObject:@1 forKey:NSProgressFileCompletedCountKey];
		}
		progress.completedUnitCount = sent;
		if ( progressCallback ) {
			dispatch_async(callbackQueue ? callbackQueue : dispatch_get_main_queue(), ^{
				progressCallback(routeName, uploadProgress, downloadProgress);
			});
		}
		start = [NSDate timeIntervalSinceReferenceDate];
		[NSThread sleepForTimeInterval:0.2];
	}
}

@end
