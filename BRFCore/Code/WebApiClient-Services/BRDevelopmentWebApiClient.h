//
//  BRDevelopmentWebApiClient.h
//  BRFCore
//
//  Created by Matt on 12/09/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import <WebApiClient/WebApiClientSupport.h>

NS_ASSUME_NONNULL_BEGIN

/**
 WebApiClient for use during development. Returns static content for routes in a @c MockData directory in the main bundle by default. Designed to be extended for app-specific handling.
 */
@interface BRDevelopmentWebApiClient : WebApiClientSupport

/**
 Get a direct response object for a route request. This method will be called during request processing. If it does @b not return a @c nil value, that object will be used as the response object of the request. If it returns a @c nil value, the @c responseObjectForRoute:pathVariables:parameters:data: method will be called.
 
 This implementation returns @c nil, and is designed for extending classes to override.
 
 @param route         The active route.
 @param pathVariables Any path variables passed with the request.
 @param parameters    Any parameters passed with the request.
 @param data          Any data passed with the request.
 
 @return An object to use for the response, or @c nil if @c responseObjectForRoute:pathVariables:parameters:data: should be called.
 */
- (nullable id)responseObjectForRoute:(id<WebApiRoute>)route pathVariables:(id)pathVariables parameters:(id)parameters data:(id<WebApiResource>)data;

/**
 Get the path of a resource to load and return as the response object. This method will be called during request processing, but only after responseObjectForRoute:pathVariables:parameters:data: returns @c nil.
 
 This implementation looks for a JSON resource in the directory returned by @c resourceDirectoryPath, named after the @c route.name value with a @c json extension.
 
 @param route         The active route.
 @param pathVariables Any path variables passed with the request.
 @param parameters    Any parameters passed with the request.
 @param data          Any data passed with the request.
 
 @return The path to a resource to return, or @c nil for no response data.
 */
- (nullable NSString *)resourcePathForRoute:(id<WebApiRoute>)route pathVariables:(id)pathVariables parameters:(id)parameters data:(id<WebApiResource>)data;

/**
 The directory path to load static data resources from. Defaults to @c MockData.
 
 @return The resource data directory path.
 */
- (NSString *)resourceDirectoryPath;

/**
 Return a random resource from a list of resources matching a file name prefix. The directory returned by @c resourceDirectoryPath will be queried, and a random selection from the list of files starting with @c baseName will be returned.
 
 @param baseName  The file name prefix to include in the random list.
 @param extension The file extension to restrict the file selection to.
 
 @return The path to a random resource matching the provided arguments, or @c nil if there are no matching files.
 */
- (nullable NSString *)randomResourceWithPrefix:(NSString *)baseName extension:(NSString *)extension;

/**
 Get a rate, in bytes per second, to throttle the response data by. This method will be called during request processing. If it returns a value greater than @c 0 the response stream will be throttled by the given rate. This can be useful for unit testing progress callbacks, for example.
 
 This implementation returns the @c BREnvironment value for the key @c Mock-Client-Throttle.
 
 @param route         The active route.
 @param pathVariables Any path variables passed with the request.
 @param parameters    Any parameters passed with the request.
 @param data          Any data passed with the request.
 
 @return The rate to throttle the response by, or @c nil for no throttle.
 */
- (nullable NSNumber *)throttleRateForRoute:(id<WebApiRoute>)route pathVariables:(id)pathVariables parameters:(id)parameters data:(id<WebApiResource>)data;

@end

NS_ASSUME_NONNULL_END
