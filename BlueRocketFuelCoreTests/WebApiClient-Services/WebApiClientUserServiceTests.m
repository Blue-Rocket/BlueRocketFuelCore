//
//  AFNetworkingWebApiClientTests.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BaseNetworkTestingSupport.h"

#import <OCMock/OCMock.h>
#import "BRAppUser.h"
#import "WebApiClientUserService.h"

@interface WebApiClientUserServiceTests : BaseNetworkTestingSupport

@end

@implementation WebApiClientUserServiceTests {
	id<WebApiClient> mockClient;
	WebApiClientUserService *userService;
}

- (void)setUp {
	[super setUp];
	mockClient = OCMStrictProtocolMock(@protocol(WebApiClient));
	userService = [[WebApiClientUserService alloc] init];
	userService.client = mockClient;
}

- (void)tearDown {
	
	[super tearDown];
}

- (void)testRegisterUser {
	BRAppUser *newUser = [BRAppUser new];
	newUser.email = @"email";
	newUser.password = @"pass";

	// sub the client call to return a successfully registered user
	OCMExpect([mockClient requestAPI:equalTo(@"register") withPathVariables:nil parameters:newUser data:nil finished:[OCMArg checkWithBlock:^BOOL(id obj) {
		void (^block)(id<WebApiResponse> response, NSError *error) = obj;
		BRAppUser *regUser = [BRAppUser new];
		regUser.email = newUser.email;
		regUser.uniqueId = @"123";
		regUser.authenticationToken = @"token";
		block(@{ @"responseObject" : regUser, @"statusCode" : @200}, nil);
		return YES;
	}]]);
	
	__block BOOL called = NO;
	[userService registerNewUser:newUser finished:^(id<BRUser> user, NSError *error) {
		assertThat(user.uniqueId, equalTo(@"123"));
		assertThat(user.email, equalTo(@"email"));
		assertThatBool(user.newUser, isFalse());
		assertThatBool(user.authenticated, isTrue());
		called = YES;
	}];
	
	OCMVerifyAll((id)mockClient);
	assertThatBool(called, isTrue());
}

@end
