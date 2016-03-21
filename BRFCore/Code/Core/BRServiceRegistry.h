//
//  BRServiceRegistry.h
//  BRFCore
//
//  Created by Matt on 18/03/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

@protocol BRUserService;

NS_ASSUME_NONNULL_BEGIN

/**
 Service factory. This class provides a way to access application services that are configured and set
 once when the application starts, but is not tied to a @c UIApplicationDelegate class.
 */
@interface BRServiceRegistry : NSObject

/** The user service to use. */
@property (nonatomic, readonly) id<BRUserService> userService;

/**
 Customize the shared registry class, so can extend with app-specific properties as needed.
 
 @param clazz The class to use, which must be a sub-class of @c BRServiceRegistry.
 */
+ (void)setSharedRegistryClass:(Class)clazz;

/**
 Test if a shared registry exists. This can be useful during application startup.
 
 @return YES if the shared registry has been created.
 */
+ (BOOL)hasSharedRegistry;

/**
 Get a globally shared instance.
 
 @return The shared instance.
 */
+ (instancetype)sharedRegistry;

@end

NS_ASSUME_NONNULL_END
