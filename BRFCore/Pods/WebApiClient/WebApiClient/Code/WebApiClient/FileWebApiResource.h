//
//  FileWebApiResource.h
//  BRFCore
//
//  Created by Matt on 24/08/15.
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiResource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 File based implementation of @c WebApiResource.
 */
@interface FileWebApiResource : NSObject <WebApiResource>

/**
 Initialize from a file URL. The content length and file name will be derived from the file itself.
 
 @param fileURL A URL to a file.
 @param name The name to associate with the file.
 @param MIMEType The MIME type to use. If @c nil then the MIME type will be determined from the path extension of the URL.
 */
- (id)initWithURL:(NSURL *)fileURL name:(NSString *)name MIMEType:(nullable NSString *)MIMEType;

@end

NS_ASSUME_NONNULL_END
