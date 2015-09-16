//
//  WebApiDataMapper.h
//  WebApiClient
//
//  Created by Matt on 13/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

@protocol WebApiRoute;

/**
 API for mapping data between native object and serialized forms.
 */
@protocol WebApiDataMapper <NSObject>

/**
 Map a source data object into some domain object.
 
 @param sourceObject The source data, which might be @c NSData, @c NSDictionary, etc.
 @param route The route of the request.
 @param error An optional output error pointer, or @c nil.
 @return The mapped domain object, or @c nil if an error occurs.
 */
- (id)performMappingWithSourceObject:(id)sourceObject route:(id<WebApiRoute>)route error:(NSError *__autoreleasing *)error;

/**
 Encode a domain object into an encoded form, such as @c NSDictionary or @c NSData.
 
 This is the logical reverse of the @ref performMappingWithSourceObject:error: method.
 
 @param domainObject The domain object to encode.
 @param route The route of the request.
 @param error An optional output error pointer, or @c nil.
 @return The serialized representation, or @c nil if an error occurs.
 */
- (id)performEncodingWithObject:(id)domainObject route:(id<WebApiRoute>)route error:(NSError *__autoreleasing *)error;

@end

/**
 API for a singleton data mapper that can return a globally shared instance.
 */
@protocol WebApiSingletonDataMapper <NSObject>

/**
 Get the singleton shared data mapper.
 */
+ (id<WebApiDataMapper>)sharedDataMapper;

@end
