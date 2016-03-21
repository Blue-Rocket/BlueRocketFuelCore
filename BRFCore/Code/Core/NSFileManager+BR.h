//
//  NSFileManager+BR.h
//  BRFCore
//
//  Created by Matt on 22/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (BR)

/**
 Get a path to a new temporary file or directory based on a name pattern.
 
 @param prefix    A prefix to use in the file name.
 @param suffix    A suffix to use in the file name. A file extension is a common suffix. Ignored if @c directory is @b YES.
 @param directory YES to create a directory path, NO for a file path.
 
 @return The path to the new temporary file or directory, which will be created before returning, or @c nil if any error occurs.
 */
+ (NSString *)temporaryPathWithPrefix:(NSString *)prefix suffix:(NSString *)suffix directory:(BOOL)directory;

/**
 Get a hex-encoded MD5 hash for a file.
 
 @param path The path of the file to get the hash for.
 
 @return The hex-encoded hash result.
 */
+ (nullable NSString *)MD5HashForFileAtPath:(NSString *)path;

/**
 Get a hex-encoded SHA1 hash for a file.
 
 @param path The path of the file to get the hash for.
 
 @return The hex-encoded hash result.
 */
+ (nullable NSString *)SHA1HashForFileAtPath:(NSString *)path;

/**
 Get a MIME type for a file at a given path.
 
 @param path The path to the file to get a MIME type for.
 
 @return The MIME type, or @c nil if cannot be determined.
 */
+ (nullable NSString *)MIMETypeForFileAtPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
