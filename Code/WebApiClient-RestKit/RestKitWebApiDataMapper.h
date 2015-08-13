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

extern NSString * const RestKitWebApiRoutePropertyRootKeyPath;

/**
 A @c WebApiDataMapper that uses RestKit to handle data mapping to/from native objects.
 
 A single shared instance of this class
 */
@interface RestKitWebApiDataMapper : NSObject <WebApiDataMapper, WebApiSingletonDataMapper>

/**
 Get a single, globally shared instance of this mapper.
 */
+ (instancetype)sharedDataMapper;

- (void)registerRequestObjectMapping:(RKObjectMapping *)objectMapping forRoutePath:(NSString *)path;

- (void)registerResponseObjectMapping:(RKObjectMapping *)objectMapping forRoutePath:(NSString *)path;

@end
