//
//  BRDevelopmentWebApiClientTests.m
//  BRFCore
//
//  Created by Matt on 12/09/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import "BaseTestingSupport.h"

#import "BRDevelopmentWebApiClient.h"

@interface BRDevelopmentWebApiClientTests : BaseTestingSupport

@end

@implementation BRDevelopmentWebApiClientTests {
	BRDevelopmentWebApiClient *client;
}

- (void)setUp {
	[super setUp];
	client = [[BRDevelopmentWebApiClient alloc] initWithEnvironment:self.testEnvironment];
}

- (void)testJsonResourceResponse {
	[client registerRoute:@{ @"method" : @"GET", @"path" : @"api/test"} forName:@"test"];
	
	XCTestExpectation *expectation = [self expectationWithDescription:@"Finished"];
	[client requestAPI:@"test" withPathVariables:nil parameters:nil data:nil finished:^(id<WebApiResponse>  _Nullable response, NSError * _Nullable error) {
		assertThat(response.routeName, equalTo(@"test"));
		assertThatInteger(response.statusCode, equalToInteger(200));
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		[expectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:2 handler:nil];
}

@end
