//
//  BRCryptoUtilitiesTests.m
//  BRFCore
//
//  Created by Matt on 22/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BaseTestingSupport.h"

#import "BRCryptoUtilities.h"

@interface BRCryptoUtilitiesTests : BaseTestingSupport

@end

@implementation BRCryptoUtilitiesTests

- (void)testMD5HashSmallFile {
	NSString *path = [self.bundle pathForResource:@"brcrypto-sample-file.txt" ofType:nil];
	NSString *md5 = (NSString *)CFBridgingRelease(BRCryptoMD5HashCreateWithFilePath((__bridge CFStringRef)path, 0));
	assertThat(md5, equalTo(@"746ad2f474700d0d3b5bb7435c0789a3"));
}

- (void)testMD5HashMediumFile {
	NSString *path = [self.bundle pathForResource:@"brcrypto-sample-file.mp4" ofType:nil];
	NSString *md5 = (NSString *)CFBridgingRelease(BRCryptoMD5HashCreateWithFilePath((__bridge CFStringRef)path, 0));
	assertThat(md5, equalTo(@"5ebeeaf19cf738a97f2ff554f556368b"));
}

- (void)testSHA1HashSmallFile {
	NSString *path = [self.bundle pathForResource:@"brcrypto-sample-file.txt" ofType:nil];
	NSString *sha1 = (NSString *)CFBridgingRelease(BRCryptoSHA1HashCreateWithFilePath((__bridge CFStringRef)path, 0));
	assertThat(sha1, equalTo(@"7d879b3e5455d7392e25632abd58ea04bad5863c"));
}

- (void)testSHA1HashMediumFile {
	NSString *path = [self.bundle pathForResource:@"brcrypto-sample-file.mp4" ofType:nil];
	NSString *sha1 = (NSString *)CFBridgingRelease(BRCryptoSHA1HashCreateWithFilePath((__bridge CFStringRef)path, 0));
	assertThat(sha1, equalTo(@"8b59754cbf0b10088ec7d02c5d72582b08ac2c7c"));
}

@end
