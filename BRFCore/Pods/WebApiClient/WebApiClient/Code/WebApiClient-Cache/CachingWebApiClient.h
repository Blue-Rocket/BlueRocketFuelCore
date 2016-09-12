//
//  CachingWebApiClient.h
//  WebApiClient
//
//  Created by Matt on 24/05/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiClient.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Expands the @c WebApiClient API with additional methods relating to caching.
 
 @since 1.1
 */
@protocol CachingWebApiClient <WebApiClient>

/**
 Request a cached result from a web API endpoint for a named URL route.
 
 This method will only returned cached data. If the response is not available in the cache, then a @c nil
 response is returned, with no error reported.
 
 @param name          The name of the API endpoint route to invoke.
 @param pathVariables Optional path variables to replace in the API's route URL.
 @param parameters    Optional request parameters to add to the URL.
 @param callbackQueue A queue to use for the callback block.
 @param callback      A callback block to invoke with the response. The callback will be on the main thread.
 */
- (void)requestCachedAPI:(NSString *)name
	   withPathVariables:(nullable id)pathVariables
			  parameters:(nullable id)parameters
				   queue:(dispatch_queue_t)callbackQueue
				finished:(void (^)(id<WebApiResponse> _Nullable response, NSError * _Nullable error))callback;

@end

NS_ASSUME_NONNULL_END
