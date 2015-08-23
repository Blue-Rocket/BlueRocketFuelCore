//
//  BRSimpleEntityReference.m
//  BlueRocketFuelCore
//
//  Created by Matt on 19/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BRSimpleEntityReference.h"

@implementation BRSimpleEntityReference {
	NSString *uniqueId;
	NSString *displayName;
	NSDictionary *info;
}

@synthesize uniqueId;
@synthesize displayName;
@synthesize info;

- (instancetype)initWithUniqueId:(NSString *)aUniqueId displayName:(NSString *)aDisplayName info:(NSDictionary *)someInfo {
	if ( (self = [super init]) ) {
		uniqueId = aUniqueId;
		displayName = aDisplayName;
		info = someInfo;
	}
	return self;
}

@end
