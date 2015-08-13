//
//  WebApiClient.h
//  BlueRocketFuelCore
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

#import "NSDictionary+WebApiClient.h"

@protocol WebApiResponse;

/** An error domain for web api client errors. */
extern NSString * const WebApiClientErrorDomain;

/** Error code when attempting to use a route that has no configuration available. */
extern const NSInteger WebApiClientErrorRouteNotAvailable;

/**
 A WebApiClient provides a centralized way for an application to interact with a web-based API based on named URL routes.
 */
@protocol WebApiClient <NSObject>

/**
 Get a globally shared client.
 
 @return A shared client instance.
 */
+ (instancetype)sharedClient;

/**
 Request a web API endpoint for a named URL route.
 
 @param name The name of the API endpoint route to invoke.
 @param pathVariables Optional path variables to replace in the API's route URL.
 @param parameters Optional request parameters to add to the URL.
 @param data Optional data to send as the request content.
 @param callback A callback block to invoke with the response.
 */
- (void)requestAPI:(NSString *)name withPathVariables:(id)pathVariables parameters:(id)parameters data:(id)data
		  finished:(void (^)(id<WebApiResponse> response, id data, NSError *error))callback;

@end

/**
 @protocol WebApiResponse
 
 @abstract A WebApiResponse object represents a response to a HTTP URL load.
 */
@protocol  WebApiResponse <NSObject>

/**
 @method statusCode
 @abstract Returns the HTTP status code of the receiver.
 @result The HTTP status code of the receiver.
 */
@property (readonly) NSInteger statusCode;

@end
