//
//  WebApiClientDigestUtils.h
//  WebApiClient
//
//  Created by Matt on 22/10/15.
//  Copyright © 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#ifndef WebApiClientDigestUtils_h
#define WebApiClientDigestUtils_h

#include <CoreFoundation/CoreFoundation.h>

/**
 Compute the MD5 hash of a string.
 
 @param string       The string to compute the digest for.
 
 @return The computed MD5 digest, or NULL if could not be created.
 */
CFDataRef WebApiClientMD5DigestCreateWithString(CFStringRef string);

/**
 Compute the MD5 hash of in-memory data.
 
 @param data       The data to compute the digest for.
 
 @return The computed MD5 digest.
 */
CFDataRef WebApiClientMD5DigestCreateWithData(CFDataRef data);

/**
 Compute the MD5 hash of a file efficiently.
 
 @param filePath  The path to the file to compute the digest for.
 @param bufferSize The amount of memory to allocate for data processing. If bufferSize < 1 then a default of 4096 will be used.
 
 @return The computed MD5 digest.
 */
CFDataRef WebApiClientMD5DigestCreateWithFilePath(CFStringRef filePath, size_t bufferSize);

/**
 Encode data as a hex string.
 
 @param data The data to encode.
 
 @return The resulting string.
 */
CFStringRef WebApiClientHexEncodedStringCreateWithData(CFDataRef data);

/**
 Deccode a hex string into data.
 
 @param data The string to decode.
 
 @return The resulting data.
 @since 1.1
 */
CFDataRef WebApiClientDataCreateWithHexEncodedString(CFStringRef data);

#endif /* WebApiClientDigestUtils_h */
