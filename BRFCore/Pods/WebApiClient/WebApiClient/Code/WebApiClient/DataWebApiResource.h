//
//  DataWebApiResource.h
//  BRFCore
//
//  Created by Matt on 24/08/15.
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiResource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 NSData based implementation of @c WebApiResource.
 */
@interface DataWebApiResource : NSObject <WebApiResource>

/** Get the resource data. */
@property (nonatomic, readonly) NSData *data;

/**
 Initialize from a @c NSData instance. The content length will be derived from the data length.
 
 @param data The data to use.
 @param name The name to associate with the data.
 @param fileName A file name to associate with the data.
 @param MIMEType The MIME type to use. If @c nil then the MIME type will be determined from the path extension of the file name.
 */
- (id)initWithData:(NSData *)data name:(NSString *)name fileName:(NSString *)fileName MIMEType:(nullable NSString *)MIMEType;

@end

NS_ASSUME_NONNULL_END
