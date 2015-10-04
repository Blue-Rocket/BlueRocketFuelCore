//
//  BaseNetworkTestingSupport.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BaseNetworkTestingSupport.h"

#import <BREnvironment/BREnvironment.h>
#import "DataWebApiResource.h"

@implementation BaseNetworkTestingSupport {
	RoutingHTTPServer *http;
}

- (void)tearDown {
	[super tearDown];
	[http stop];
	http = nil;
}

- (RoutingHTTPServer *)http {
	if ( http == nil ) {
		http = [[RoutingHTTPServer alloc] init];
		[http setDefaultHeader:@"Server" value:@"BRMenuTests/1.0"];
		[http start:nil];
		NSLog(@"HTTP server started at %@", [self httpURL]);
	}
	return http;
}

- (NSURL *)httpURL {
	return [NSURL URLWithString:[@"http://localhost:" stringByAppendingFormat:@"%u", [self.http listeningPort]]];
}

- (NSURL *)httpURLForRelativePath:(NSString *)path {
	return [NSURL URLWithString:path relativeToURL:[self httpURL]];
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

#pragma mark - HTTP Multipart Form support

- (NSDictionary *)extractMultipartFormParts:(RouteRequest *)request {
	NSMutableDictionary *result = [NSMutableDictionary new];
	
	NSString *contentType = [request header:@"Content-Type"];
	assertThat(contentType, startsWith(@"multipart/form-data"));
	NSUInteger paramsIdx = [contentType rangeOfString:@";"].location;
	assertThatUnsignedInteger(paramsIdx, greaterThan(@0));
	NSArray *contentParams = [[contentType substringFromIndex:(paramsIdx + 1)] componentsSeparatedByString:@";"];
	assertThatUnsignedInteger(contentParams.count, greaterThan(@0));
	NSString *boundaryParam = contentParams[[contentParams indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [[(NSString *)obj stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] hasPrefix:@"boundary"];
	}]];
	NSString *boundary = [[boundaryParam componentsSeparatedByString:@"="] lastObject];
	assertThat(boundary, notNilValue());
	
	NSString *bodyData = [[NSString alloc] initWithData:[request body] encoding:NSUTF8StringEncoding];
	NSScanner *scanner = [[NSScanner alloc] initWithString:bodyData];
	scanner.charactersToBeSkipped = nil;
	NSCharacterSet *headerDelimSet = [NSCharacterSet characterSetWithCharactersInString:@": "];

	while ( ![scanner isAtEnd] ) {
		NSString *str = nil;

		// read part headers
		[scanner scanUpToString:[NSString stringWithFormat:@"--%@", boundary] intoString:NULL];
		if ( ![scanner scanString:[NSString stringWithFormat:@"--%@", boundary] intoString:NULL] ) {
			break;
		}
		if ( [scanner scanString:@"--\r\n" intoString:NULL] ) {
			break;
		} else if ( ![scanner scanString:@"\r\n" intoString:NULL] ) {
			break;
		}
		
		// read part header data
		NSString *partContentDisposition = nil;
		NSString *partContentType = nil;
		NSString *partContentBody = nil;
		while ( true ) {
			[scanner scanUpToCharactersFromSet:headerDelimSet intoString:&str];
			[scanner scanCharactersFromSet:headerDelimSet intoString:NULL];
			if ( [str caseInsensitiveCompare:@"Content-Disposition"] == NSOrderedSame ) {
				[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&partContentDisposition];
			} else if ( [str caseInsensitiveCompare:@"Content-Type"] == NSOrderedSame ) {
				[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&partContentType];
			} else {
				[scanner scanUpToCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:NULL];
			}
			str = nil;
			[scanner scanCharactersFromSet:[NSCharacterSet newlineCharacterSet] intoString:&str];
			if ( [str length] > 2 ) {
				break;
			}
		}
		[scanner scanUpToString:[NSString stringWithFormat:@"\r\n--%@", boundary] intoString:&partContentBody];
		[scanner scanString:@"\r\n" intoString:NULL];
		
		// at this point, scanner is at --Boundary or --\r\n(EOF)
		
		paramsIdx = [partContentDisposition rangeOfString:@";"].location;
		assertThat([partContentDisposition substringToIndex:paramsIdx], equalTo(@"form-data"));
		contentParams = [[partContentDisposition substringFromIndex:(paramsIdx + 1)] componentsSeparatedByString:@";"];
		NSMutableDictionary *partDisposition = [NSMutableDictionary new];
		for ( NSString *param in contentParams ) {
			NSArray *comps = [[param stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByString:@"="];
			assertThat(comps, hasCountOf(2));
			partDisposition[comps[0]] = [comps[1] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
		}
		
		if ( [partContentType length] > 0 ) {
			// file part
			DataWebApiResource *r = [[DataWebApiResource alloc] initWithData:[partContentBody dataUsingEncoding:NSUTF8StringEncoding]
																		name:partDisposition[@"name"]
																	fileName:(partDisposition[@"filename"] != nil ? partDisposition[@"filename"] : partDisposition[@"name"])
																	MIMEType:partContentType];
			result[partDisposition[@"name"]] = r;
		} else {
			result[partDisposition[@"name"]] = partContentBody;
		}
	}
	return result;
}

@end
