//
//  WebApiClientActivitySupport.h
//  WebApiClient
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>

/**
 UI support for WebApiClient requests, for example to show an activity view when a request is taking too long.
 
 This class for listen for @c WebApiClientRequestWillBeginNotification notifications. If the @c WebApiRoute
 included in the notification has @c preventUserInteraction set to @c YES and the client request does not 
 complete within the configured @c requestTooSlowDuration, a full-screen view with an activity indicator
 and message will be inserted into the configured @c window and remain until the client request completes.
 */
@interface WebApiClientActivitySupport : NSObject

/** A window to display activity views on. */
@property (nonatomic, weak) UIWindow *window;

/** An interval representing the amount of time a request is allowed to take before it is considered "too slow" and some action should be taken. */
@property (nonatomic) NSTimeInterval requestTooSlowDuration;

@end
