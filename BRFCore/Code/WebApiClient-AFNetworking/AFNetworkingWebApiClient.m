//
//  AFNetworkingWebApiClient.m
//  BlueRocketFuelCore
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "AFNetworkingWebApiClient.h"

#import <AFNetworking/AFHTTPSessionManager.h>
#import <BRCocoaLumberjack/BRCocoaLumberjack.h>
#import <BREnvironment/BREnvironment.h>
#import "NSString+BR.h"
#import "WebApiDataMapper.h"

@implementation AFNetworkingWebApiClient {
	AFHTTPSessionManager *manager;
	NSLock *lock;
	// a mapping of NSURLSessionTask identifiers to associated WebApiRoute objects, to support notifications
	NSMutableDictionary *tasksToRoutes;
}

- (id)initWithEnvironment:(BREnvironment *)environment {
	if ( (self = [super initWithEnvironment:environment]) ) {
		tasksToRoutes = [[NSMutableDictionary alloc] initWithCapacity:8];
		lock = [[NSLock alloc] init];
		lock.name = @"AFNetworkingApiClientLock";
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
}

- (AFHTTPRequestSerializer *)requestSerializationForRoute:(id<WebApiRoute>)route URL:(NSURL *)url parameters:(id)parameters data:(id)data error:(NSError * __autoreleasing *)error {
	WebApiSerialization type = route.serialization;
	AFHTTPRequestSerializer *ser;
	switch ( type ) {
		case WebApiSerializationForm:
		case WebApiSerializationURL:
			ser = [AFHTTPRequestSerializer serializer];
			break;
		case WebApiSerializationJSON:
			ser = [AFJSONRequestSerializer serializer];
			[ser setValue:@"application/json" forHTTPHeaderField:@"Accept"];
			break;
		case WebApiSerializationNone:
			ser = nil;
			break;
			
	}
	return ser;
}

- (NSArray *)activeTaskIdentifiers {
	NSArray *idents = nil;
	[lock lock];
	idents = [tasksToRoutes allKeys];
	[lock unlock];
	return idents;
}

- (id<WebApiRoute>)routeForActiveTaskIdentifier:(NSUInteger)identifier {
	id<WebApiRoute> route = nil;
	[lock lock];
	route = tasksToRoutes[@(identifier)];
	[lock unlock];
	return route;
}

- (id<WebApiRoute>)routeForTask:(NSURLSessionTask *)task {
	return [self routeForActiveTaskIdentifier:task.taskIdentifier];
}

- (void)setRoute:(id<WebApiRoute>)route forTask:(NSURLSessionTask *)task {
	[lock lock];
	if ( route == nil ) {
		[tasksToRoutes removeObjectForKey:@(task.taskIdentifier)];
	} else {
		tasksToRoutes[@(task.taskIdentifier)] = route;
	}
	[lock unlock];
}

#pragma mark - Notifications

- (void)taskDidResume:(NSNotification *)note {
	NSURLSessionTask *task = note.object;
	id<WebApiRoute> route = [self routeForTask:task];
	if ( route ) {
		[[NSNotificationCenter defaultCenter] postNotificationName:WebApiClientRequestDidBeginNotification object:route
														  userInfo:@{WebApiClientURLRequestNotificationKey : task.originalRequest}];
	}
}

- (void)taskDidComplete:(NSNotification *)notification {
	NSURLSessionTask *task = notification.object;
	id<WebApiRoute> route = [self routeForTask:task];
	if ( !route ) {
		return;
	}
	[self setRoute:nil forTask:task];
	NSError *error = notification.userInfo[AFNetworkingTaskDidCompleteErrorKey];
	NSNotification *note = nil;
	if ( error ) {
		note = [[NSNotification alloc] initWithName:WebApiClientRequestDidFailNotification object:route
										   userInfo:@{NSUnderlyingErrorKey : error,
													  WebApiClientURLRequestNotificationKey : task.originalRequest,
													  WebApiClientURLResponseNotificationKey : task.response}];
	} else {
		note = [[NSNotification alloc] initWithName:WebApiClientRequestDidSucceedNotification object:route
										   userInfo:@{WebApiClientURLRequestNotificationKey : task.originalRequest,
													  WebApiClientURLResponseNotificationKey : task.response}];
	}
	if ( note ) {
		[[NSNotificationCenter defaultCenter] postNotification:note];
	}
}

#pragma mark - Public API

static void * AFNetworkingWebApiClientTaskStateContext = &AFNetworkingWebApiClientTaskStateContext;

- (void)requestAPI:(NSString *)name withPathVariables:(id)pathVariables parameters:(id)parameters data:(id)data
		  finished:(void (^)(id<WebApiResponse>, NSError *))callback {
	
	void (^doCallback)(id<WebApiResponse>, NSError *) = ^(id<WebApiResponse> response, NSError *error) {
		if ( callback ) {
			callback(response, error);
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
		id reqData = data;
		if ( dataMapper ) {
			id encoded = [dataMapper performEncodingWithObject:parameters route:route error:&error];
			if ( !encoded ) {
				return doCallback(nil, error);
			}
			if ( [encoded isKindOfClass:[NSDictionary class]] ) {
				reqParameters = encoded;
			} else {
				reqData = encoded;
			}
		} else {
			reqParameters = [self dictionaryForParametersObject:parameters];
		}
		NSMutableURLRequest *req = nil;
		if ( route.serialization != WebApiSerializationNone && data != nil ) {
			req = [ser multipartFormRequestWithMethod:route.method URLString:[url absoluteString] parameters:reqParameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
				// TODO
			} error:&error];
		} else {
			req = [ser requestWithMethod:route.method URLString:[url absoluteString] parameters:reqParameters error:&error];
		}
		
		[self addAuthorizationHeadersToRequest:req forRoute:route];
		
		__block NSURLSessionDataTask *task = [manager dataTaskWithRequest:req completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
			NSMutableDictionary *apiResponse = [[NSMutableDictionary alloc] initWithCapacity:4];
			if ( [response isKindOfClass:[NSHTTPURLResponse class]] ) {
				NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
				apiResponse.statusCode = httpResponse.statusCode;
				apiResponse.responseHeaders = httpResponse.allHeaderFields;
			}
			void (^handleResponse)(id, NSError *) = ^(id finalResponseObject, NSError *finalError) {
				apiResponse.responseObject = finalResponseObject;
				doCallback(apiResponse, finalError);
			};
			if ( dataMapper && !error ) {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
					NSError *decodeError = nil;
					id decoded = [dataMapper performMappingWithSourceObject:responseObject route:route error:&decodeError];
					dispatch_async(dispatch_get_main_queue(), ^{
						handleResponse(decoded, decodeError);
					});
				});
			} else {
				handleResponse(responseObject, error);
			}
		}];
		[self setRoute:route forTask:task];
		dispatch_async(dispatch_get_main_queue(), ^{
			[[NSNotificationCenter defaultCenter] postNotificationName:WebApiClientRequestWillBeginNotification object:route
															  userInfo:@{WebApiClientURLRequestNotificationKey : req}];
		});
		[task resume];
	});
}

@end
