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

- (NSTimeInterval)cacheTTL {
	id val = self[NSStringFromSelector(@selector(cacheTTL))];
	return [val doubleValue];
}

- (NSArray<NSString *> *)invalidatesCachedRouteNames {
	id val = self[NSStringFromSelector(@selector(invalidatesCachedRouteNames))];
	return ([val isKindOfClass:[NSArray class]] ? val : nil);
}

- (BOOL)isCacheIgnoreQueryParameters {
	NSNumber *val = self[@"cacheIgnoreQueryParameters"];
	return [val boolValue];
}

@end

@implementation NSMutableDictionary (CachingWebApiRoute)

- (void)setCacheTTL:(NSTimeInterval)ttl {
	[self setOrRemoveObject:@(ttl) forKey:NSStringFromSelector(@selector(cacheTTL))];
}

- (void)setInvalidatesCachedRouteNames:(NSArray<NSString *> *)invalidatesCachedRouteNames {
	[self setOrRemoveObject:invalidatesCachedRouteNames forKey:NSStringFromSelector(@selector(invalidatesCachedRouteNames))];
}

- (void)setCacheIgnoreQueryParameters:(BOOL)cacheIgnoreQueryParameters {
	[self setOrRemoveObject:@(cacheIgnoreQueryParameters) forKey:@"cacheIgnoreQueryParameters"];
}

@end
