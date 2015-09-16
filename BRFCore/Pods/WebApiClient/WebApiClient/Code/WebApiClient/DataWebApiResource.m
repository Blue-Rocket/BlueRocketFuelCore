//
//  DataWebApiResource.m
//  BRFCore
//
//  Created by Matt on 24/08/15.
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "DataWebApiResource.h"

#import <MobileCoreServices/MobileCoreServices.h>

@implementation DataWebApiResource {
	NSData *data;
	NSString *name;
	NSString *fileName;
	NSString *MIMEType;
}

@synthesize data;
@synthesize fileName;
@synthesize MIMEType;
@synthesize name;

- (id)initWithData:(NSData *)theData name:(NSString *)theName fileName:(NSString *)theFileName MIMEType:(nullable NSString *)theMIMEType {
	if ( (self = [super init]) ) {
		data = theData;
		name = theName;
		fileName = theFileName;
		MIMEType = theMIMEType;
		[self setupFileDetails];
	}
	return self;
}

- (void)setupFileDetails {
	if ( [MIMEType length] < 1 ) {
		// determine MIME type based on file extension
		NSString *fileExtension = [fileName pathExtension];
		NSString *contentType = nil;
		if ( [fileExtension length] > 0 ) {
			NSString *UTI = (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
			contentType = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)UTI, kUTTagClassMIMEType);
		}
		MIMEType = ([contentType length] > 0 ? contentType : @"application/octet-stream");
	}
}

- (int64_t)length {
	return [data length];
}

- (NSInputStream *)inputStream {
	return [[NSInputStream alloc] initWithData:data];
}


@end
