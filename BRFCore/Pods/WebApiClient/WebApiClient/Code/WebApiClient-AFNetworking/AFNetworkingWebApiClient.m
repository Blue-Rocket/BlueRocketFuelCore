//
//  AFNetworkingWebApiClient.m
//  WebApiClient
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "AFNetworkingWebApiClient.h"

#import <AFNetworking/AFHTTPSessionManager.h>
#import <AFgzipRequestSerializer/AFgzipRequestSerializer.h>
#import <BRCocoaLumberjack/BRCocoaLumberjack.h>
#import <BREnvironment/BREnvironment.h>
#import "AFNetworkingWebApiClientTask.h"
#import "DataWebApiResource.h"
#import "FileWebApiResource.h"
#import "WebApiClientDigestUtils.h"
#import "WebApiDataMapper.h"
#import "WebApiErrorExtractor.h"
#import "WebApiResource.h"

@implementation AFNetworkingWebApiClient {
	AFHTTPSessionManager *manager;
	id<AFURLResponseSerialization> responseSerializer;
	NSDictionary<NSString *, NSString *> *defaultSerializationAcceptableContentTypes;
	NSLock *lock;
	
	// a mapping of NSURLSessionTask identifiers to associated task objects, to support notifications
	NSMutableDictionary<NSNumber *, AFNetworkingWebApiClientTask *> *tasks;
	
	// to support callbacks on arbitrary queues, our manager must NOT use the main thread
	dispatch_queue_t completionQueue;
}

@synthesize responseSerializer;
@synthesize defaultSerializationAcceptableContentTypes;

- (id)initWithEnvironment:(BREnvironment *)environment {
	if ( (self = [super initWithEnvironment:environment]) ) {
		tasks = [[NSMutableDictionary alloc] initWithCapacity:8];
		lock = [[NSLock alloc] init];
		lock.name = @"AFNetworkingApiClientLock";
		
		// let us accept any and all responses!
		AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
		responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:
							  @[jsonResponseSerializer,
								[AFImageResponseSerializer serializer],
								[AFHTTPResponseSerializer serializer]]];

		// support http://jsonapi.org/ for response Content-Type
		NSMutableSet *jsonContentTypes = [NSMutableSet setWithSet:jsonResponseSerializer.acceptableContentTypes];
		[jsonContentTypes addObject:WebApiClientJSONAPIContentType];
		jsonResponseSerializer.acceptableContentTypes = jsonContentTypes;
		
		[self initializeURLSessionManager];
	}
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(taskDidResume:) name:AFNetworkingTaskDidResumeNotification object:nil];
	[center addObserver:self selector:@selector(taskDidComplete:) name:AFNetworkingTaskDidCompleteNotification object:nil];
	return self;
}

- (void)dealloc {
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:AFNetworkingTaskDidResumeNotification object:nil];
	[center removeObserver:self name:AFNetworkingTaskDidCompleteNotification object:nil];
}

- (void)initializeURLSessionManager {
	if ( manager ) {
		[manager invalidateSessionCancelingTasks:YES];
	}
	NSURLSessionConfiguration *sessConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
	AFHTTPSessionManager *mgr = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseApiURL] sessionConfiguration:sessConfig];
	manager = mgr;
	if ( completionQueue ) {
		completionQueue = nil;
	}
	NSString *callbackQueueName = [@"WebApiClient-" stringByAppendingString:[[self baseApiURL] absoluteString]];
	completionQueue = dispatch_queue_create([callbackQueueName UTF8String], DISPATCH_QUEUE_CONCURRENT);
	manager.completionQueue = completionQueue;
	manager.responseSerializer = self.responseSerializer;
	[manager setTaskDidSendBodyDataBlock:[self taskDidSendBodyDataBlock]];
	[manager setDataTaskDidBecomeDownloadTaskBlock:[self dataTaskDidBecomeDownloadTaskBlock]];
	[manager setDataTaskDidReceiveDataBlock:[self dataTaskDidReceiveDataBlock]];
	[manager setDownloadTaskDidWriteDataBlock:[self downloadTaskDidWriteDataBlock]];
}

- (void)setResponseSerializer:(id<AFURLResponseSerialization>)value {
	if ( responseSerializer == value ) {
		return;
	}
	responseSerializer = value;
	manager.responseSerializer = value;
}

