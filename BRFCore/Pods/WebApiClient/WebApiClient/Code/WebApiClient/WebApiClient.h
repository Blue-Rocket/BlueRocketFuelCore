//
//  WebApiClient.h
//  WebApiClient
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

/** Error code when a timeout is reached waiting for a client response. */
extern const NSInteger WebApiClientErrorResponseTimeout;

/** A notification name for when a request will be initiated. */
extern NSString * const WebApiClientRequestWillBeginNotification;

/** A notification name for when a request has been initiated. */
extern NSString * const WebApiClientRequestDidBeginNotification;

/** A notification name for when a request did make progress. */
extern NSString * const WebApiClientRequestDidProgressNotification;

/** A notification name for when the response to a request did make progress. */
extern NSString * const WebApiClientResponseDidProgressNotification;

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

/** A notification user info key for a @c NSProgress object representing the progress of an API endpoint transaction. */
extern NSString * const WebApiClientProgressNotificationKey;

/** The Content-Type for JSON. */
extern NSString * const WebApiClientJSONContentType;

/** The Content-Type for json:api. */
extern NSString * const WebApiClientJSONAPIContentType;

@protocol WebApiResource;

/**
 A block for monitoring the progress of an API request.
 
 @param routeName        The name of the route associated with the progress.
 @param uploadProgress   The upload progress, if any.
 @param downloadProgress The download progress, if any.
 */
typedef void (^WebApiClientRequestProgressBlock)(NSString *routeName, NSProgress * _Nullable uploadProgress, NSProgress * _Nullable downloadProgress);

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
 
 @param name          The name of the API endpoint route to invoke.
 @param pathVariables Optional path variables to replace in the API's route URL.
 @param parameters    Optional request parameters to add to the URL.
 @param data          Optional data to send as the request content.
 @param callback      A callback block to invoke with the response. The callback will be on the main thread.
 
 @return A unique identifier that can be used to monitor the progress of the request, or @c nil if none available.
 */
- (void)requestAPI:(NSString *)name
 withPathVariables:(nullable id)pathVariables
		parameters:(nullable id)parameters
			  data:(nullable id<WebApiResource>)data
		  finished:(void (^)(id<WebApiResponse> _Nullable response, NSError * _Nullable error))callback;

/**
 Request a web API endpoint for a named URL route, using a specific queue for the result callback.
 
 As the request is processed, the various @c WebApiClientRequest* notifications will be sent. For each notification
 the notification object will be the @c WebApiRoute associated with the request. The @c WebApiClientURLRequestNotificationKey
 key will be populated in the notification @c userInfo dictionary with the original @c NSURLRequest.
 
 @param name             The name of the API endpoint route to invoke.
 @param pathVariables    Optional path variables to replace in the API's route URL.
 @param parameters       Optional request parameters to add to the URL.
 @param data             Optional data to send as the request content.
 @param callbackQueue    A queue to use for the callback block.
 @param progressCallback Optional callback block to monitor the progress of the request. The callback will be on the @c callbackQueue.
 @param callback         A callback block to invoke with the response. The callback will be on the @c callbackQueue queue.
 
 @return A unique identifier that can be used to monitor the progress of the request, or @c nil if none available.
 */
- (void)requestAPI:(NSString *)name
 withPathVariables:(nullable id)pathVariables
		parameters:(nullable id)parameters
			  data:(nullable id<WebApiResource>)data
			 queue:(dispatch_queue_t)callbackQueue
		  progress:(nullable WebApiClientRequestProgressBlock)progressCallback
		  finished:(void (^)(id<WebApiResponse> _Nullable response, NSError * _Nullable error))callback;

/**
 Make a synchronous request to a web API endpoint, blocking the calling thread until a response is available
 or a timeout occurs.
 
 Generally the asynchronous @c requestAPI:withPathVariables:parameters:data:finished: is a better option. Use this
 method when you really do need to block the calling thread until a result is available.
 
 @param name          The name of the API endpoint route to invoke.
 @param pathVariables Optional path variables to replace in the API's route URL.
 @param parameters    Optional request parameters to add to the URL.
 @param data          Optional data to send as the request content.
 @param maximumWait   The maximum number of seconds to wait for a response before returning a @c WebApiClientErrorResponseTimeout error.
					  Pass @c 0 to wait forever.
 @param error         Optional error output parameter.
 
 @return The response, or @c nil if a timeout or other error occurs.
 */
- (nullable id<WebApiResponse>)blockingRequestAPI:(NSString *)name
								withPathVariables:(nullable id)pathVariables
									   parameters:(nullable id)parameters
											 data:(nullable id<WebApiResource>)data
									  maximumWait:(NSTimeInterval)maximumWait
											error:(NSError **)error;

/**
 Get all available cookies for a single request or all requests.
 
 @param name      The name of the API endpoint route to get applicable cookies for, or @c nil to get all cookies for all routes.
 @param cookieJar The cookie storage to extract the cookies from. Pass @c nil to use the shared cookie storage provided by the OS.
 
 @return An array of all applicable cookies.
 */
- (NSArray<NSHTTPCookie *> *)cookiesForAPI:(nullable NSString *)name inCookieStorage:(nullable NSHTTPCookieStorage *)cookieJar;

@end

NS_ASSUME_NONNULL_END
