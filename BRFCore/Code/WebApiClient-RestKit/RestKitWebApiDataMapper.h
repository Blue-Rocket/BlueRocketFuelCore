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

- (void)registerRequestObjectMapping:(RKObjectMapping *)objectMapping forRouteName:(NSString *)name;

- (void)registerResponseObjectMapping:(RKObjectMapping *)objectMapping forRouteName:(NSString *)name;

@end
