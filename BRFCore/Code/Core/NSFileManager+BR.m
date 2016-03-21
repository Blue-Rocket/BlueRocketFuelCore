//
//  NSFileManager+BR.m
//  BRFCore
//
//  Created by Matt on 22/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "NSFileManager+BR.h"

#import <BRCocoaLumberjack/BRCocoaLumberjack.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "BRCryptoUtilities.h"

@implementation NSFileManager (BR)

+ (NSString *)applicationSupportDirectoryPath {
	NSString *applicationName = [[[NSBundle mainBundle] infoDictionary] valueForKey:(NSString *)kCFBundleNameKey];
	return [[NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0]
			stringByAppendingPathComponent:applicationName];
}

+ (NSString *)temporaryPathWithPrefix:(NSString *)prefix suffix:(NSString *)suffix directory:(BOOL)directory {
	NSString *nameTemplate = (directory ? [prefix stringByAppendingString:@".XXXXXX"] : [NSString stringWithFormat:@"%@.XXXXXX%@", prefix, suffix]);
	NSString *tempFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:nameTemplate];
	const char *tempFileTemplateCString = [tempFileTemplate fileSystemRepresentation];
	char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
	strcpy(tempFileNameCString, tempFileTemplateCString);
	if ( directory ) {
		char *result = mkdtemp(tempFileNameCString);
		if ( !result ) {
			DDLogError(@"Failed to create temp directory %s", tempFileNameCString);
			free(tempFileNameCString);
			return nil;
		}
	} else {
		int fileDescriptor = mkstemps(tempFileNameCString, (int)[suffix length]);
		if ( fileDescriptor == -1 ) {
			DDLogError(@"Failed to create temp file %s", tempFileNameCString);
			free(tempFileNameCString);
			return nil;
		}
	}
	
	NSString * result = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:tempFileNameCString length:strlen(tempFileNameCString)];
	free(tempFileNameCString);
	return result;
}

+ (NSString *)MD5HashForFileAtPath:(NSString *)path {
	NSString *result = nil;
	if ( [[NSFileManager defaultManager] isReadableFileAtPath:path] ) {
		result = CFBridgingRelease(BRCryptoMD5HashCreateWithFilePath((__bridge CFStringRef)path, 0));
	}
	return result;
}

+ (NSString *)SHA1HashForFileAtPath:(NSString *)path {
	NSString *result = nil;
	if ( [[NSFileManager defaultManager] isReadableFileAtPath:path] ) {
		result = CFBridgingRelease(BRCryptoSHA1HashCreateWithFilePath((__bridge CFStringRef)path, 0));
	}
	return result;
}

+ (NSString *)MIMETypeForFileAtPath:(NSString *)path {
	// for now, this just uses the file extension... might need something better
	NSString *extension = [path pathExtension];
	CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
	NSString *result = nil;
	if ( type != NULL ) {
		result = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType));
		CFRelease(type);
	}
	return result;
}

@end
