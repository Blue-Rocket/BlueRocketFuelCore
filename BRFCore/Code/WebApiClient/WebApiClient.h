//
//  WebApiClient.h
//  BlueRocketFuelCore
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

#import "NSDictionary+WebApiClient.h"

NS_ASSUME_NONNULL_BEGIN

/** An error domain for web api client errors. */
extern NSString * const WebApiClientErrorDomain;

/** Error code when attempting to use a route that has no configuration available. */
extern const NSInteger WebApiClientErrorRouteNotAvailable;

/** A notification name for when a request will be initiated. */
extern NSString * const WebApiClientRequestWillBeginNotification;

/** A notification name for when a request has been initiated. */
extern NSString * const WebApiClientRequestDidBeginNotification;

/** A notification name for when a request did make progress. */
extern NSString * const WebApiClientRequestDidProgressNotification;

/** A notification name for when a request did succeed. */
extern NSString * const WebApiClientRequestDidSucceedNotification;

/** A notification name for when a request did fail. */
extern NSString * const WebApiClientRequestDidFailNotification;

/** A notification name for when a request did cancel. */
extern NSString * const WebApiClientRequestDidCancelNotification;

/** A notification user info key for a @c NSURLRequest object representing the original request for the API endpoint. */
extern NSString * const WebApiClientURLRequestNotificationKey;

/** A notification user info key for a @c NSURLResponse object representing the response from an API endpoint. */
extern NSString * const WebApiClientURLResponseNotificationKey;

@protocol WebApiResource;

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
 
 As the request is processed, the various @c WebApiClientRequest* notifications will be sent. For each notification 
 the notification object will be the @c WebApiRoute associated with the request. The @c WebApiClientURLRequestNotificationKey
 key will be populated in the notification @c userInfo dictionary with the original @c NSURLRequest.
 
 @param name The name of the API endpoint route to invoke.
 @param pathVariables Optional path variables to replace in the API's route URL.
 @param parameters Optional request parameters to add to the URL.
 @param data Optional data to send as the request content.
 @param callback A callback block to invoke with the response.
 */
- (void)requestAPI:(NSString *)name
 withPathVariables:(nullable id)pathVariables
		parameters:(nullable id)parameters
			  data:(nullable id<WebApiResource>)data
		  finished:(void (^)(id<WebApiResponse> response, NSError * __nullable error))callback;

@end

NS_ASSUME_NONNULL_END