- (void (^)(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend))taskDidSendBodyDataBlock {
	return ^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
		AFNetworkingWebApiClientTask *clientTask = [self clientTaskForTask:task];
		if ( clientTask && !clientTask.uploadProgress ) {
			NSProgress *prog = [NSProgress progressWithTotalUnitCount:totalBytesExpectedToSend];
			prog.completedUnitCount = totalBytesSent;
			clientTask.uploadProgress = prog;
		}
		clientTask.uploadProgress.totalUnitCount = totalBytesExpectedToSend;
		clientTask.uploadProgress.completedUnitCount = totalBytesSent;
		if ( clientTask ) {
			[self handleProgressCallbackForClientTask:clientTask];
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:WebApiClientRequestDidProgressNotification object:clientTask.route
																  userInfo:@{WebApiClientURLRequestNotificationKey : task.originalRequest,
																			 WebApiClientProgressNotificationKey : clientTask.uploadProgress}];
			});
		}
	};
}

- (void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLSessionDownloadTask *downloadTask))dataTaskDidBecomeDownloadTaskBlock {
	return ^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLSessionDownloadTask * _Nonnull downloadTask) {
		AFNetworkingWebApiClientTask *clientTask = [self clientTaskForTask:dataTask];
		AFNetworkingWebApiClientTask *newClientTask = [[AFNetworkingWebApiClientTask alloc] initWithTaskIdentifier:@(downloadTask.taskIdentifier)
																											 route:clientTask.route
																											 queue:clientTask.callbackQueue
																									 progressBlock:clientTask.progressBlock];
		newClientTask.uploadProgress = clientTask.uploadProgress;
		newClientTask.downloadProgress = clientTask.downloadProgress;
		[self setClientTask:newClientTask forTask:downloadTask];
		[self setClientTask:nil forTask:dataTask];
	};
}

- (void)handleProgressCallbackForClientTask:(AFNetworkingWebApiClientTask *)clientTask {
	WebApiClientRequestProgressBlock progressBlock = clientTask.progressBlock;
	if ( progressBlock ) {
		dispatch_async(clientTask.callbackQueue, ^{
			progressBlock(clientTask.route.name, clientTask.uploadProgress, clientTask.downloadProgress);
		});
	}
}

- (void (^)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data))dataTaskDidReceiveDataBlock {
	return ^(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull task, NSData * _Nonnull data) {
		AFNetworkingWebApiClientTask *clientTask = [self clientTaskForTask:task];
		if ( clientTask && !clientTask.downloadProgress ) {
			NSProgress *prog = [NSProgress progressWithTotalUnitCount:task.countOfBytesExpectedToReceive];
			clientTask.downloadProgress = prog;
		}
		clientTask.downloadProgress.totalUnitCount = task.countOfBytesExpectedToReceive;
		clientTask.downloadProgress.completedUnitCount = task.countOfBytesReceived;
		if ( clientTask ) {
			[self handleProgressCallbackForClientTask:clientTask];
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:WebApiClientResponseDidProgressNotification object:clientTask.route
																  userInfo:@{WebApiClientURLRequestNotificationKey : task.originalRequest,
																			 WebApiClientProgressNotificationKey : clientTask.downloadProgress}];
			});
		}
	};
}

- (void (^)(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite))downloadTaskDidWriteDataBlock {
	return ^(NSURLSession * _Nonnull session, NSURLSessionDownloadTask * _Nonnull task, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
		AFNetworkingWebApiClientTask *clientTask = [self clientTaskForTask:task];
		if ( clientTask && !clientTask.downloadProgress ) {
			NSProgress *prog = [NSProgress progressWithTotalUnitCount:task.countOfBytesExpectedToReceive];
			clientTask.downloadProgress = prog;
		}
		clientTask.downloadProgress.totalUnitCount = totalBytesExpectedToWrite;
		clientTask.downloadProgress.completedUnitCount = totalBytesWritten;
		if ( clientTask ) {
			[self handleProgressCallbackForClientTask:clientTask];
			dispatch_async(dispatch_get_main_queue(), ^{
				[[NSNotificationCenter defaultCenter] postNotificationName:WebApiClientResponseDidProgressNotification object:clientTask.route
																  userInfo:@{WebApiClientURLRequestNotificationKey : task.originalRequest,
																			 WebApiClientProgressNotificationKey : clientTask.downloadProgress}];
			});
		}
	};
}

