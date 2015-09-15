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
@property (nonatomic, readwrite) NSTimeInterval cache;

@end
