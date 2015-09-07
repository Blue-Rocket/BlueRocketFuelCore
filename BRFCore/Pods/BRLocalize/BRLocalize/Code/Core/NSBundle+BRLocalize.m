//
//  NSBundle+BRLocalize.m
//  BlueRocketFuelCore
//
//  Created by Matt on 10/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "NSBundle+BRLocalize.h"

@implementation NSBundle (BRLocalize)

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
	NSError *error = nil;
	id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
	if ( error ) {
		NSLog(@"Error loading strings.json: %@", [error localizedDescription]);
	}
	return result;
}

@end
