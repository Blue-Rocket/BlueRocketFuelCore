//
//  RestKitWebApiDataMapper.h
//  BlueRocketFuelCore
//
//  Created by Matt on 13/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

#import "WebApiDataMapper.h"

@class RKObjectMapping;

typedef id(^RestKitWebApiDataMapperBlock)(id sourceObject, id<WebApiRoute>route, NSError * __autoreleasing *error);

/**
 A WebApiRoute property for a root object property to wrap the encoded request object in. This provides
 a way to wrap the request in a top-level object, for example wrap a @c User object so the request looks
 like @c { "user" : { ... } }.
 */
extern NSString * const RestKitWebApiRoutePropertyRequestRootKeyPath;

/**
 A WebApiRoute property for a root object property to unwrap the decoded request object from. This provides
 a way to unwrap the response in a top-level object, for example unwrap a @c User object from a response
 like @c { "user" : { ... } }.
 */
extern NSString * const RestKitWebApiRoutePropertyResponseRootKeyPath;

/**
 A @c WebApiDataMapper that uses RestKit to handle data mapping to/from native objects.
 
 A single shared instance of this class
 */
@interface RestKitWebApiDataMapper : NSObject <WebApiDataMapper, WebApiSingletonDataMapper>

/**
 Get a single, globally shared instance of this mapper.
 */
+ (instancetype)sharedDataMapper;

/**
 Register an object mapping for use when encoding an object for sending in a request.
 
 @param objectMapping The mapping to register.
 @param name          The route name to register the mapping with.
 */
- (void)registerRequestObjectMapping:(RKObjectMapping *)objectMapping forRouteName:(NSString *)name;

/**
 Register a block to invoke after any object encoding has been performed on a request object.
 
 @param block The block to invoke, which must return the desired final encoded object.
 @param name  The route name to register the mapping with.
 */
- (void)registerRequestMappingBlock:(RestKitWebApiDataMapperBlock)block forRouteName:(NSString *)name;

/**
 Register an object mapping for use when mapping a response to an object.
 
 @param objectMapping The mapping to register.
 @param name          The route name to register the mapping with.
 */
- (void)registerResponseObjectMapping:(RKObjectMapping *)objectMapping forRouteName:(NSString *)name;

/**
 Register a block to invoke after any object mapping has been performed on a response object.
 
 @param block The block to invoke, which must return the desired final mapped object.
 @param name  The route name to register the mapping with.
 */
- (void)registerResponseMappingBlock:(RestKitWebApiDataMapperBlock)block forRouteName:(NSString *)name;

@end
