//
//  BRSimpleStringLink.m
//  BRFCore
//
//  Created by Matt on 16/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import "BRSimpleStringLink.h"

@implementation BRSimpleStringLink {
	NSRange range;
	NSString *reference;
	NSURL *url;
}

@synthesize range, reference, url;

- (instancetype)init {
	return [self initWithRange:NSMakeRange(0, 0) reference:@""];
}

- (instancetype)initWithRange:(NSRange)theRange reference:(NSString *)theReference {
	if ( (self = [super init]) ) {
		range = theRange;
		reference = theReference;
	}
	return self;
}

- (instancetype)initWithRange:(NSRange)theRange URL:(NSURL *)theUrl {
	if ( (self = [super init]) ) {
		range = theRange;
		url = theUrl;
	}
	return self;
}

@end
