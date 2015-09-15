//
//  AFNetworkingWebApiClientTests.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BaseNetworkTestingSupport.h"

#import <AFNetworking/AFURLSessionManager.h>
#import <PINCache/PINCache.h>
#import "AFNetworkingWebApiClient.h"
#import "BRSimpleEntityReference.h"
#import "DataWebApiResource.h"
#import "FileWebApiResource.h"
#import "PINCacheWebApiClient.h"
#import "WebApiClientCacheEntry.h"
#import "WebApiClientEnvironment.h"

@interface PINCacheWebApiClientTests : BaseNetworkTestingSupport

@end

@implementation PINCacheWebApiClientTests {
	AFNetworkingWebApiClient *client;
	PINCacheWebApiClient *cachingClient;
	PINCache *entryCache;
	PINCache *dataCache;
	NSMutableArray *cachedEntries;
	NSMutableArray *cachedData;
	int count;
}

- (void)setUp {
	[super setUp];
	BREnvironment *env = [self.testEnvironment copy];
	env[WebApiClientSupportServerPortEnvironmentKey] = [NSString stringWithFormat:@"%u", [self.http listeningPort]];
	NSLog(@"Environment port set to %@", env[WebApiClientSupportServerPortEnvironmentKey]);
	client = [[AFNetworkingWebApiClient alloc] initWithEnvironment:env];
	
	// dictionaries to collect cache objects
	cachedEntries = [[NSMutableArray alloc] initWithCapacity:8];
	cachedData = [[NSMutableArray alloc] initWithCapacity:8];
	
	entryCache = [[PINCache alloc] initWithName:@"PINCacheWebApiClientTests-EntryCache"];
	entryCache.memoryCache.willAddObjectBlock = ^(PINMemoryCache *cache, NSString *key, id __nullable object) {
		[cachedEntries addObject:@{@"key" : key, @"value" : object}];
	};
	dataCache = [[PINCache alloc] initWithName:@"PINCacheWebApiClientTests-DataCache"];
	dataCache.memoryCache.willAddObjectBlock = ^(PINMemoryCache *cache, NSString *key, id __nullable object) {
		[cachedData addObject:@{@"key" : key, @"value" : object}];
	};
	cachingClient = [[PINCacheWebApiClient alloc] initWithEntryCache:entryCache dataCache:dataCache];
	cachingClient.client = client;
	
	count = 0;
}

- (void)tearDown {
	[entryCache removeAllObjects];
	[dataCache removeAllObjects];
	[super tearDown];
}

