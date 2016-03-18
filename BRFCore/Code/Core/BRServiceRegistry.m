//
//  BRServiceRegistry.m
//  BRFCore
//
//  Created by Matt on 18/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import "BRServiceRegistry+BR.h"

static Class SharedRegistryClass = NULL;
static BRServiceRegistry *SharedRegistry =  nil;

@implementation BRServiceRegistry {
	id<BRUserService> userService;
}

@synthesize userService;

+ (BOOL)hasSharedRegistry {
	return (SharedRegistry != nil);
}

+ (instancetype)sharedRegistry {
	// note we are not locking this, with the expectation an app will set this once during startup and never touch it again
	BRServiceRegistry *result = SharedRegistry;
	if ( result == nil ) {
		Class clazz = SharedRegistryClass;
		if ( !clazz ) {
			clazz = self;
		}
		result = [[clazz alloc] init];
		SharedRegistry = result;
	}
	return result;
}

+ (void)setSharedRegistryClass:(Class)clazz {
	NSAssert([clazz isSubclassOfClass:[SharedRegistry class]], @"Must be a subclass of ServiceRegistry, not %@", NSStringFromClass(clazz));
	if ( clazz != SharedRegistryClass ) {
		SharedRegistryClass = clazz;
		SharedRegistry = nil;
	}
}

@end

@implementation BRServiceRegistry (BR)

- (void)setUserService:(nonnull id<BRUserService>)service {
	userService = service;
}

@end
