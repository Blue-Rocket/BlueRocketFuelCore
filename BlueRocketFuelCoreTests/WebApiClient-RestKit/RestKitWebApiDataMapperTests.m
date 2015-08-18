//
//  AFNetworkingWebApiClientTests.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BaseNetworkTestingSupport.h"

#import "AFNetworkingWebApiClient.h"
#import "BRAppUser.h"
#import "BRFCRestKitDataMapping.h"
#import "BRSimpleEntityReference.h"
#import "RestKitWebApiDataMapper.h"

@interface RestKitWebApiDataMapperTests : BaseNetworkTestingSupport

@end

@implementation RestKitWebApiDataMapperTests {
	AFNetworkingWebApiClient *client;
}

- (void)setUp {
	[super setUp];
	[self http]; // start up HTTP server, configure port in environment
	//client = [[AFNetworkingWebApiClient alloc] initWithEnvironment:self.testEnvironment];
}

- (void)testEncodeAppUserObject {
	RestKitWebApiDataMapper *mapper = [RestKitWebApiDataMapper sharedDataMapper];
	RKObjectMapping *userMapping = [BRFCRestKitDataMapping appUserMapping];
	[mapper registerRequestObjectMapping:[userMapping inverseMapping] forRouteName:@"login"];
	
	id<WebApiRoute> route = @{@"name" : @"login"};
	
	BRAppUser *login = [BRAppUser new];
	login.email = @"dude@example.com";
	login.password = @"foobar";
	
	NSError *error = nil;
	id encoded = [mapper performEncodingWithObject:login route:route error:&error];
	assertThat(error, nilValue());
	assertThat(encoded, notNilValue());
	assertThatBool([encoded isKindOfClass:[NSDictionary class]], equalTo(@YES));
	NSDictionary *parameters = encoded;
	assertThat(parameters, hasCountOf(2));
	assertThat(parameters[@"email"], equalTo(@"dude@example.com"));
	assertThat(parameters[@"password"], equalTo(@"foobar"));
}

- (void)testEncodeAppUserObjectWithRootKeyPath {
	RestKitWebApiDataMapper *mapper = [RestKitWebApiDataMapper sharedDataMapper];
	RKObjectMapping *userMapping = [BRFCRestKitDataMapping appUserMapping];
	[mapper registerRequestObjectMapping:[userMapping inverseMapping] forRouteName:@"login"];
	
	id<WebApiRoute> route = @{@"name" : @"login", @"dataMapperRequestRootKeyPath" : @"foo"};
	
	BRAppUser *login = [BRAppUser new];
	login.email = @"dude@example.com";
	login.password = @"foobar";
	
	NSError *error = nil;
	id encoded = [mapper performEncodingWithObject:login route:route error:&error];
	assertThat(error, nilValue());
	assertThat(encoded, notNilValue());
	assertThatBool([encoded isKindOfClass:[NSDictionary class]], equalTo(@YES));
	NSDictionary *parameters = encoded;
	assertThat(parameters, hasCountOf(1));
	parameters = parameters[@"foo"]; // rootKeyPath
	assertThat(parameters, hasCountOf(2));
	assertThat(parameters[@"email"], equalTo(@"dude@example.com"));
	assertThat(parameters[@"password"], equalTo(@"foobar"));
}

- (void)testMapAppUserObject {
	RestKitWebApiDataMapper *mapper = [RestKitWebApiDataMapper sharedDataMapper];
	RKObjectMapping *userMapping = [BRFCRestKitDataMapping appUserMapping];
	[mapper registerResponseObjectMapping:userMapping forRouteName:@"login"];
	
	id<WebApiRoute> route = @{@"name" : @"login"};
	
	NSError *error = nil;
	id obj = [mapper performMappingWithSourceObject:@{@"first_name" : @"The", @"last_name" : @"Dude", @"id" : @"abc123", @"email" : @"dude@example.com"} route:route error:&error];
	assertThat(error, nilValue());
	assertThatBool([obj isKindOfClass:[BRAppUser class]], equalTo(@YES));
	BRAppUser *user = obj;
	assertThat(user.email, equalTo(@"dude@example.com"));
	assertThat(user.firstName, equalTo(@"The"));
	assertThat(user.lastName, equalTo(@"Dude"));
	assertThat(user.email, equalTo(@"dude@example.com"));
	assertThat(user.uniqueId, equalTo(@"abc123"));
	assertThatBool(user.newUser, equalTo(@NO));
	assertThatBool(user.authenticated, equalTo(@NO));
}

- (void)testMapAppUserObjectWithRootKeyPath {
	RestKitWebApiDataMapper *mapper = [RestKitWebApiDataMapper sharedDataMapper];
	RKObjectMapping *userMapping = [BRFCRestKitDataMapping appUserMapping];
	[mapper registerResponseObjectMapping:userMapping forRouteName:@"login"];
	
	id<WebApiRoute> route = @{@"name" : @"login", @"dataMapperResponseRootKeyPath" : @"foo"};
	
	NSError *error = nil;
	id obj = [mapper performMappingWithSourceObject:@{@"foo" : @{@"first_name" : @"The", @"last_name" : @"Dude", @"id" : @"abc123", @"email" : @"dude@example.com"}} route:route error:&error];
	assertThat(error, nilValue());
	assertThatBool([obj isKindOfClass:[BRAppUser class]], equalTo(@YES));
	BRAppUser *user = obj;
	assertThat(user.email, equalTo(@"dude@example.com"));
	assertThat(user.firstName, equalTo(@"The"));
	assertThat(user.lastName, equalTo(@"Dude"));
	assertThat(user.email, equalTo(@"dude@example.com"));
	assertThat(user.uniqueId, equalTo(@"abc123"));
	assertThatBool(user.newUser, equalTo(@NO));
	assertThatBool(user.authenticated, equalTo(@NO));
}

@end
