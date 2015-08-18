//
//  AFNetworkingWebApiClientTests.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import "BaseNetworkTestingSupport.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#import "WebApiClientSupport.h"

@interface TestWebApiClient : WebApiClientSupport

@property (nonatomic, readonly) NSArray *routeNames;

@end

@implementation TestWebApiClient {
	NSMutableArray *routeNames;
}

@synthesize routeNames;

- (void)registerRoute:(id<WebApiRoute>)route forName:(NSString *)name {
	[super registerRoute:route forName:name];
	if ( routeNames == nil ) {
		routeNames = [[NSMutableArray alloc] initWithCapacity:8];
	}
	[routeNames addObject:name];
}

@end

@interface WebApiClientSupportTests : BaseNetworkTestingSupport

@end

@implementation WebApiClientSupportTests {
	TestWebApiClient *client;
}

- (void)setUp {
	[super setUp];
	
	client = [[TestWebApiClient alloc] initWithEnvironment:self.testEnvironment];
}

- (void)testLoadRoutes {
	assertThat(client.routeNames, containsInAnyOrder(@"register", @"login", nil));
}

@end
