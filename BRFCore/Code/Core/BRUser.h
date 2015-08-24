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

@property (nonatomic, readonly) NSString *firstName;
@property (nonatomic, readonly) NSString *lastName;
@property (nonatomic, readonly) NSString *email;
@property (nonatomic, readonly) NSString *authenticationToken;

/**
 Get the current user. This may return an anonymous user (non-authenticated) or @c nil.
 
 @return The current user instance.
 */
+ (instancetype)currentUser;

/**
 Set the current user to a new instance.
 
 @param theUser The new user instance, or @c nil to clear the current user.
 */
+ (void)replaceCurrentUser:(id<BRUser>)theUser;

@end

#pragma mark -

/**
 API for a user for registration purposes.
 */
@protocol BRUserRegistration <BRUser>

@property (nonatomic, readwrite) NSString *firstName;
@property (nonatomic, readwrite) NSString *lastName;
@property (nonatomic, readwrite) NSString *email;

@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *passwordAgain;

// the various validateX methods return a localized error message if the associated property X is not valid

- (NSString *)validateEmail;
- (NSString *)validateFirstName;
- (NSString *)validateLastName;
- (NSString *)validatePassword;
- (NSString *)validatePasswordAgain;

@end
