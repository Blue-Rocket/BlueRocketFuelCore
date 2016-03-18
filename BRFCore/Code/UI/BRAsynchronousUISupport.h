//
//  BRAsynchronousUISupport.h
//  BRFCore
//
//  Created by Matt on 18/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Protocol for an object that supports updates to the UI in response to asynchronous operations.
 */
@protocol BRAsynchronousUISupport <NSObject>

@optional

/**
 Make the UI disabled in some way in preparation for an asyncronous call.
 */
- (void)disableForAsynchronousCall;

/**
 Make the UI enabled in some way in follow up to a previous call to @c disableForAsynchronousCall.
 */
- (void)enableFromAsynchronousCall;

@end
