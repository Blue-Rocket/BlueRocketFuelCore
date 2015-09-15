//
//  WebApiClientPINCache.h
//  WebApiClient
//
//  Created by Matt on 11/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BRUserService.h"

#import "WebApiClient.h"

/**
 A @c WebApiClient that delegates all calls to another @c WebApiClient, caching the results based
 on the @c WebApiRoute @c cache property.
 */
@interface WebApiClientPINCache : NSObject <WebApiClient>

/** The @c WebApiClient implementation to delegate all calls to. If not configured the global shared client will be used. */
@property (nonatomic, strong) id<WebApiClient> client;

/**
 Set the shared client delegate to use.
 
 @param sharedClient The shared global client.
 */
+ (void)setSharedClient:(id<WebApiClient>)sharedClient;

@end
