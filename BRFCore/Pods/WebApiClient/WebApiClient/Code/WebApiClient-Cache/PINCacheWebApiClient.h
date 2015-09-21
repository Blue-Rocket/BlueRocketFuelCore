//
//  PINCacheWebApiClient.h
//  WebApiClient-Cache
//
//  Created by Matt on 11/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiClient.h"

@class PINCache;
@protocol SupportingWebApiClient;

NS_ASSUME_NONNULL_BEGIN

/**
 A @c WebApiClient that delegates all calls to another @c WebApiClient, caching the results based
 on the @c WebApiRoute @c cache property.
 
 @b Note that HTTP response data is cached based on URLs only, including query parameters.
 
 @b Note that all response objects must conform to @c NSCoding to work with @c PINCache. If any
 mapping is configured for the route, the _mapped_ response object is cached and as such _that_
 object must conform to @c NSCoding.
 */
@interface PINCacheWebApiClient : NSObject <WebApiClient>

/** The @c SupportingWebApiClient implementation to delegate all calls to. */
@property (nonatomic, strong) id<SupportingWebApiClient> client;

/**
 Set the shared client delegate to use.
 
 @param sharedClient The shared global client.
 */
+ (void)setSharedClient:(id<SupportingWebApiClient>)sharedClient;

/**
 Initialize with custom entry and data caches.
 
 @param entryCache The cache to use for @c WebApiClientCacheEntry objects, used to track expiry dates.
 @param dataCache  The cache to use for the actual data.
 
 @return The initialized client.
 */
- (instancetype)initWithEntryCache:(PINCache *)entryCache dataCache:(PINCache *)dataCache;

@end

NS_ASSUME_NONNULL_END
