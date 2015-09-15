//
//  AFNetworkingWebApiClientTests.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BaseNetworkTestingSupport.h"

#import <AFNetworking/AFURLSessionManager.h>
#import "AFNetworkingWebApiClient.h"
#import "BRSimpleEntityReference.h"
#import "DataWebApiResource.h"
#import "FileWebApiResource.h"
#import "WebApiClientEnvironment.h"

@interface AFNetworkingWebApiClientTests : BaseNetworkTestingSupport

@end

@implementation AFNetworkingWebApiClientTests {
	AFNetworkingWebApiClient *client;
}

- (void)setUp {
	[super setUp];
	BREnvironment *env = [self.testEnvironment copy];
	env[WebApiClientSupportServerPortEnvironmentKey] = [NSString stringWithFormat:@"%u", [self.http listeningPort]];
	NSLog(@"Environment port set to %@", env[WebApiClientSupportServerPortEnvironmentKey]);
	client = [[AFNetworkingWebApiClient alloc] initWithEnvironment:env];
}

- (void)testNotificationsSuccess {
	[self.http handleMethod:@"GET" withPath:@"/test" block:^(RouteRequest *request, RouteResponse *response) {
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];
	
	id<WebApiRoute> route = [client routeForName:@"test" error:nil];
	
	__block BOOL willBegin = NO;
	[self expectationForNotification:WebApiClientRequestWillBeginNotification object:route handler:^BOOL(NSNotification *note) {
		NSURLRequest *req = [note userInfo][WebApiClientURLRequestNotificationKey];
		NSURLResponse *res = [note userInfo][WebApiClientURLResponseNotificationKey];
		assertThat(req.URL.absoluteString, equalTo([self httpURLForRelativePath:@"test"].absoluteString));
		assertThat(res, nilValue());
		willBegin = YES;
		return YES;
	}];

	__block BOOL didBegin = NO;
	[self expectationForNotification:WebApiClientRequestDidBeginNotification object:route handler:^BOOL(NSNotification *note) {
		didBegin = YES;
		NSURLRequest *req = [note userInfo][WebApiClientURLRequestNotificationKey];
		NSURLResponse *res = [note userInfo][WebApiClientURLResponseNotificationKey];
		assertThat(req.URL.absoluteString, equalTo([self httpURLForRelativePath:@"test"].absoluteString));
		assertThat(res, nilValue());
		
		// make sure task identifier is tracked appropriately
		assertThat(client.activeTaskIdentifiers, hasCountOf(1));
		return YES;
	}];
	
	__block BOOL didSucceed = NO;
	[self expectationForNotification:WebApiClientRequestDidSucceedNotification object:route handler:^BOOL(NSNotification *note) {
		didSucceed = YES;
		NSURLRequest *req = [note userInfo][WebApiClientURLRequestNotificationKey];
		NSURLResponse *res = [note userInfo][WebApiClientURLResponseNotificationKey];
		assertThat(req.URL.absoluteString, equalTo([self httpURLForRelativePath:@"test"].absoluteString));
		assertThat(res, notNilValue());

		// make sure task identifier is released appropriately
		assertThat(client.activeTaskIdentifiers, isEmpty());
		
		return YES;
	}];
	
	XCTestExpectation *requestExpectation = [self expectationWithDescription:@"HTTP request"];
	[client requestAPI:@"test" withPathVariables:nil parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThatBool(willBegin, isTrue());
		assertThatBool(didBegin, isTrue());
		assertThatBool(didSucceed, isFalse());
		[requestExpectation fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testInvokeError404 {
	__block BOOL called = NO;
	[client requestAPI:@"test" withPathVariables:nil parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThatInteger(response.statusCode, equalTo(@404));
		assertThat(error, notNilValue());
		assertThat([error.userInfo[NSURLErrorFailingURLErrorKey] absoluteString], equalTo([[self httpURLForRelativePath:@"test"] absoluteString]));
		assertThat(response.responseObject, nilValue());
		called = YES;
	}];
	assertThatBool([self processMainRunLoopAtMost:10 stop:&called], equalTo(@YES));
}

- (void)testInvokeError422 {
	[self.http handleMethod:@"GET" withPath:@"/test" block:^(RouteRequest *request, RouteResponse *response) {
		[self respondWithJSON:@"{\"code\":123, \"message\":\"Your request failed.\"}" response:response status:422];
	}];
	
	__block BOOL called = NO;
	[client requestAPI:@"test" withPathVariables:nil parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThatInteger(response.statusCode, equalTo(@422));
		assertThat(error, notNilValue());
		assertThat(response.responseObject, notNilValue());
		assertThat([response.responseObject valueForKeyPath:@"code"], equalTo(@123));
		assertThat([response.responseObject valueForKeyPath:@"message"], equalTo(@"Your request failed."));
		called = YES;
	}];
	assertThatBool([self processMainRunLoopAtMost:10 stop:&called], equalTo(@YES));
}

- (void)testInvokeSimpleGET {
	[self.http handleMethod:@"GET" withPath:@"/test" block:^(RouteRequest *request, RouteResponse *response) {
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];

	__block BOOL called = NO;
	[client requestAPI:@"test" withPathVariables:nil parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.route.name, equalTo(@"test"));
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
	[client requestAPI:@"doc" withPathVariables:@{@"uniqueId" : @123 } parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.route.name, equalTo(@"doc"));
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		called = YES;
	}];
	assertThatBool([self processMainRunLoopAtMost:10 stop:&called], equalTo(@YES));
}

- (void)testInvokeGETWithPathVariableObject {
	[self.http handleMethod:@"GET" withPath:@"/document/123" block:^(RouteRequest *request, RouteResponse *response) {
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];
	
	// instead of a dictionary, pass an arbitrary object for the path variables; all declared properties will be available as path variables
	id<BREntityReference> docRef = [[BRSimpleEntityReference alloc] initWithUniqueId:@"123" displayName:@"Top Secret" info:nil];
	
	__block BOOL called = NO;
	[client requestAPI:@"doc" withPathVariables:docRef parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.route.name, equalTo(@"doc"));
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		called = YES;
	}];
	assertThatBool([self processMainRunLoopAtMost:10 stop:&called], equalTo(@YES));
}

