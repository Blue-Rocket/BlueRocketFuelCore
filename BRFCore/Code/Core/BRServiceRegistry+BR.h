//
//  BRServiceRegistry+BR.h
//  BRFCore
//
//  Created by Matt on 18/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import "BRServiceRegistry.h"

/**
 An extended API for application startup code to use for populating the various services on BRServiceRegistry.
 This category exists to hide the methods not used by the application after it starts up, to keep the API
 as simple as possible.
 */
@interface BRServiceRegistry (BR)

/**
 Set the @c BRUserService to use.
 
 @param userService The user service to use.
 */
- (void)setUserService:(id<BRUserService>)userService;

@end
