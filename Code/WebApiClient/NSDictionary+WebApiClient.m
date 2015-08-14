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
	return [self[NSStringFromSelector(@selector(serialization))] unsignedIntegerValue];
}

- (NSString *)contentType {
	return self[NSStringFromSelector(@selector(contentType))];
}

- (NSString *)dataMapper {
	return self[NSStringFromSelector(@selector(dataMapper))];
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

- (void)setContentType:(NSString *)contentType {
	[self setOrRemoveObject:contentType forKey:NSStringFromSelector(@selector(contentType))];
}

- (void)setDataMapper:(NSString *)dataMapper {
	[self setOrRemoveObject:dataMapper forKey:NSStringFromSelector(@selector(dataMapper))];
}

@end