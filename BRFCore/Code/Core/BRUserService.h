//
//  BRUserService.h
//  BlueRocketFuelCore
//
//  Created by Matt on 11/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BRUser.h"
#import "BRServiceConstants.h"

/** Error code for when invalid credentials are used. */
extern const NSInteger BRUserServiceErrorInvalidCredentials;

/** Error code when requesting to use an email that is already in use. */
extern const NSInteger BRUserServiceErrorEmailInUse;

/** Notification sent after a login was successful. The object will be the active BRUser instance. */
extern NSString * const BRUserServiceNotificationLoginDidSucceed;

/** Notification sent after a login failed. The `userInfo` dictionary will contain a `NSUnderlyingError` key with the associated NSError. */
extern NSString * const BRUserServiceNotificationLoginDidFail;

/** Notification sent after the user has logged out. */
extern NSString * const BRUserServiceNotificationLogoutDidSucceed;

/**
 API for user services, such as authentication and registration.
 */
@protocol BRUserService <NSObject>

/**
 Get a new user instance to use during registration.
 
 @return A new user instance.
 */
- (id<BRUserRegistration>)newUser;

/**
 Get the active (logged-in) user, or `nil` if no user currently available.
 
 @return The active user, or `nil` if none available.
 */
- (id<BRUser>)activeUser;

/**
 Register and log in as a new user.
 
 @param newUser The new user details to register. This should be an instance previously returned by `newUser:`.
 @param callback The block to invoke with the registration result. The block will be passed the active user if successful, or an error otherwise.
 */
- (void)registerNewUser:(id<BRUserRegistration>)newUser finished:(void (^)(id<BRUser> user, NSError *error))callback;

/**
 Log in with a non-social user account.
 
 @param userDetails The user details, with an appropriate username and password available.
 @param callback The block to invoke with the login result.
 */
- (void)loginWithUserDetails:(id<BRUserRegistration>)userDetails finished:(void (^)(id<BRUser> user, NSError *error))callback;

/**
 Request a password be reset for a given email.
 
 It is assumed that calling this method simply requests some other service to inform the user at the given email address
 about how they can actually reset their password. Thus you cannot assume the user has actually reset their password after the
 callback block is invoked.
 
 @param email The email address of the user to request the password reset for.
 @param callback The block to invoke with the login result.
 */
- (void)requestPasswordReset:(NSString *)email  finished:(void (^)(BOOL success, NSError *error))callback;

/**
 Log out.
 */
- (void)logout;

@end
