//
//  BaseNetworkTestingSupport.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import "BaseNetworkTestingSupport.h"

#import <BREnvironment/BREnvironment.h>
#import "WebApiClientEnvironment.h"

@implementation BaseNetworkTestingSupport {
	RoutingHTTPServer *http;
}

- (void)tearDown {
	[super tearDown];
	[http stop];
	http = nil;
	self.testEnvironment[WebApiClientSupportServerPortEnvironmentKey] = nil;
}

- (RoutingHTTPServer *)http {
	if ( http == nil ) {
		http = [[RoutingHTTPServer alloc] init];
		[http setDefaultHeader:@"Server" value:@"BRMenuTests/1.0"];
		[http start:nil];
		self.testEnvironment[WebApiClientSupportServerPortEnvironmentKey] = [NSString stringWithFormat:@"%u", [http listeningPort]];
	}
	return http;
}

- (NSURL *)httpURL {
	return [NSURL URLWithString:[@"http://localhost:" stringByAppendingFormat:@"%u", [self.http listeningPort]]];
}

#pragma mark - Threading support

- (BOOL)processMainRunLoopAtMost:(NSTimeInterval)seconds stop:(BOOL *)stop {
	NSParameterAssert(stop);
	NSTimeInterval cutoff = [NSDate timeIntervalSinceReferenceDate] + seconds;
	while ( (*stop == NO) && [NSDate timeIntervalSinceReferenceDate] < cutoff ) {
		[[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.2]];
	}
	return *stop;
}

#pragma mark - HTTP JSON support

- (void)respondWithJSON:(NSString *)json response:(RouteResponse *)response status:(NSInteger)statusCode {
	[response setStatusCode:statusCode];
	[response setHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
	[response respondWithString:json encoding:NSUTF8StringEncoding];
}

- (void)respondWithJSONResource:(NSString *)name response:(RouteResponse *)response status:(NSInteger)statusCode {
	[response setStatusCode:statusCode];
	[response setHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
	NSURL *jsonResourceURL = [self.bundle URLForResource:name withExtension:@"json"];
	NSString *json = [NSString stringWithContentsOfURL:jsonResourceURL encoding:NSUTF8StringEncoding error:nil];
	XCTAssertNotNil(json, @"Error parsing JSON resource: %@", name);
	[response respondWithString:json encoding:NSUTF8StringEncoding];
}

- (void)respondWithJSONTemplate:(NSString *)name parameters:(NSDictionary *)parameters response:(RouteResponse *)response status:(NSInteger)statusCode {
	[response setStatusCode:statusCode];
	[response setHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
	NSURL *jsonResourceURL = [self.bundle URLForResource:name withExtension:@"json"];
	NSString *json = [NSString stringWithContentsOfURL:jsonResourceURL encoding:NSUTF8StringEncoding error:nil];
	
	static NSRegularExpression *regex = nil;
	if ( regex == nil ) {
		NSError *error;
		regex = [[NSRegularExpression alloc] initWithPattern:@"\\$\\{(\\w+)\\}" options:0 error:&error];
		NSAssert(regex != nil, @"Regex should have compiled: %@", [error localizedDescription]);
	}
	
	__block NSUInteger endOfPreviousMatch = 0;
	NSMutableString *resultJSON = [NSMutableString stringWithCapacity:[json length]];
	[regex enumerateMatchesInString:json options:0 range:NSMakeRange(0, [json length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange matchRange = [result range];
		[resultJSON appendString:[json substringWithRange:NSMakeRange(endOfPreviousMatch, matchRange.location - endOfPreviousMatch)]];
		NSString *paramName = [json substringWithRange:[result rangeAtIndex:1]];
		NSString *paramValue = parameters[paramName];
		if ( [paramValue length] > 0 ) {
			[resultJSON appendString:paramValue];
		}
		endOfPreviousMatch = matchRange.location + matchRange.length;
	}];
	if ( endOfPreviousMatch < [json length] ) {
		// add last word segment
		[resultJSON appendString:[json substringFromIndex:endOfPreviousMatch]];
	}
	
	[response respondWithString:resultJSON encoding:NSUTF8StringEncoding];
}

@end
