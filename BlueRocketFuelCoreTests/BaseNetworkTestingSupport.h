//
//  BaseNetworkTestingSupport.h
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BaseTestingSupport.h"

#import <RoutingHTTPServer/RoutingHTTPServer.h>

/**
 A base @c XCTestCase class for other unit tests to extend that require basic HTTP networking support.
 */
@interface BaseNetworkTestingSupport : BaseTestingSupport

/**
 Get an internal HTTP server instance. The server will use a randomly available port when first started.
 The @c testEnvironment will be updated with the port number, available at @c WebApiClientSupportServerPortEnvironmentKey.
 */
@property (nonatomic, readonly) RoutingHTTPServer *http;

/**
 A base URL to the configured HTTP server. The HTTP server will be started when invoking this property, if not already running.
 */
@property (nonatomic, readonly) NSURL *httpURL;

/**
 Process the main run loop for a maximum number of seconds or until the BOOL parameter is YES,
 whichever occurs first; returns the value of the 'stop' parameter.
 
 @param seconds The maximum number of seconds to wait for the @c stop flag.
 @param stop Set to @c YES to stop processing the main run loop before @c seconds have passed.
 @return The value of the @c stop pointer.
 */
- (BOOL)processMainRunLoopAtMost:(NSTimeInterval)seconds stop:(BOOL *)stop;

/**
 Respond to a HTTP request with a JSON string value and status code.
 
 @param json The JSON string to return as the HTTP body.
 @param response The HTTP respose object to write the response to.
 @param statusCode The HTTP statuc code to respond with.
 */
- (void)respondWithJSON:(NSString *)json response:(RouteResponse *)response status:(NSInteger)statusCode;

/**
 Respond to a HTTP request with a JSON bundle resource and status code.
 
 @param name The name of JSON resource in the configured bundle to return as the HTTP body.
 @param response The HTTP respose object to write the response to.
 @param statusCode The HTTP statuc code to respond with.
 */
- (void)respondWithJSONResource:(NSString *)name response:(RouteResponse *)response status:(NSInteger)statusCode;

/**
 Respond to a HTTP request with a JSON bundle resource where parameters in the form of ${param}
 are replaced by corresponding values in the provided 'parameters' dictionary.
 
 @param name The name of JSON resource in the configured bundle to return as the HTTP body.
 @param parameters Template parameters to replace from the JSON content.
 @param response The HTTP respose object to write the response to.
 @param statusCode The HTTP statuc code to respond with.
 */
- (void)respondWithJSONTemplate:(NSString *)name parameters:(NSDictionary *)parameters
					   response:(RouteResponse *)response status:(NSInteger)statusCode;

@end

