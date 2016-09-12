//
//  JSONAPIErrorExtractor.m
//  WebApiClient
//
//  Created by Matt on 4/25/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "JSONAPIErrorExtractor.h"

#import "JSONAPIError.h"
#import "WebApiResponse.h"

NSString * const JSONAPIErrorExtractorDefaultErrorDomain = @"JSONAPIError";

@implementation JSONAPIErrorExtractor {
	NSString *errorDomain;
}

@synthesize errorDomain;

- (instancetype)init {
	if ( (self = [super init]) ) {
		errorDomain = JSONAPIErrorExtractorDefaultErrorDomain;
	}
	return self;
}

- (nullable NSError *)errorForResponse:(id<WebApiResponse>)response error:(nullable NSError *)error {
	NSError *result = error;
	if ( response.statusCode < 200 || response.statusCode > 299 ) {
		NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:4];
		[userInfo addEntriesFromDictionary:error.userInfo];
		
		// extract server-assigned code and localized message, if available
		id responseObj = response.responseObject;
		NSArray<JSONAPIError *> *errors = nil;
		if ( [responseObj isKindOfClass:[NSDictionary class]] ) {
			errors = [self extractErrors:responseObj];
		}
		NSUInteger code = 0;
		NSString *message;
		if ( errors.count > 1 ) {
			// we've got an array of error objects; use the first code as the primary code, and bundle all detail messages together.
			NSMutableArray<NSString *> *messages = [[NSMutableArray alloc] initWithCapacity:errors.count];
			for ( JSONAPIError *error in errors ) {
				if ( !code ) {
					code = [error.code integerValue];
				}
				if ( error.detail.length > 0 ) {
					[messages addObject:error.detail];
				}
			}
			message = [messages componentsJoinedByString:@" "];
		} else {
			// a single error
			code = [[errors firstObject].code integerValue];
			message = [errors firstObject].detail;
		}
		if ( message ) {
			userInfo[NSLocalizedDescriptionKey] = message;
		}
		if ( error ) {
			userInfo[NSUnderlyingErrorKey] = error;
		}
		if ( errors ) {
			userInfo[WebApiErrorResponseObjectKey] = errors;
		}
		result = [NSError errorWithDomain:self.errorDomain code:(code ? code : response.statusCode) userInfo:userInfo];
	}
	return result;
}

- (NSArray<JSONAPIError *> *)extractErrors:(NSDictionary<NSString *, id> *)responseObject {
	id errorsObj = responseObject[@"errors"];
	if ( ![errorsObj isKindOfClass:[NSArray class]] ) {
		return nil;
	}
	NSArray *errorsArray = (NSArray *)errorsObj;
	NSMutableArray<JSONAPIError *> *result = [[NSMutableArray alloc] initWithCapacity:errorsArray.count];
	for ( id arrayObj in errorsArray ) {
		if ( ![arrayObj isKindOfClass:[NSDictionary class]] ) {
			continue;
		}
		[result addObject:[JSONAPIError JSONAPIErrorWithResponseObject:arrayObj]];
	}
	return result;
}

@end
