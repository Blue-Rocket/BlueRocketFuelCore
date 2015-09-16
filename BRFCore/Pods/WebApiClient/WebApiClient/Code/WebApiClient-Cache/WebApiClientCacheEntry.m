//
//  WebApiClientCacheEntry.m
//  BRFCore
//
//  Created by Matt on 15/09/15.
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiClientCacheEntry.h"

@implementation WebApiClientCacheEntry

- (id)initWithCoder:(NSCoder *)aDecoder {
	NSTimeInterval created = [aDecoder decodeDoubleForKey:NSStringFromSelector(@selector(created))];
	NSTimeInterval expires = [aDecoder decodeDoubleForKey:NSStringFromSelector(@selector(expires))];
	return [self initWithCreationTime:created expireTime:expires];
}

- (instancetype)init {
	return [self initWithCreationTime:0 expireTime:0];
}

- (instancetype)initWithCreationTime:(NSTimeInterval)created expireTime:(NSTimeInterval)expires {
	if ( (self = [super init]) ) {
		_created = created;
		_expires = expires;
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeDouble:_created forKey:NSStringFromSelector(@selector(created))];
	[aCoder encodeDouble:_expires forKey:NSStringFromSelector(@selector(expires))];
}

@end
