//
//  AFNetworkingWebApiClient.m
//  BlueRocketFuelCore
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "AFNetworkingWebApiClient.h"

#import <AFNetworking/AFHTTPSessionManager.h>
#import <BlueRocketFuelCore/NSString+BR.h>
#import "WebApiDataMapper.h"

@implementation AFNetworkingWebApiClient {
	AFHTTPSessionManager *manager;
}

- (id)init {
	if ( (self = [super init]) ) {
		[self initializeURLSessionManager];
	}
	return self;
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
			break;
		case WebApiSerializationNone:
			ser = nil;
			break;
			
	}
	return ser;
}

- (void)requestAPI:(NSString *)name withPathVariables:(id)pathVariables parameters:(id)parameters data:(id)data
		  finished:(void (^)(id<WebApiResponse>, id, NSError *))callback {
	
	void (^doCallback)(id<WebApiResponse>, id, NSError *) = ^(id<WebApiResponse> response, id data, NSError *error) {
		if ( callback ) {
			callback(response, data, error);
		}
	};

	NSError *error = nil;
	id<WebApiRoute> route = [self routeForName:name error:&error];
	if ( !route ) {
		return doCallback(nil, nil, error);
	}
	
	// note we do NOT pass parameters to this method, because we'll let AFNetworking handle that for us later
	NSURL *url = [self URLForRoute:route pathVariables:pathVariables parameters:nil error:&error];
	if ( !url ) {
		return doCallback(nil, nil, error);
	}
	AFHTTPRequestSerializer *ser = [self requestSerializationForRoute:route URL:url parameters:parameters data:data error:&error];
	if ( !ser ) {
		return doCallback(nil, nil, error);
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
				return doCallback(nil, nil, error);
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
		
		// TODO: implicit header setting here, e.g. auth token etc
		
		NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:req completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
			if (error) {
				NSLog(@"Error: %@", error);
			} else {
				NSLog(@"%@ %@", response, responseObject);
			}
		}];
		[dataTask resume];
	});
}

@end
