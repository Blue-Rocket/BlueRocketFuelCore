//
//  NSFileManager_BRTests.m
//  BRFCore
//
//  Created by Matt on 22/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import "BaseTestingSupport.h"

#import "NSFileManager+BR.h"

@interface NSFileManager_BRTests : BaseTestingSupport

@end

@implementation NSFileManager_BRTests

- (void)testTextFileMIMEType {
	NSString *path = [self.bundle pathForResource:@"brcrypto-sample-file.txt" ofType:nil];
	assertThat([NSFileManager MIMETypeForFileAtPath:path], equalTo(@"text/plain"));
}

- (void)testMP4FileMIMEType {
	NSString *path = [self.bundle pathForResource:@"brcrypto-sample-file.mp4" ofType:nil];
	assertThat([NSFileManager MIMETypeForFileAtPath:path], equalTo(@"video/mp4"));
}

- (void)testMD5HashSmallFile {
	NSString *path = [self.bundle pathForResource:@"brcrypto-sample-file.txt" ofType:nil];
	NSString *md5 = [NSFileManager MD5HashForFileAtPath:path];
	assertThat(md5, equalTo(@"746ad2f474700d0d3b5bb7435c0789a3"));
}

- (void)testSHA1HashSmallFile {
	NSString *path = [self.bundle pathForResource:@"brcrypto-sample-file.txt" ofType:nil];
	NSString *sha1 = [NSFileManager SHA1HashForFileAtPath:path];
	assertThat(sha1, equalTo(@"7d879b3e5455d7392e25632abd58ea04bad5863c"));
}

- (void)testCreateTemporaryFile {
	NSString *path = [NSFileManager temporaryPathWithPrefix:@"NSFileManager_BR" suffix:@".txt" directory:NO];
	BOOL isDir = NO;
	assertThatBool([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir], isTrue());
	assertThatBool(isDir, isFalse());
	assertThat([path pathExtension], equalTo(@"txt"));
	assertThatBool([[path lastPathComponent] hasPrefix:@"NSFileManager_BR"], isTrue());
	assertThat([[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil][NSFileSize], equalTo(@0));
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

- (void)testCreateTemporaryDirectory {
	NSString *path = [NSFileManager temporaryPathWithPrefix:@"NSFileManager_BR" suffix:@"foo" directory:YES];
	BOOL isDir = NO;
	assertThatBool([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir], isTrue());
	assertThatBool(isDir, isTrue());
	assertThatBool([[path lastPathComponent] hasPrefix:@"NSFileManager_BR"], isTrue());
	assertThat([[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil], hasCountOf(0));
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

@end
