//
//  BRSimpleStringLink.h
//  BRFCore
//
//  Created by Matt on 16/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "NSString+BR.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Basic implementation of BRStringLink.
 */
@interface BRSimpleStringLink : NSObject <BRStringLink>

/**
 Initialize with a range and named reference.
 
 @param range     The range.
 @param reference The named reference.
 
 @return The initialized instance.
 */
- (instancetype)initWithRange:(NSRange)range reference:(NSString *)reference NS_DESIGNATED_INITIALIZER;

/**
 Initialize with a range and URL.
 
 @param range     The range.
 @param url       The URL.
 
 @return The initialized instance.
 */
- (instancetype)initWithRange:(NSRange)range URL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