- (void)testInvokeError404 {
	XCTestExpectation *requestExpectation = [self expectationWithDescription:@"Request"];
	[cachingClient requestAPI:@"test" withPathVariables:nil parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThatInteger(response.statusCode, equalTo(@404));
		assertThat(error, notNilValue());
		assertThat([error.userInfo[NSURLErrorFailingURLErrorKey] absoluteString], equalTo([[self httpURLForRelativePath:@"test"] absoluteString]));
		assertThat(response.responseObject, nilValue());
		[requestExpectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testInvokeError422 {
	[self.http handleMethod:@"GET" withPath:@"/test" block:^(RouteRequest *request, RouteResponse *response) {
		[self respondWithJSON:@"{\"code\":123, \"message\":\"Your request failed.\"}" response:response status:422];
	}];
	
	XCTestExpectation *requestExpectation = [self expectationWithDescription:@"Request"];
	[cachingClient requestAPI:@"test" withPathVariables:nil parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThatInteger(response.statusCode, equalTo(@422));
		assertThat(error, notNilValue());
		assertThat(response.responseObject, notNilValue());
		assertThat([response.responseObject valueForKeyPath:@"code"], equalTo(@123));
		assertThat([response.responseObject valueForKeyPath:@"message"], equalTo(@"Your request failed."));
		[requestExpectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testInvokeSimpleGET {
	[self.http handleMethod:@"GET" withPath:@"/test" block:^(RouteRequest *request, RouteResponse *response) {
		[self respondWithJSON:[NSString stringWithFormat:@"{\"success\":true, \"count\":%@}", @(++count)] response:response status:200];
	}];

	XCTestExpectation *requestExpectation = [self expectationWithDescription:@"Request"];
	[cachingClient requestAPI:@"test" withPathVariables:nil parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.responseObject[@"success"], equalTo(@YES));
		assertThat(error, nilValue());
		[requestExpectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:2 handler:nil];
	
	// process the main run loop to give time for the objects to be added to the caches
	BOOL stop = NO;
	[self processMainRunLoopAtMost:2 stop:&stop];
	
	// we should have one value in each cache
	assertThat(cachedEntries, hasCountOf(1));
	WebApiClientCacheEntry *entry = [cachedEntries firstObject][@"value"];
	assertThatInt((int)(entry.expires - entry.created), equalToInt(3));
	
	assertThat(cachedData, hasCountOf(1));
	id<WebApiResponse> response = [cachedData firstObject][@"value"];
	assertThatInt(response.statusCode, equalToInt(200));
	assertThat(response.responseObject[@"success"], equalTo(@YES));
}

- (void)testInvokeSimpleGETCached {
	[self testInvokeSimpleGET];
	
	XCTestExpectation *requestExpectation = [self expectationWithDescription:@"Request"];
	[cachingClient requestAPI:@"test" withPathVariables:nil parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.responseObject[@"success"], equalTo(@YES));
		assertThat(error, nilValue());
		[requestExpectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:2 handler:nil];
	
	// process the main run loop to give time for the objects to be added to the caches
	BOOL stop = NO;
	[self processMainRunLoopAtMost:2 stop:&stop];
	
	// we should STILL have one value in each cache
	assertThat(cachedEntries, hasCountOf(1));
	assertThat(cachedData, hasCountOf(1));
	
	// only ONE HTTP request processed
	assertThatInt(count, equalToInt(1));
}

- (void)testInvokeSimpleGETExpired {
	[self testInvokeSimpleGET];
	
	// wait a bit longer now, for items to expire
	// process the main run loop to give time for the objects to be added to the caches
	BOOL stop = NO;
	[self processMainRunLoopAtMost:1.1 stop:&stop];
	
	XCTestExpectation *requestExpectation = [self expectationWithDescription:@"Request"];
	[cachingClient requestAPI:@"test" withPathVariables:nil parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.responseObject[@"success"], equalTo(@YES));
		assertThat(error, nilValue());
		[requestExpectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:2 handler:nil];
	
	// process the main run loop to give time for the objects to be added to the caches
	[self processMainRunLoopAtMost:2 stop:&stop];
	
	// we should have TWO values in each cache
	assertThat(cachedEntries, hasCountOf(2));
	WebApiClientCacheEntry *entry = [cachedEntries lastObject][@"value"];
	assertThatInt((int)(entry.expires - entry.created), equalToInt(3));
	
	assertThat(cachedData, hasCountOf(2));
	id<WebApiResponse> response = [cachedData lastObject][@"value"];
	assertThatInt(response.statusCode, equalToInt(200));
	assertThat(response.responseObject[@"count"], equalTo(@2));
	
	assertThatInt(count, equalToInt(2));
}

- (void)testInvokeGETWithPathVariable {
	[self.http handleMethod:@"GET" withPath:@"/document/123" block:^(RouteRequest *request, RouteResponse *response) {
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];
	
	XCTestExpectation *requestExpectation = [self expectationWithDescription:@"Request"];
	[cachingClient requestAPI:@"doc" withPathVariables:@{@"uniqueId" : @123 } parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		[requestExpectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:2 handler:nil];

	// process the main run loop to give time for the objects to be added to the caches
	BOOL stop = NO;
	[self processMainRunLoopAtMost:1 stop:&stop];

	// we should have one value in each cache
	assertThat(cachedEntries, hasCountOf(1));
	WebApiClientCacheEntry *entry = [cachedEntries firstObject][@"value"];
	assertThatInt((int)(entry.expires - entry.created), equalToInt(3));
	
	assertThat(cachedData, hasCountOf(1));
	id<WebApiResponse> response = [cachedData firstObject][@"value"];
	assertThatInt(response.statusCode, equalToInt(200));
	assertThat(response.responseObject[@"success"], equalTo(@YES));
}

- (void)testInvokeTwoRequestsWithCache {
	[self.http handleMethod:@"GET" withPath:@"/test" block:^(RouteRequest *request, RouteResponse *response) {
		[self respondWithJSON:[NSString stringWithFormat:@"{\"success\":true, \"count\":%@}", @(++count)] response:response status:200];
	}];
	[self.http handleMethod:@"GET" withPath:@"/document/123" block:^(RouteRequest *request, RouteResponse *response) {
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];
	
	XCTestExpectation *requestTestExpectation = [self expectationWithDescription:@"TestRequest"];
	[cachingClient requestAPI:@"test" withPathVariables:nil parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.responseObject[@"success"], equalTo(@YES));
		assertThat(error, nilValue());
		[requestTestExpectation fulfill];
	}];
	XCTestExpectation *requestDocExpectation = [self expectationWithDescription:@"DocRequest"];
	[cachingClient requestAPI:@"doc" withPathVariables:@{@"uniqueId" : @123 } parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		[requestDocExpectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:2 handler:nil];
	
	// process the main run loop to give time for the objects to be added to the caches
	BOOL stop = NO;
	[self processMainRunLoopAtMost:2 stop:&stop];

	// we should have two values in each cache, with two different cache keys
	assertThat(cachedEntries, hasCountOf(2));
	NSString *key1 = [cachedEntries firstObject][@"key"];
	NSString *key2 = [cachedEntries lastObject][@"key"];
	assertThat(key1, notNilValue());
	assertThat(key2, notNilValue());
	assertThat(key1, isNot(equalTo(key2)));
	
	assertThat(cachedData, hasCountOf(2));
	key1 = [cachedData firstObject][@"key"];
	key2 = [cachedData lastObject][@"key"];
	assertThat(key1, notNilValue());
	assertThat(key2, notNilValue());
	assertThat(key1, isNot(equalTo(key2)));
}

- (void)testInvokeGETWithPathVariableObject {
	[self.http handleMethod:@"GET" withPath:@"/document/123" block:^(RouteRequest *request, RouteResponse *response) {
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];
	
	// instead of a dictionary, pass an arbitrary object for the path variables; all declared properties will be available as path variables
	id<BREntityReference> docRef = [[BRSimpleEntityReference alloc] initWithUniqueId:@"123" displayName:@"Top Secret" info:nil];
	
	XCTestExpectation *requestExpectation = [self expectationWithDescription:@"Request"];
	[cachingClient requestAPI:@"doc" withPathVariables:docRef parameters:nil data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		[requestExpectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:2 handler:nil];

	// process the main run loop to give time for the objects to be added to the caches
	BOOL stop = NO;
	[self processMainRunLoopAtMost:1 stop:&stop];
	
	// we should have one value in each cache
	assertThat(cachedEntries, hasCountOf(1));
	WebApiClientCacheEntry *entry = [cachedEntries firstObject][@"value"];
	assertThatInt((int)(entry.expires - entry.created), equalToInt(3));
	
	assertThat(cachedData, hasCountOf(1));
	id<WebApiResponse> response = [cachedData firstObject][@"value"];
	assertThatInt(response.statusCode, equalToInt(200));
	assertThat(response.responseObject[@"success"], equalTo(@YES));
}

- (void)testInvokeGETWithQueryParameter {
	[self.http handleMethod:@"GET" withPath:@"/test" block:^(RouteRequest *request, RouteResponse *response) {
		NSDictionary *queryParams = [request params];
		assertThat(queryParams[@"foo"], equalTo(@"bar"));
		[self respondWithJSON:@"{\"success\":true}" response:response status:200];
	}];
	
	XCTestExpectation *requestExpectation = [self expectationWithDescription:@"Request"];
	[cachingClient requestAPI:@"test" withPathVariables:nil parameters:@{@"foo" : @"bar"} data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		[requestExpectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:2 handler:nil];

	// process the main run loop to give time for the objects to be added to the caches
	BOOL stop = NO;
	[self processMainRunLoopAtMost:1 stop:&stop];
	
	// we should have one value in each cache
	assertThat(cachedEntries, hasCountOf(1));
	WebApiClientCacheEntry *entry = [cachedEntries firstObject][@"value"];
	assertThatInt((int)(entry.expires - entry.created), equalToInt(3));
	
	assertThat(cachedData, hasCountOf(1));
	id<WebApiResponse> response = [cachedData firstObject][@"value"];
	assertThatInt(response.statusCode, equalToInt(200));
	assertThat(response.responseObject[@"success"], equalTo(@YES));
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
	
	XCTestExpectation *requestExpectation = [self expectationWithDescription:@"Request"];
	[cachingClient requestAPI:@"test" withPathVariables:nil parameters:docRef data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		assertThat(response.responseObject, equalTo(@{@"success" : @YES}));
		assertThat(error, nilValue());
		[requestExpectation fulfill];
	}];
	[self waitForExpectationsWithTimeout:2 handler:nil];

	// process the main run loop to give time for the objects to be added to the caches
	BOOL stop = NO;
	[self processMainRunLoopAtMost:1 stop:&stop];
	
	// we should have one value in each cache
	assertThat(cachedEntries, hasCountOf(1));
	WebApiClientCacheEntry *entry = [cachedEntries firstObject][@"value"];
	assertThatInt((int)(entry.expires - entry.created), equalToInt(3));
	
	assertThat(cachedData, hasCountOf(1));
	id<WebApiResponse> response = [cachedData firstObject][@"value"];
	assertThatInt(response.statusCode, equalToInt(200));
	assertThat(response.responseObject[@"success"], equalTo(@YES));
}

@end
