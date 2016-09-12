//
//  CachingWebApiRoute.h
//  BRFCore
//
//  Created by Matt on 15/09/15.
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiRoute.h"

/**
 Extension of @c WebApiRoute that adds caching support.
 */
@protocol CachingWebApiRoute <WebApiRoute>

/** A maximum cache time, in seconds. */
@property (nonatomic, readonly) NSTimeInterval cacheTTL;

/** 
 A list of route names that should have any cached data invalidated when this route is requested.
 
 For example a DELETE request for a particular entity might invalidate an associated GET request that listed the available entities of the same kind.
 */
@property (nonatomic, readonly) NSArray<NSString *> *invalidatesCachedRouteNames;

/** 
 Flag to indicate that URL query parameters should @b not be considered when calculating cache keys for routes.
 
 @since 1.1
 */
@property (nonatomic, readonly, getter=isCacheIgnoreQueryParameters) BOOL cacheIgnoreQueryParameters;

@end
