//
//  WebApiClientErrorExtractor.h
//  WebApiClient
//
//  Created by Matt on 4/25/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

@protocol WebApiResponse;

NS_ASSUME_NONNULL_BEGIN

/**
 An error @c userInfo key representing an error response object.
 */
extern NSString * const WebApiErrorResponseObjectKey;

/**
 API for extracting a standardized error from a @c WebApiResponse.
 */
@protocol WebApiErrorExtractor <NSObject>

/**
 Extract a standardized error from a response.
 
 This method might be invoked for non-error responses, so should handle those appropriately by returning @c nil. For any returned error, the @c NSLocalizedDescriptionKey should be provided with a localized message, @c NSUnderlyingErrorKey should be set to the passed in @c error parameter. If a specialized error object is needed, it should be set on @c WebApiErrorResponseObjectKey.
 
 @param response The response to extract the error from.
 @param error    An error returned with the response.
 
 @return A standardized error, or @c nil if the response does not constitute an error.
 */
- (nullable NSError *)errorForResponse:(id<WebApiResponse>)response error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
