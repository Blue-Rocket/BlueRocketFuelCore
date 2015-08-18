//
//  AFNetworkingWebApiClientTests.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BaseNetworkTestingSupport.h"

#import "AFNetworkingWebApiClient.h"

@interface AFNetworkingWebApiClientTests : BaseNetworkTestingSupport

@end

@implementation AFNetworkingWebApiClientTests {
	AFNetworkingWebApiClient *client;
}

- (void)setUp {
	[super setUp];
	[self http]; // start up HTTP server, configure port in environment
	client = [[AFNetworkingWebApiClient alloc] initWithEnvironment:self.testEnvironment];
}

- (void)testInvokeSimpleGET {
	[self.http handleMethod:@"GET" withPath:@"/test" block:^(RouteRequest *request, RouteResponse *response) {
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];

	__block BOOL called = NO;
	[client requestAPI:@"test" withPathVariables:nil parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		called = YES;
	}];
	assertThatBool([self processMainRunLoopAtMost:10 stop:&called], equalTo(@YES));
}

- (void)testInvokeGETWithPathVariable {
	[self.http handleMethod:@"GET" withPath:@"/document/123" block:^(RouteRequest *request, RouteResponse *response) {
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];
	
	__block BOOL called = NO;
	[client requestAPI:@"doc" withPathVariables:@{@"docId" : @123 } parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		called = YES;
	}];
	assertThatBool([self processMainRunLoopAtMost:10 stop:&called], equalTo(@YES));
}


@end