- (AFHTTPRequestSerializer *)requestSerializationForRoute:(id<WebApiRoute>)route URL:(NSURL *)url parameters:(id)parameters data:(id)data error:(NSError * __autoreleasing *)error {
	WebApiSerialization type = route.serialization;
	AFHTTPRequestSerializer *ser;
	switch ( type ) {
		case WebApiSerializationForm:
		case WebApiSerializationNone:
		case WebApiSerializationURL:
			ser = [AFHTTPRequestSerializer serializer];
			break;
		
		case WebApiSerializationJSON:
			ser = [AFJSONRequestSerializer serializer];
			[ser setValue:WebApiClientJSONContentType forHTTPHeaderField:@"Accept"];
			break;
	}
	
	// populate default Accept value, if configured for serialization type
	NSString *acceptableContentType = self.defaultSerializationAcceptableContentTypes[[NSDictionary nameForWebApiSerialization:type]];
	if ( acceptableContentType ) {
		[ser setValue:acceptableContentType forHTTPHeaderField:@"Accept"];
	}
	
	if ( ser && route.gzip ) {
		ser = [AFgzipRequestSerializer serializerWithSerializer:ser];
	}
	
	if ( data != nil && [ser.HTTPMethodsEncodingParametersInURI containsObject:route.method] == NO ) {
		// we have a request body as well as request parameters; so allow the parameters to be encoded in the URL
		NSMutableSet *allowed = [ser.HTTPMethodsEncodingParametersInURI mutableCopy];
		[allowed addObject:route.method];
		ser.HTTPMethodsEncodingParametersInURI = allowed;
	}
	
	return ser;
}

- (NSArray *)activeTaskIdentifiers {
	NSArray *idents = nil;
	[lock lock];
	idents = [tasks allKeys];
	[lock unlock];
	return idents;
}

- (AFNetworkingWebApiClientTask *)clientTaskForActiveTaskIdentifier:(NSUInteger)identifier {
	AFNetworkingWebApiClientTask *clientTask = nil;
	[lock lock];
	clientTask = tasks[@(identifier)];
	[lock unlock];
	return clientTask;
}

- (AFNetworkingWebApiClientTask *)clientTaskForTask:(NSURLSessionTask *)task {
	return [self clientTaskForActiveTaskIdentifier:task.taskIdentifier];
}

- (void)setClientTask:(AFNetworkingWebApiClientTask *)clientTask forTask:(NSURLSessionTask *)task {
	[lock lock];
	NSNumber *key = @(task.taskIdentifier);
	if ( clientTask == nil ) {
		[tasks removeObjectForKey:key];
	} else {
		tasks[key] = clientTask;
	}
	[lock unlock];
}

#pragma mark - Notifications

- (void)taskDidResume:(NSNotification *)note {
	NSURLSessionTask *task = note.object;
	AFNetworkingWebApiClientTask *clientTask = [self clientTaskForTask:task];
	if ( clientTask ) {
		[[NSNotificationCenter defaultCenter] postNotificationName:WebApiClientRequestDidBeginNotification object:clientTask.route
														  userInfo:@{WebApiClientURLRequestNotificationKey : task.originalRequest}];
	}
}

- (void)taskDidComplete:(NSNotification *)notification {
	NSURLSessionTask *task = notification.object;
	AFNetworkingWebApiClientTask *clientTask = [self clientTaskForTask:task];
	if ( !clientTask ) {
		return;
	}
	[self setClientTask:nil forTask:task];
	NSError *error = notification.userInfo[AFNetworkingTaskDidCompleteErrorKey];
	NSNotification *note = nil;
	if ( error ) {
		NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithCapacity:4];
		info[NSUnderlyingErrorKey] = error;
		if ( task.originalRequest ) {
			info[WebApiClientURLRequestNotificationKey] = task.originalRequest;
		}
		if ( task.response ) {
			info[WebApiClientURLResponseNotificationKey] = task.response;
		}
		note = [[NSNotification alloc] initWithName:WebApiClientRequestDidFailNotification object:clientTask.route
										   userInfo:info];
	} else {
		note = [[NSNotification alloc] initWithName:WebApiClientRequestDidSucceedNotification object:clientTask.route
										   userInfo:@{WebApiClientURLRequestNotificationKey : task.originalRequest,
													  WebApiClientURLResponseNotificationKey : task.response}];
	}
	if ( note ) {
		[[NSNotificationCenter defaultCenter] postNotification:note];
	}
}

