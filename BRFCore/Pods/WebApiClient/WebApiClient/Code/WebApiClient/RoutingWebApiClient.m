//
//  RoutingWebApiClient.m
//  WebApiClient
//
//  Created by Matt on 27/05/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "RoutingWebApiClient.h"

@implementation RoutingWebApiClient {
	id<WebApiClient> defaultClient;
	NSDictionary<NSString *, id<WebApiClient>> *clients;
}

@synthesize defaultClient;
@synthesize clients;

- (instancetype)init {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
	return [self initWithDefaultClient:nil];
#pragma clang diagnostic pop
}

- (instancetype)initWithDefaultClient:(id<WebApiClient>)client {
	NSParameterAssert(client);
	if ( (self = [super init]) ) {
		defaultClient = client;
	}
	return self;
}

- (id<WebApiClient>)clientForRoute:(NSString *)name {
	id<WebApiClient> result = clients[name];
	if ( result == nil ) {
		result = defaultClient;
	}
	return result;
}

- (id<SupportingWebApiClient>)supportingClientForRoute:(NSString *)name {
	id<WebApiClient> delegate = [self clientForRoute:name];
	return ([delegate conformsToProtocol:@protocol(SupportingWebApiClient)]
			? (id<SupportingWebApiClient>)delegate : nil);
}

#pragma mark - WebApiClient

+ (instancetype)sharedClient {
	static RoutingWebApiClient *shared;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[self alloc] init];
	});
	return shared;
}

- (void)requestAPI:(NSString *)name
 withPathVariables:(nullable id)pathVariables
		parameters:(nullable id)parameters
			  data:(nullable id<WebApiResource>)data
		  finished:(void (^)(id<WebApiResponse> _Nullable response, NSError * _Nullable error))callback {
	id<WebApiClient> delegate = [self clientForRoute:name];
	[delegate requestAPI:name withPathVariables:pathVariables parameters:parameters data:data finished:callback];
}

- (void)requestAPI:(NSString *)name
 withPathVariables:(nullable id)pathVariables
		parameters:(nullable id)parameters
			  data:(nullable id<WebApiResource>)data
			 queue:(dispatch_queue_t)callbackQueue
		  progress:(nullable WebApiClientRequestProgressBlock)progressCallback
		  finished:(void (^)(id<WebApiResponse> _Nullable response, NSError * _Nullable error))callback {
	id<WebApiClient> delegate = [self clientForRoute:name];
	[delegate requestAPI:name withPathVariables:pathVariables parameters:parameters data:data
				   queue:callbackQueue progress:progressCallback finished:callback];
}

- (nullable id<WebApiResponse>)blockingRequestAPI:(NSString *)name
								withPathVariables:(nullable id)pathVariables
									   parameters:(nullable id)parameters
											 data:(nullable id<WebApiResource>)data
									  maximumWait:(NSTimeInterval)maximumWait
											error:(NSError **)error {
	id<WebApiClient> delegate = [self clientForRoute:name];
	return [delegate blockingRequestAPI:name withPathVariables:pathVariables parameters:parameters data:data maximumWait:maximumWait error:error];
}

- (NSArray<NSHTTPCookie *> *)cookiesForAPI:(nullable NSString *)name inCookieStorage:(nullable NSHTTPCookieStorage *)cookieJar {
	id<WebApiClient> delegate = [self clientForRoute:name];
	return [delegate cookiesForAPI:name inCookieStorage:cookieJar];
}

#pragma mark - SupportingWebApiClient

- (nullable id<WebApiRoute>)routeForName:(NSString *)name error:(NSError * __nullable __autoreleasing *)error {
	id<SupportingWebApiClient> delegate = [self supportingClientForRoute:name];
	return [delegate routeForName:name error:error];
}

- (NSURL *)URLForRoute:(id<WebApiRoute>)route
		 pathVariables:(nullable id)pathVariables
			parameters:(nullable id)parameters
				 error:(NSError * __autoreleasing *)error {
	id<SupportingWebApiClient> delegate = [self supportingClientForRoute:route.name];
	return [delegate URLForRoute:route pathVariables:pathVariables parameters:parameters error:error];
}

@end