- (void)testInvokeGETWithQueryParameter {
	[self.http handleMethod:@"GET" withPath:@"/test" block:^(RouteRequest *request, RouteResponse *response) {
		NSDictionary *queryParams = [request params];
		assertThat(queryParams[@"foo"], equalTo(@"bar"));
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];
	
	__block BOOL called = NO;
	[client requestAPI:@"test" withPathVariables:nil parameters:@{@"foo" : @"bar"} data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.route.name, equalTo(@"test"));
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		called = YES;
	}];
	assertThatBool([self processMainRunLoopAtMost:10 stop:&called], equalTo(@YES));
}

- (void)testInvokeGETWithQueryParameterObject {
	[self.http handleMethod:@"GET" withPath:@"/test" block:^(RouteRequest *request, RouteResponse *response) {
		NSDictionary *queryParams = [request params];
		assertThat(queryParams[@"uniqueId"], equalTo(@"123"));
		assertThat(queryParams[@"displayName"], equalTo(@"Top Secret"));
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];
	
	// instead of a dictionary, pass an arbitrary object for the query params; all declared properties will be available as parameters
	id<BREntityReference> docRef = [[BRSimpleEntityReference alloc] initWithUniqueId:@"123" displayName:@"Top Secret" info:nil];
	
	__block BOOL called = NO;
	[client requestAPI:@"test" withPathVariables:nil parameters:docRef data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.route.name, equalTo(@"test"));
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		called = YES;
	}];
	assertThatBool([self processMainRunLoopAtMost:10 stop:&called], equalTo(@YES));
}

- (void)testInvokePUTWithParameterObject {
	[self.http handleMethod:@"PUT" withPath:@"/document/123" block:^(RouteRequest *request, RouteResponse *response) {
		NSDictionary *postParams = [NSJSONSerialization JSONObjectWithData:[request body] options:0 error:nil];
		assertThat(postParams[@"uniqueId"], equalTo(@"123"));
		assertThat(postParams[@"displayName"], equalTo(@"Top Secret"));
		assertThat([postParams valueForKeyPath:@"info.password"], equalTo(@"secret"));
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];
	
	// instead of a dictionary, pass an arbitrary object for the query params; all declared properties will be available as parameters
	id<BREntityReference> docRef = [[BRSimpleEntityReference alloc] initWithUniqueId:@"123" displayName:@"Top Secret" info:@{@"password" : @"secret"}];
	
	__block BOOL called = NO;
	[client requestAPI:@"saveDoc" withPathVariables:docRef parameters:docRef data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.route.name, equalTo(@"saveDoc"));
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		called = YES;
	}];
	assertThatBool([self processMainRunLoopAtMost:10 stop:&called], equalTo(@YES));
}

- (void)testFileUpload {
	NSURL *fileURL = [self.bundle URLForResource:@"upload-test.txt" withExtension:nil];
	[self.http handleMethod:@"POST" withPath:@"/file/test_file" block:^(RouteRequest *request, RouteResponse *response) {
		NSDictionary *bodyParts = [self extractMultipartFormParts:request];
		DataWebApiResource *rsrc = bodyParts[@"test_file"];
		assertThat(rsrc.MIMEType, equalTo(@"text/plain"));
		assertThat(rsrc.fileName, equalTo(@"upload-test.txt"));
		assertThat([[NSString alloc] initWithData:rsrc.data encoding:NSUTF8StringEncoding], equalTo(@"Hello, server!\n"));
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];
	
	FileWebApiResource *r = [[FileWebApiResource alloc] initWithURL:fileURL name:@"test_file" MIMEType:nil];
	XCTestExpectation *requestExpectation = [self expectationWithDescription:@"HTTP request"];
	[client requestAPI:@"file" withPathVariables:r parameters:nil data:r finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.route.name, equalTo(@"file"));
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		[requestExpectation fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testFormPOST {
	NSDictionary *formParameters = @{@"one" : @"two", @"three" : @"four"};
	[self.http handleMethod:@"POST" withPath:@"/form" block:^(RouteRequest *request, RouteResponse *response) {
		NSDictionary *bodyParts = [self extractMultipartFormParts:request];
		assertThat(bodyParts, equalTo(formParameters));
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];
	
	XCTestExpectation *requestExpectation = [self expectationWithDescription:@"HTTP request"];
	[client requestAPI:@"form-post" withPathVariables:nil parameters:formParameters data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		[requestExpectation fulfill];
	}];
	
	// also test using the serializationName form in config.json, to the same endpoint
	XCTestExpectation *requestAltExpectation = [self expectationWithDescription:@"HTTP alt request"];
	[client requestAPI:@"form-post-alt" withPathVariables:nil parameters:formParameters data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		[requestAltExpectation fulfill];
	}];
	
	[self waitForExpectationsWithTimeout:2 handler:nil];
}

@end
