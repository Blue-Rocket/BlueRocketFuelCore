//
//  WebApiResource.h
//  BRFCore
//
//  Created by Matt on 24/08/15.
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 API for a resource, such as a file or stream, to support web multipart requests.
 */
@protocol WebApiResource <NSObject>

/** An input stream to the resource data. */
@property (nonatomic, readonly, nullable) NSInputStream *inputStream;

/** The length of the input stream data, in bytes. */
@property (nonatomic, readonly) int64_t length;

/** A name to associate with the resource, which may be different from the resource's @c fileName. */
@property (nonatomic, readonly) NSString *name;

/** A file name to associate with the resource. */
@property (nonatomic, readonly) NSString *fileName;

/** The MIME type of the resource. */
@property (nonatomic, readonly) NSString *MIMEType;

/** Get the hex-encoded MD5 digest of the data stream, or @c nil if not known. */
@property (nonatomic, readonly, nullable) NSString *MD5;

/** 
 Get a MD5 digest of the data stream, or @c nil if not known.
 
 @since 1.1
 */
@property (nonatomic, readonly, nullable) NSData *MD5Digest;

/**
 Get a URL value for this resource.
 
 @return A URL value, or @c nil if not appropriate.
 */
- (nullable NSURL *)URLValue;

@end

NS_ASSUME_NONNULL_END
