//
//  SupportingWebApiClient.h
//  BRFCore
//
//  Created by Matt on 15/09/15.
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiClient.h"

NS_ASSUME_NONNULL_BEGIN

/**
 API for a WebApiClient with extended attributes, geared for implementation support.
 */
@protocol SupportingWebApiClient <WebApiClient>

/**
 Get a registered route by its name.
 
 The WebApiClient API does not specify how routes are registered.
 
 @param name  The name of the route to get.
 @param error An error if the route is not registered. Pass @c nil if you don't need the error.
 The localized message @c web.api.missingRoute will be returned.
 @return The route associated with @c name, or @c nil if not registered.
 */
- (nullable id<WebApiRoute>)routeForName:(NSString *)name error:(NSError * __nullable __autoreleasing *)error;

/**
 Get a @c URL instance for a route.
 
 @param route The route.
 @param pathVariables An optional path variables object. All path variables will be resolved against this object.
 @param parameters An optional parameters object to encode as the query component of the request URL.
 @param error An error if the route has no associated path. Pass @c nil if you don't need the error.
 The localized message @c web.api.missingRoutePath will be returned.
 @return The URL instance.
 */
- (NSURL *)URLForRoute:(id<WebApiRoute>)route
		 pathVariables:(nullable id)pathVariables
			parameters:(nullable id)parameters
				 error:(NSError * __autoreleasing *)error;

@end

NS_ASSUME_NONNULL_END
