//
//  BRCryptoUtilities.h
//  BRFCore
//
//  Created by Matt on 22/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#ifndef BRCryptoUtilities_h
#define BRCryptoUtilities_h

#include <CoreFoundation/CoreFoundation.h>

/**
 Compute the MD5 hash of a file efficiently.
 
 @param filePath  The path to the file to compute the hash from.
 @param chunkSize The amount of memory to allocate for reading the file in chunks. If @c chunkSize is less than 1 then a default of 4096 will be used.
 
 @return The computed MD5 hash as a hex-encoded string, or @c NULL if any error occurs or the file does not exist.
 */
CFStringRef _Nullable BRCryptoMD5HashCreateWithFilePath(CFStringRef _Nonnull filePath, size_t chunkSize);

/**
 Compute the SHA1 hash of a file efficiently.
 
 @param filePath  The path to the file to compute the hash from.
 @param chunkSize The amount of memory to allocate for reading the file in chunks. If @c chunkSize is less than 1 then a default of 4096 will be used.
 
 @return The computed SHA1 hash as a hex-encoded string, or @c NULL if any error occurs or the file does not exist.
 */
CFStringRef _Nullable BRCryptoSHA1HashCreateWithFilePath(CFStringRef _Nonnull filePath, size_t chunkSize);

#endif /* BRCryptoUtilities_h */
