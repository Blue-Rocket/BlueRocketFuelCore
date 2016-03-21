//
//  BRCryptoUtilities.c
//  BRFCore
//
//  Created by Matt on 22/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#include "BRCryptoUtilities.h"

#include <stdio.h>
#include <stdint.h>
#include <CoreFoundation/CoreFoundation.h>
#include <CommonCrypto/CommonDigest.h>

#define FileHashDefaultChunkSizeForReadingData 4096

CFStringRef _Nullable BRCryptoCreateHexStringForHash(const unsigned char * _Nonnull digest, size_t len) {
	CFStringRef result = NULL;
	char hexEncoding[2 * len + 1];
	for ( size_t i = 0; i < len; ++i ) {
		snprintf(hexEncoding + (2 * i), 3, "%02x", (int)(digest[i]));
	}
	result = CFStringCreateWithCString(kCFAllocatorDefault, (const char *)hexEncoding, kCFStringEncodingUTF8);
	return result;
}

CFStringRef _Nullable BRCryptoMD5HashCreateWithFilePath(CFStringRef _Nonnull filePath, size_t chunkSize) {
	CFStringRef result = NULL;
	CFReadStreamRef readStream = NULL;
	CFURLRef fileURL = NULL;
	if ( filePath ) {
		fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, (Boolean)false);
	}
	if ( fileURL ) {
		readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, fileURL);
		if ( readStream ) {
			Boolean didSucceed = CFReadStreamOpen(readStream);
			if ( didSucceed ) {
				CC_MD5_CTX hashObject;
				CC_MD5_Init(&hashObject);
				
				// Make sure chunkSizeForReadingData is valid
				if ( chunkSize < 1 ) {
					chunkSize = FileHashDefaultChunkSizeForReadingData;
				}
				
				// Feed the data to the hash object
				bool hasMoreData = true;
				uint8_t buffer[chunkSize];
				while ( hasMoreData ) {
					CFIndex readBytesCount = CFReadStreamRead(readStream, (UInt8 *)buffer, (CFIndex)sizeof(buffer));
					if ( readBytesCount == -1 ) break;
					if ( readBytesCount == 0 ) {
						hasMoreData = false;
						continue;
					}
					CC_MD5_Update(&hashObject, (const void *)buffer, (CC_LONG)readBytesCount);
				}
				
				// Check if the read operation succeeded
				didSucceed = !hasMoreData;
				
				// Compute the hash digest
				unsigned char digest[CC_MD5_DIGEST_LENGTH];
				CC_MD5_Final(digest, &hashObject);
				
				// Abort if the read operation failed
				if ( didSucceed ) {
					result = BRCryptoCreateHexStringForHash(digest, CC_MD5_DIGEST_LENGTH);
				}
			}
		}
	}
	
	if ( readStream ) {
		CFReadStreamClose(readStream);
		CFRelease(readStream);
	}
	if ( fileURL ) {
		CFRelease(fileURL);
	}
	return result;
}

CFStringRef _Nullable BRCryptoSHA1HashCreateWithFilePath(CFStringRef _Nonnull filePath, size_t chunkSize) {
	CFStringRef result = NULL;
	CFReadStreamRef readStream = NULL;
	CFURLRef fileURL = NULL;
	if ( filePath ) {
		fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)filePath, kCFURLPOSIXPathStyle, (Boolean)false);
	}
	if ( fileURL ) {
		readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault, fileURL);
		if ( readStream ) {
			Boolean didSucceed = CFReadStreamOpen(readStream);
			if ( didSucceed ) {
				CC_SHA1_CTX hashObject;
				CC_SHA1_Init(&hashObject);
				
				// Make sure chunkSizeForReadingData is valid
				if ( chunkSize < 1 ) {
					chunkSize = FileHashDefaultChunkSizeForReadingData;
				}
				
				// Feed the data to the hash object
				bool hasMoreData = true;
				uint8_t buffer[chunkSize];
				while ( hasMoreData ) {
					CFIndex readBytesCount = CFReadStreamRead(readStream, (UInt8 *)buffer, (CFIndex)sizeof(buffer));
					if ( readBytesCount == -1 ) break;
					if ( readBytesCount == 0 ) {
						hasMoreData = false;
						continue;
					}
					CC_SHA1_Update(&hashObject, (const void *)buffer, (CC_LONG)readBytesCount);
				}
				
				// Check if the read operation succeeded
				didSucceed = !hasMoreData;
				
				// Compute the hash digest
				unsigned char digest[CC_SHA1_DIGEST_LENGTH];
				CC_SHA1_Final(digest, &hashObject);
				
				// Abort if the read operation failed
				if ( didSucceed ) {
					result = BRCryptoCreateHexStringForHash(digest, CC_SHA1_DIGEST_LENGTH);
				}
			}
		}
	}
	
	if ( readStream ) {
		CFReadStreamClose(readStream);
		CFRelease(readStream);
	}
	if ( fileURL ) {
		CFRelease(fileURL);
	}
	return result;
}
