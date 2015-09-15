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

@end
