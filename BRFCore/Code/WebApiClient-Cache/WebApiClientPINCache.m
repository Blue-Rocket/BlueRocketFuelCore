//
//  WebApiClientPINCache.m
//  WebApiClient
//
//  Created by Matt on 11/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiClientPINCache.h"

#import <BRCocoaLumberjack/BRCocoaLumberjack.h>

static id<WebApiClient> SharedGlobalClient;

@implementation WebApiClientPINCache

+ (void)setSharedClient:(id<WebApiClient>)sharedClient {
	SharedGlobalClient = sharedClient;
}

+ (instancetype)sharedClient {
	static WebApiClientPINCache *shared;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[self alloc] init];
	});
	return shared;
}

- (instancetype)init {
	if ( (self = [super init]) ) {
		// TODO: configure cache defaults
	}
	return self;
}

- (void)requestAPI:(NSString * __nonnull)name withPathVariables:(nullable id)pathVariables parameters:(nullable id)parameters
			  data:(nullable id<WebApiResource>)data finished:(void (^ __nonnull)(id<WebApiResponse> __nonnull, NSError * __nullable))callback {
	[self.client requestAPI:name withPathVariables:pathVariables parameters:parameters data:data finished:^(id<WebApiResponse> __nonnull response, NSError * __nullable error) {
		// TODO: inspect route for cache
		
		if ( callback ) {
			callback(response, error);
		}
	}];
}

@end
