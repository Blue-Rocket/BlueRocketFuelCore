//
//  FileWebApiResource.m
//  BRFCore
//
//  Created by Matt on 24/08/15.
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "FileWebApiResource.h"

#import <MobileCoreServices/MobileCoreServices.h>

@implementation FileWebApiResource {
	NSURL *url;
	int64_t length;
	NSString *name;
	NSString *fileName;
	NSString *MIMEType;
}

@synthesize fileName;
@synthesize length;
@synthesize MIMEType;
@synthesize name;

- (id)initWithURL:(NSURL *)fileURL name:(NSString *)aName MIMEType:(NSString *)theMIMEType {
	if ( (self = [super init]) ) {
		url = fileURL;
		name = aName;
		MIMEType = theMIMEType;
		[self setupFileDetails];
	}
	return self;
}

- (void)setupFileDetails {
	fileName = [url lastPathComponent];
	if ( [MIMEType length] < 1 ) {
		// determine MIME type based on file extension
		NSString *fileExtension = [url pathExtension];
		NSString *contentType = nil;
		if ( [fileExtension length] > 0 ) {
			NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
			contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
		}
		MIMEType = ([contentType length] > 0 ? contentType : @"application/octet-stream");
	}
	NSFileManager *fm = [NSFileManager new];
	NSDictionary *attr = [fm attributesOfItemAtPath:[url path] error:nil];
	length = [attr[NSFileSize] longLongValue];
}

- (NSInputStream *)inputStream {
	return [[NSInputStream alloc] initWithURL:url];
}

@end
