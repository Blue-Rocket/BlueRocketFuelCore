//
//  BRStringLink.h
//  BRFCore
//
//  Created by Matt on 16/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A discovered link within a string.
 */
@protocol BRStringLink <NSObject>

/** The range for this link. */
@property (nonatomic, readonly) NSRange range;

/** A reference style link value. Either this or @c url will be available. */
@property (nonatomic, readonly, nullable) NSString *reference;

/** A URL style link value. Either this or @c reference will be avaiable. */
@property (nonatomic, readonly, nullable) NSURL *url;

@end
