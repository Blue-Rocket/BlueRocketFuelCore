//
//  BRUserService.m
//  BlueRocketFuelCore
//
//  Created by Matt on 11/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BRUserService.h"

const NSInteger BRUserServiceErrorInvalidCredentials = 40000;
const NSInteger BRUserServiceErrorEmailInUse = 40001;

NSString * const BRUserServiceNotificationLoginDidSucceed = @"UserServiceLoginDidSucceed";
NSString * const BRUserServiceNotificationLoginDidFail = @"UserServiceLoginDidFail";
NSString * const BRUserServiceNotificationLogoutDidSucceed = @"UserServiceLogoutDidSucceed";
NSString * const BRUserServiceNotificationUserDetailsDidChange = @"UserServiceUserDetailsDidChange";
