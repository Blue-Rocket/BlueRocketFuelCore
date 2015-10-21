//
//  NSData+BR.h
//  BRFCore
//
//  Created by Matt on 21/10/15.
//  Copyright © 2015 Blue Rocket, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (BR)

/**
 Compute a MD5 digest from the receiver's content.
 
 @return The MD5 digest.
 */
- (NSData *)MD5DigestValue;

/**
 Convert the receiver into a hex-encoded string value.
 
 @return The hex string.
 */
- (NSString *)hexStringValue;

@end
