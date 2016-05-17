//
//  NSData+BR.m
//  BRFCore
//
//  Created by Matt on 21/10/15.
//  Copyright © 2015 Blue Rocket, Inc. All rights reserved.
//

#import "NSData+BR.h"

#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (BR)

- (NSData *)MD5DigestValue {
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self bytes], (CC_LONG)[self length], result);
	return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

- (NSString *)hexStringValue {
	NSMutableString *stringBuffer = [NSMutableString stringWithCapacity:([self length] * 2)];
	const unsigned char *dataBuffer = [self bytes];
	NSUInteger i, len;
	for ( i = 0, len = [self length]; i < len; ++i ) {
		[stringBuffer appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
	}
	return [stringBuffer copy];
}

@end
