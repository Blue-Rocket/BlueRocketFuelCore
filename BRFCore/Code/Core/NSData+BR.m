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

+ (NSData *)dataWithHexString:(NSString *)hexString {
	if ( hexString.length < 2 ) {
		return nil;
	}
	
	const char *bytes = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
	if ( !bytes ) {
		return nil;
	}
	
	char twoChars[3] = {0,0,0};
	NSUInteger resultSize = hexString.length / 2;
	NSUInteger remaining = resultSize;
	Byte *resultBytes = malloc(resultSize);
	if ( !resultBytes ) {
		return nil;
	}
	Byte *outByte = resultBytes;
	while ( remaining-- ) {
		twoChars[0] = *bytes++;
		twoChars[1] = *bytes++;
		*outByte++ = strtol(twoChars, NULL, 16);
	}
	return [NSData dataWithBytesNoCopy:resultBytes length:resultSize freeWhenDone:YES];
}

+ (NSData *)dataWithHexStringWithWhitespace:(NSString *)hexString {
	NSString *sanitized = [hexString stringByReplacingOccurrencesOfString:@"\\s"
															   withString:@""
																  options:NSRegularExpressionSearch
																	range:NSMakeRange(0, hexString.length)];
	return [self dataWithHexString:sanitized];
}

@end
