//
//  BaseTestingSupport.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import "BaseTestingSupport.h"

#import <BREnvironment/BREnvironment.h>
#import "BRAppConfigEnvironmentProvider.h"

static NSBundle *bundle;
static BREnvironment *testEnvironment;

@implementation BaseTestingSupport {
	BRAppConfigEnvironmentProvider *provider;
}

- (NSBundle *)bundle {
	return bundle;
}

- (BREnvironment *)testEnvironment {
	return testEnvironment;
}

+ (void)setUp {
	bundle = [[NSBundle alloc] initWithURL:[NSBundle bundleForClass:[self class]].bundleURL];
	[BREnvironment setSharedEnvironmentBundle:bundle];
	testEnvironment = [BREnvironment sharedEnvironment];
}

- (void)setUp {
	[super setUp];
	// register a config.json provider from the unit test bundle
	provider = [[BRAppConfigEnvironmentProvider alloc] init];
	provider.bundle = bundle;
	[BREnvironment registerEnvironmentProvider:provider];
}

- (void)tearDown {
	[BREnvironment unregisterEnvironmentProvider:provider];
	[super tearDown];
}

@end
