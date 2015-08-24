//
//  NSDictionary_WebApiClientTests.m
//  BRFCore
//
//  Created by Matt on 24/08/15.
//  Copyright (c) 2015 Blue Rocket, Inc. All rights reserved.
//

#import "BaseTestingSupport.h"

#import "NSDictionary+WebApiClient.h"
#import "WebApiRoute.h"

@interface NSDictionary_WebApiClientTests : BaseTestingSupport

@end

@implementation NSDictionary_WebApiClientTests

- (void)testWebApiRouteGetters {
	NSDictionary *route = @{@"name" : @"test", @"path" : @"test/path", @"method" : @"POST", @"serialization" : @2,
							  @"contentType" : @"foo/bar", @"dataMapper" : @"SomeClassName", @"preventUserInteraction" : @YES};
	assertThat(route.name, equalTo(@"test"));
	assertThat(route.path, equalTo(@"test/path"));
	assertThat(route.method, equalTo(@"POST"));
	assertThatUnsignedInteger(route.serialization, equalTo(@(WebApiSerializationForm)));
	assertThat(route.contentType, equalTo(@"foo/bar"));
	assertThat(route.dataMapper, equalTo(@"SomeClassName"));
	assertThatBool(route.preventUserInteraction, equalTo(@YES));
}

- (void)testSerializationNameGetter {
	id<WebApiRoute> route = @{@"serializationName" : @"form"};
	assertThatUnsignedInteger(route.serialization, equalTo(@2));
}

- (void)testSerializationNameSetter {
	NSMutableDictionary *route = [NSMutableDictionary new];

	route.serializationName = @"json";
	assertThatUnsignedInteger(route.serialization, equalToUnsignedInteger(WebApiSerializationJSON));

	route.serializationName = @"form";
	assertThatUnsignedInteger(route.serialization, equalToUnsignedInteger(WebApiSerializationForm));
	
	route.serializationName = @"url";
	assertThatUnsignedInteger(route.serialization, equalToUnsignedInteger(WebApiSerializationURL));

	route.serializationName = @"none";
	assertThatUnsignedInteger(route.serialization, equalToUnsignedInteger(WebApiSerializationNone));
}

- (void)testSerializationNameSetterUnknownString {
	NSMutableDictionary *route = [NSMutableDictionary new];
	
	route.serializationName = @"blahblah";
	assertThatUnsignedInteger(route.serialization, equalToUnsignedInteger(0));
}

@end
