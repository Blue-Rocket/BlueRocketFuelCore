//
//  PINCacheWebApiClient.h
//  WebApiClient-Cache
//
//  Created by Matt on 11/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "SupportingWebApiClient.h"

#import "CachingWebApiClient.h"

@class PINCache;
@protocol SupportingWebApiClient;

NS_ASSUME_NONNULL_BEGIN

/**
 A @c WebApiClient that delegates all calls to another @c WebApiClient, caching the results based
 on the @c WebApiRoute @c cache property.
 
 @b Note that HTTP response data is cached based on URLs. Cache keys include URL query parameters,
 unless the route defines the cacheIgnoreQueryParameters key with a truthy value.
 
 @b Note that all response objects must conform to @c NSCoding to work with @c PINCache. If any
 mapping is configured for the route, the _mapped_ response object is cached and as such _that_
 object must conform to @c NSCoding.
 */
@interface PINCacheWebApiClient : NSObject <CachingWebApiClient, SupportingWebApiClient>

/** The @c SupportingWebApiClient implementation to delegate all calls to. */
@property (nonatomic, strong) id<SupportingWebApiClient> client;

/** The cache used for @c WebApiClientCacheEntry objects. */
@property (nonatomic, readonly) PINCache *entryCache;

/** The cache used for actual response data. */
@property (nonatomic, readonly) PINCache *dataCache;

/**
 An optional discriminator to add to all generated cache keys. This can be changed at runtime to support
 different cache @em groups. For example in a multi-user app groups could be defined as the user unique
 IDs so that each user has their own cache, and when switching between users this propery is updated to
 the active user's ID.
 
 @since 1.1.0
 */
@property (nonatomic, strong, nullable) NSString *keyDiscriminator;

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
