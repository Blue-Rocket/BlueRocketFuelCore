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

/**
 Convert a hex-encoded string into a data instance.
 
 @param hexString The hex string, e.g. one returned from @c hexStringValue. Whitespace is @b not handled.
 
 @return The data, or @c nil if nothing converted.
 @since 0.14
 */
+ (NSData *)dataWithHexString:(NSString *)hexString;

/**
 Convert a hex-encoded string into a data instance.
 
 @param hexString The hex string, e.g. one returned from @c hexStringValue. Whitespace is striped from the input before converting.
 
 @return The data, or @c nil if nothing converted.
 @since 0.14
 */
+ (NSData *)dataWithHexStringWithWhitespace:(NSString *)hexString;

@end
