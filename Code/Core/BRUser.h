//
//  BRUser.h
//  BlueRocketFuelCore
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BREntity.h"

/**
 Basic API for an application user.
 */
@protocol BRUser <BREntity>

@property (nonatomic, readonly, getter=isNewUser) BOOL newUser;
@property (nonatomic, readonly, getter=isAuthenticated) BOOL authenticated;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *email;

@end

#pragma mark -

/**
 API for a user for registration purposes.
 */
@protocol BRUserRegistration <BRUser>

@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *passwordAgain;

// the various validateX methods return a localized error message if the associated property X is not valid

- (NSString *)validateEmail;
- (NSString *)validateFirstName;
- (NSString *)validateLastName;
- (NSString *)validatePassword;
- (NSString *)validatePasswordAgain;

@end
