//
//  FileWebApiResource.h
//  BRFCore
//
//  Created by Matt on 24/08/15.
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiResource.h"

/**
 File based implementation of @c WebApiResource.
 */
@interface FileWebApiResource : NSObject <WebApiResource>

/**
 Initialize from a file URL. The content length and file name will be derived from the file itself.
 
 @param fileURL A URL to a file.
 @param name The name to associate with the file.
 @param 
 */
- (id)initWithURL:(NSURL *)fileURL name:(NSString *)name MIMEType:(NSString *)MIMEType;

@end
