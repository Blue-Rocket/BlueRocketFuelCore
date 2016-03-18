//
//  BRServiceRegistry.h
//  BRFCore
//
//  Created by Matt on 18/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
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
 Get a globally shared instance.
 
 @return The shared instance.
 */
+ (instancetype)sharedRegistry;

@end

NS_ASSUME_NONNULL_END
