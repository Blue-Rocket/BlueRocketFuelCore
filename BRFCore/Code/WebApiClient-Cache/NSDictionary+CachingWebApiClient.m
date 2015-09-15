//
//  NSDictionary+CachingWebApiClient.m
//  BRFCore
//
//  Created by Matt on 15/09/15.
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "NSDictionary+CachingWebApiClient.h"

#import "NSDictionary+WebApiClient.h"

@implementation NSDictionary (CachingWebApiRoute)

- (NSTimeInterval)cache {
	id val = self[NSStringFromSelector(@selector(cache))];
	return [val doubleValue];
}

@end

@implementation NSMutableDictionary (CachingWebApiRoute)

- (void)setCache:(NSTimeInterval)cache {
	[self setOrRemoveObject:@(cache) forKey:NSStringFromSelector(@selector(cache))];
}

@end
