//
//  WebApiClientCacheEntry.h
//  BRFCore
//
//  Created by Matt on 15/09/15.
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

/**
 A top-level cache entry, which serves as a metadata object placeholder for a second-level cache entry.
 */
@interface WebApiClientCacheEntry : NSObject <NSCoding>

/** The creation time of the entry, relative to @c NSDate's reference date. */
@property (nonatomic, readonly) NSTimeInterval created;

/** The expire time of the entry, relative to @c NSDate's reference date. */
@property (nonatomic, readonly) NSTimeInterval expires;

/**
 Initialize a cache entry with creation and expiry dates.
 
 @param created The creation time, relative to @c NSDate's reference date..
 @param expires The expiry time, relative to @c NSDate's reference date..
 
 @return The initialized object.
 */
- (instancetype)initWithCreationTime:(NSTimeInterval)created expireTime:(NSTimeInterval)expires;

@end
