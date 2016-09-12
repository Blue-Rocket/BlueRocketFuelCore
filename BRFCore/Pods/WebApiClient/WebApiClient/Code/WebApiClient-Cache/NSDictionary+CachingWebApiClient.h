//
//  NSDictionary+CachingWebApiClient.h
//  BRFCore
//
//  Created by Matt on 15/09/15.
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "CachingWebApiRoute.h"

@interface NSDictionary (CachingWebApiClient) <CachingWebApiRoute>

@end

/**
 Extension to @c NSMutableDictionary to implement writable properties for web API.
 */
@interface NSMutableDictionary (MutableCachingWebApiRoute)

/** A maximum cache time, in seconds. */
@property (nonatomic, readwrite) NSTimeInterval cacheTTL;

/** A list of route names that should have any cached data invalidated when this route is requested. */
@property (nonatomic, readwrite) NSArray<NSString *> *invalidatesCachedRouteNames;

/** Flag to indicate that URL query parameters should @b not be considered when calculating cache keys for routes. */
@property (nonatomic, readwrite, getter=isCacheIgnoreQueryParameters) BOOL cacheIgnoreQueryParameters;

@end
