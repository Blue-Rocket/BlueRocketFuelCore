//
//  NSBundle+BR.m
//  BlueRocketFuelCore
//
//  Created by Matt on 10/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "NSBundle+BR.h"

@implementation NSBundle (BR)

+ (NSDictionary *)appStrings {
	static NSDictionary *appStrings = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		appStrings = [NSBundle mainBundle].appStrings;
	});
	return appStrings;
}

- (NSDictionary *)appStrings {
	NSString *path = [self pathForResource:@"strings" ofType:@"json"];
	if ( !path ) {
		return nil;
	}
	NSData *data = [[NSData alloc] initWithContentsOfFile:path];
	return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

+ (NSDictionary *)appConfig {
	static NSDictionary *appConfig = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		appConfig = [NSBundle mainBundle].appConfig;
	});
	return appConfig;
}

- (NSDictionary *)appConfig {
	NSString *path = [self pathForResource:@"config" ofType:@"json"];
	if ( !path ) {
		return nil;
	}
	NSData *data = [[NSData alloc] initWithContentsOfFile:path];
	return[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
}

@end
