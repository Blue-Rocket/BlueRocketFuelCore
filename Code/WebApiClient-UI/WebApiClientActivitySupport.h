//
//  WebApiClientActivitySupport.h
//  BlueRocketFuelCore
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>

/**
 UI support for WebApiClient requests, for example to show an activity view when a request is taking too long.
 */
@interface WebApiClientActivitySupport : NSObject

/** A window to display activity views on. */
@property (nonatomic, weak) UIWindow *window;

/** An interval representing the amount of time a request is allowed to take before it is considered "too slow" and some action should be taken. */
@property (nonatomic) NSTimeInterval requestTooSlowDuration;

@end