#pragma mark - Public API

static void * AFNetworkingWebApiClientTaskStateContext = &AFNetworkingWebApiClientTaskStateContext;

- (void)requestAPI:(NSString *)name
 withPathVariables:(nullable id)pathVariables
		parameters:(nullable id)parameters
			  data:(nullable id<WebApiResource>)data
			 queue:(dispatch_queue_t)callbackQueue
		  progress:(nullable WebApiClientRequestProgressBlock)progressCallback
		  finished:(nonnull void (^)(id<WebApiResponse> _Nonnull, NSError * _Nullable))callback {

	void (^doCallback)(id<WebApiResponse>, NSError *) = ^(id<WebApiResponse> response, NSError *error) {
		if ( callback ) {
			dispatch_async(callbackQueue, ^{
				callback(response, error);
			});
		}
	};

	NSError *error = nil;
	id<WebApiRoute> route = [self routeForName:name error:&error];
	if ( !route ) {
		return doCallback(nil, error);
	}
	
	// note we do NOT pass parameters to this method, because we'll let AFNetworking handle that for us later
	NSURL *url = [self URLForRoute:route pathVariables:pathVariables parameters:nil error:&error];
	if ( !url ) {
		return doCallback(nil, error);
	}
	AFHTTPRequestSerializer *ser = [self requestSerializationForRoute:route URL:url parameters:parameters data:data error:&error];
	if ( !ser ) {
		return doCallback(nil, error);
	}
	
	id<WebApiDataMapper> dataMapper = [self dataMapperForRoute:route];

	// kick out to new thread, so mapping, etc don't block UI
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSError *error = nil;
		NSDictionary *reqParameters = nil;
		id<WebApiResource> reqData = data;
		BOOL uploadStream = NO;
		if ( parameters ) {
			if ( dataMapper && ![route.method isEqualToString:@"GET"] && ![route.method isEqualToString:@"HEAD"] ) {
				id encoded = [dataMapper performEncodingWithObject:parameters route:route error:&error];
				if ( !encoded ) {
					return doCallback(nil, error);
				}
				if ( [encoded isKindOfClass:[NSDictionary class]] ) {
					reqParameters = encoded;
				} else if ( [encoded conformsToProtocol:@protocol(WebApiResource)] ) {
					reqData = encoded;
				} else if ( [encoded isKindOfClass:[NSData class]] ) {
					reqData = [[DataWebApiResource alloc] initWithData:encoded name:@"data" fileName:@"data.dat" MIMEType:@"application/octet-stream"];
				}
			} else {
				reqParameters = [self dictionaryForParametersObject:parameters];
			}
		}
		NSMutableURLRequest *req = nil;
		if ( ![route.method isEqualToString:@"GET"] && ![route.method isEqualToString:@"HEAD"] && route.serialization == WebApiSerializationForm ) {
			req = [ser multipartFormRequestWithMethod:route.method URLString:[url absoluteString] parameters:reqParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
				if ( reqData ) {
					[formData appendPartWithInputStream:reqData.inputStream name:reqData.name fileName:reqData.fileName length:reqData.length mimeType:reqData.MIMEType];
				}
			} error:&error];
		} else {
			req = [ser requestWithMethod:route.method URLString:[url absoluteString] parameters:reqParameters error:&error];
			if ( reqData != nil ) {
				uploadStream = YES;
				req.HTTPBodyStream = reqData.inputStream;
				[req setValue:reqData.MIMEType forHTTPHeaderField:@"Content-Type"];
				[req setValue:[NSString stringWithFormat:@"%llu", (unsigned long long)reqData.length] forHTTPHeaderField:@"Content-Length"];
				NSData *digest = reqData.MD5Digest;
				NSString *md5base64 = [digest base64EncodedStringWithOptions:0];
				if ( md5base64.length > 0 ) {
					[req setValue:md5base64 forHTTPHeaderField:@"Content-MD5"];
				}
			}
		}
		
		[self addRequestHeadersToRequest:req forRoute:route];
		[self addAuthorizationHeadersToRequest:req forRoute:route];
		
		void (^responseHandler)(NSURLResponse *, id, NSError *) = ^(NSURLResponse *response, id responseObject, NSError *error) {
			NSMutableDictionary *apiResponse = [[NSMutableDictionary alloc] initWithCapacity:4];
			apiResponse.routeName = name;
			if ( [response isKindOfClass:[NSHTTPURLResponse class]] ) {
				NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
				apiResponse.statusCode = httpResponse.statusCode;
				apiResponse.responseHeaders = httpResponse.allHeaderFields;
			}
			void (^handleResponse)(id, NSError *) = ^(id finalResponseObject, NSError *finalError) {
				apiResponse.responseObject = finalResponseObject;
				if ( self.errorExtractor ) {
					finalError = [self.errorExtractor errorForResponse:apiResponse error:finalError];
				}
				doCallback(apiResponse, finalError);
			};
			
			// with compound serializer, empty response returned as NSData, but we want that as nil
			if ( [responseObject isKindOfClass:[NSData class]]  && [responseObject length] < 1 ) {
				responseObject = nil;
			}
			
			if ( [responseObject isKindOfClass:[NSURL class]] ) {
				NSURL *pointerURL = responseObject;
				if ( [pointerURL isFileURL] ) {
					responseObject = [[FileWebApiResource alloc] initWithURL:pointerURL name:[pointerURL lastPathComponent] MIMEType:response.MIMEType];
				}
				handleResponse(responseObject, error);
			} else if ( dataMapper && responseObject && !error ) {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
					NSError *decodeError = nil;
					id decoded = [dataMapper performMappingWithSourceObject:responseObject route:route error:&decodeError];
					handleResponse(decoded, decodeError);
				});
			} else {
				handleResponse(responseObject, error);
			}
		};
		
		NSProgress *progress = nil;
		NSURLSessionTask *task;
		if ( uploadStream ) {
			task = [manager uploadTaskWithStreamedRequest:req progress:&progress completionHandler:responseHandler];
			progress.totalUnitCount = reqData.length;
			[progress setUserInfoObject:route forKey:NSStringFromProtocol(@protocol(WebApiRoute))];
		} else if ( route.saveAsResource ) {
			task = [manager downloadTaskWithRequest:req progress:&progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
				NSString *fileName = [response suggestedFilename];
				if ( [fileName length] < 1 ) {
					fileName = @"download.dat";
				}
				NSString *tempFilePath = [[self class] temporaryPathWithPrefix:[fileName stringByDeletingPathExtension] suffix:[@"." stringByAppendingString:[fileName pathExtension]]];
				
				// remove our temp file, because AFNetworking will be moving the download file to there
				[[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:nil];
				
				return [NSURL fileURLWithPath:tempFilePath];
			} completionHandler:responseHandler];
		} else {
			task = [manager dataTaskWithRequest:req completionHandler:responseHandler];
		}
		AFNetworkingWebApiClientTask *clientTask = [[AFNetworkingWebApiClientTask alloc] initWithTaskIdentifier:@(task.taskIdentifier)
																										  route:route
																										  queue:callbackQueue
																								  progressBlock:progressCallback];
		[self setClientTask:clientTask forTask:task];
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:WebApiClientRequestWillBeginNotification object:route
															  userInfo:@{WebApiClientURLRequestNotificationKey : req}];
		});
		[task resume];
	});
}

+ (NSString *)temporaryPathWithPrefix:(NSString *)prefix suffix:(NSString *)suffix {
	NSString *nameTemplate = [NSString stringWithFormat:@"%@.XXXXXX%@", prefix, suffix];
	NSString *tempFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:nameTemplate];
	const char *tempFileTemplateCString = [tempFileTemplate fileSystemRepresentation];
	char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
	strcpy(tempFileNameCString, tempFileTemplateCString);
	int fileDescriptor = mkstemps(tempFileNameCString, (int)[suffix length]);
	if ( fileDescriptor == -1 ) {
		log4Error(@"Failed to create temp file %s", tempFileNameCString);
		free(tempFileNameCString);
		return nil;
	}
	
	NSString * result = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:tempFileNameCString
																					length:strlen(tempFileNameCString)];
	free(tempFileNameCString);
	return result;
}

@end
