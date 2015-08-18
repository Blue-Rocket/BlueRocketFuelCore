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

#import "BRAppUser.h"
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

@interface TestUser : BRAppUser

@property (nonatomic, strong) NSString *subclassProp;

@end

#pragma mark - Unit tests

@interface WebApiClientSupportTests : BaseNetworkTestingSupport

@end

@implementation WebApiClientSupportTests {
	TestWebApiClient *client;
}

- (void)setUp {
	[super setUp];
	
	client = [[TestWebApiClient alloc] initWithEnvironment:self.testEnvironment];
}

- (void)testBaseApiURL {
	NSURL *baseURL = [client baseApiURL];
	assertThat(baseURL, equalTo([NSURL URLWithString:@"http://localhost/"]));
}

- (void)testLoadRoutes {
	assertThat(client.routeNames, containsInAnyOrder(@"register", @"login", @"user", nil));
	id<WebApiRoute> route = [client routeForName:@"register" error:nil];
	assertThat(route, notNilValue());
	assertThat(route.name, equalTo(@"register"));
	assertThat(route.path, equalTo(@"register"));
	assertThat(route.method, equalTo(@"POST"));
	assertThat(route.dataMapper, equalTo(@"RestKitWebApiDataMapper"));
	assertThat(route[@"dataMapperRequestRootKeyPath"], equalTo(@"user"));
	assertThatBool(route.preventUserInteraction, isTrue());
	
	route = [client routeForName:@"login" error:nil];
	assertThat(route, notNilValue());
	assertThat(route.name, equalTo(@"login"));
	assertThat(route.path, equalTo(@"login"));
	assertThat(route.method, equalTo(@"POST"));
	assertThat(route.dataMapper, equalTo(@"RestKitWebApiDataMapper"));
	assertThat(route[@"dataMapperRequestRootKeyPath"], equalTo(@"user"));
	assertThatBool(route.preventUserInteraction, isTrue());
}

- (void)testURLPathVariable {
	id<WebApiRoute> route = [client routeForName:@"user" error:nil];
	NSURL *url = [client URLForRoute:route pathVariables:@{ @"userId" : @(1234) } parameters:nil error:nil];
	assertThat([url absoluteString], equalTo(@"http://localhost/user/1234"));
}

- (void)dictionaryFromUserObject {
	BRAppUser *user = nil;
	NSDictionary *dictionary = [client dictionaryForParametersObject:user];
}

@end
