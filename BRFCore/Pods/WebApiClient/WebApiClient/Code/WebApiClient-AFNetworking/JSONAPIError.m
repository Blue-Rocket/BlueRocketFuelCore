//
//  JSONAPIError.m
//  WebApiClient
//
//  Created by Matt on 4/25/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "JSONAPIError.h"

@implementation JSONAPIError {
	NSString *uniqueId;
	NSString *code;
	NSString *title;
	NSString *detail;
	NSString *status;
}

@synthesize id = uniqueId;
@synthesize code;
@synthesize title;
@synthesize detail;
@synthesize status;

- (instancetype)initWithResponseObject:(NSDictionary<NSString *, id> *)responseObject {
	if ( (self = [super init]) ) {
		uniqueId = [JSONAPIError nonEmptyStringValue:responseObject[@"id"]];
		code = [JSONAPIError nonEmptyStringValue:responseObject[@"code"]];
		title = [JSONAPIError nonEmptyStringValue:responseObject[@"title"]];
		detail = [JSONAPIError nonEmptyStringValue:responseObject[@"detail"]];
		status = [JSONAPIError nonEmptyStringValue:responseObject[@"status"]];
	}
	return self;
}

+ (instancetype)JSONAPIErrorWithResponseObject:(NSDictionary<NSString *, id> *)responseObject {
	return [[JSONAPIError alloc] initWithResponseObject:responseObject];
}

+ (NSString *)nonEmptyStringValue:(id)val {
	NSString *result = nil;
	if ( [val isKindOfClass:[NSString class]] ) {
		result = val;
	} else if ( [val respondsToSelector:@selector(stringValue)] ) {
		result = [val stringValue];
	} else if ( [val respondsToSelector:@selector(description)] ) {
		result = [val description];
	}
	return (result.length > 0 ? result : nil);
}

@end
