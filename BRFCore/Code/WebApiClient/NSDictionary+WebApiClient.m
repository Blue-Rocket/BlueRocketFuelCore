//
//  NSDictionary+WebApiClient.m
//  BlueRocketFuelCore
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "NSDictionary+WebApiClient.h"

static CFStringRef CreateURLEncodedQueryParameterString(CFStringRef string);

// see http://tools.ietf.org/html/rfc3986#section-2.2
static CFStringRef CreateURLEncodedQueryParameterString(CFStringRef string) {
	return CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, string, NULL,
												   CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"),
												   kCFStringEncodingUTF8);
}

@implementation NSDictionary (WebApiClient)

#pragma mark - WebApiRoute

- (NSString *)name {
	return self[NSStringFromSelector(@selector(name))];
}

- (NSString *)path {
	return self[NSStringFromSelector(@selector(path))];
}

- (NSString *)method {
	return self[NSStringFromSelector(@selector(method))];
}

- (WebApiSerialization)serialization {
	id val = self[NSStringFromSelector(@selector(serialization))];
	if ( val ) {
		return [val unsignedIntegerValue];
	}
	val = self[NSStringFromSelector(@selector(serializationName))];
	return [NSDictionary webApiSerializationForName:val];
}

- (NSString *)contentType {
	return self[NSStringFromSelector(@selector(contentType))];
}

- (NSString *)dataMapper {
	return self[NSStringFromSelector(@selector(dataMapper))];
}

- (BOOL)isPreventUserInteraction {
	NSNumber *val = self[@"preventUserInteraction"];
	return [val boolValue];
}

- (NSString *)asURLQueryParameterString {
	NSMutableString *str = [NSMutableString new];
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		if ( [str length] > 0 ) {
			[str appendString:@"&"];
		}
		[str appendString:(CFBridgingRelease(CreateURLEncodedQueryParameterString((__bridge CFStringRef)[NSString stringWithFormat:@"%@", key])))];
		[str appendString:@"="];
		[str appendString:(CFBridgingRelease(CreateURLEncodedQueryParameterString((__bridge CFStringRef)[NSString stringWithFormat:@"%@", obj])))];
	}];
	return str;
}

#pragma mark - WebApiResponse

- (NSInteger)statusCode {
	NSNumber *val = self[NSStringFromSelector(@selector(statusCode))];
	return [val integerValue];
}

- (id)responseObject {
	return self[NSStringFromSelector(@selector(responseObject))];
}

- (NSDictionary *)responseHeaders {
	return self[NSStringFromSelector(@selector(responseHeaders))];
}

#pragma mark - Utilities

+ (NSString *)nameForWebApiSerialization:(WebApiSerialization)serialization {
	switch ( serialization ) {
		case WebApiSerializationJSON:
			return @"json";
			
		case WebApiSerializationForm:
			return @"form";
			
		case WebApiSerializationURL:
			return @"url";
			
		case WebApiSerializationNone:
			return @"none";
	}
	return @"json";
}

+ (WebApiSerialization)webApiSerializationForName:(NSString *)string {
	string = [string lowercaseString];
	if ( [string isEqualToString:@"json"] ) {
		return WebApiSerializationJSON;
	} else if ( [string isEqualToString:@"form"] ) {
		return WebApiSerializationForm;
	} else if ( [string isEqualToString:@"url"] ) {
		return WebApiSerializationURL;
	} else if ( [string isEqualToString:@"none"] ) {
		return WebApiSerializationNone;
	}
	return 0;
}

@end

@implementation NSMutableDictionary (WebApiClient)

/**
 Set an object on the receiver if non-nil, otherwise remove that key.
 
 @param object The object to set, or @c nil to remove any value associated with @c key.
 @param key The key of the object to set or remove.
 */
- (void)setOrRemoveObject:(id)object forKey:(NSString *)key {
	if ( object == nil ) {
		[self removeObjectForKey:key];
	} else {
		self[key] = object;
	}
}

- (void)setName:(NSString *)name {
	[self setOrRemoveObject:name forKey:NSStringFromSelector(@selector(name))];
}

- (void)setPath:(NSString *)path {
	[self setOrRemoveObject:path forKey:NSStringFromSelector(@selector(path))];
}

- (void)setMethod:(NSString *)method {
	[self setOrRemoveObject:method forKey:NSStringFromSelector(@selector(method))];
}

- (void)setSerialization:(WebApiSerialization)serialization {
	NSString *key = NSStringFromSelector(@selector(serialization));
	self[key] = @(serialization);
}

- (NSString *)serializationName {
	WebApiSerialization ser = [self serialization];
	return [NSDictionary nameForWebApiSerialization:ser];
}

- (void)setSerializationName:(NSString *)name {
	[self setSerialization:[NSDictionary webApiSerializationForName:name]];
}

- (void)setContentType:(NSString *)contentType {
	[self setOrRemoveObject:contentType forKey:NSStringFromSelector(@selector(contentType))];
}

- (void)setDataMapper:(NSString *)dataMapper {
	[self setOrRemoveObject:dataMapper forKey:NSStringFromSelector(@selector(dataMapper))];
}

- (void)setPreventUserInteraction:(BOOL)preventUserInteraction {
	[self setOrRemoveObject:@(preventUserInteraction) forKey:@"preventUserInteraction"];
}

#pragma mark - WebApiResponse

- (void)setStatusCode:(NSInteger)statusCode {
	[self setOrRemoveObject:@(statusCode) forKey:NSStringFromSelector(@selector(statusCode))];
}

- (void)setResponseObject:(id)responseObject {
	[self setOrRemoveObject:responseObject forKey:NSStringFromSelector(@selector(responseObject))];
}

- (void)setResponseHeaders:(NSDictionary *)responseHeaders {
	[self setOrRemoveObject:responseHeaders forKey:NSStringFromSelector(@selector(responseHeaders))];
}

@end