//
//  Created by Shawn McKee on 1/21/15.
//
//  Copyright (c) 2015 Blue Rocket, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "BRUser.h"

extern NSString * const BREnvironmentKeyPasswordMinLength;

@protocol BRKeychainService;

@interface BRAppUser : NSObject <BRUser, BRUserRegistration>

@property (nonatomic, strong) NSString *authenticationToken;

@property (nonatomic, strong) NSString *uniqueId;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *passwordAgain;

- (void)initializeWithDictionary:(NSDictionary *)dictionary;

/**
 Persist user details so they can be restored later via @c load.
 
 @param userDefaults The user defaults to save non-secure preferences to. If not provided, the standard user defaults will be used.
 @param keychain The keychain service to save secure preferences to. If not provided, the shared keychain service will be used.
 */
- (void)saveToUserDefaults:(NSUserDefaults *)userDefaults keychain:(id<BRKeychainService>)keychain;

/**
 Load any previously saved details.
 
 @param userDefaults The user defaults to load non-secure preferences from. If not provided, the standard user defaults will be used.
 @param keychain The keychain service to load secure preferences from. If not provided, the shared keychain service will be used.
 */
- (void)loadFromUserDefaults:(NSUserDefaults *)userDefaults keychain:(id<BRKeychainService>)keychain;

#pragma mark - Persistence support

/**
 Persist or delete a preference for a key.
 
 @param value        The preference object to persist. If @c nil or @c NSNull, delete any persisted value for the given key.
 @param key          The unique key to persist the preference as.
 @param userDefaults The user defaults to persist to. If not provided, the standard user defaults will be used.
 */
+ (void)setPreferencesValue:(id)value forKey:(NSString *)key inUserDefaults:(NSUserDefaults *)userDefaults;

/**
 Read a persisted perference object.
 
 @param key The key of the preference to read.
 
 @return The preference value, or @c nil if not available.
 */
+ (id)preferencesValueForKey:(NSString *)key inUserDefaults:(NSUserDefaults *)userDefaults;

/**
 Securely persist or delete a preference for a key.
 
 @param value The preference object to persist. If @c nil, delete any persisted value for the given key.
 @param key   The unique key to persist the preference as.
 @param keychain The keychain service to persist to. If not provided, the shared keychain service will be used.
 */
+ (void)setSecurePreferencesValue:(NSString *)value forKey:(NSString *)key inKeychain:(id<BRKeychainService>)keychain;

/**
 Read a persisted perference object stored via @c setSecurePreferencesValue:forKey.
 
 @param key      The key of the preference to read.
 @param keychain The keychain service to persist to. If not provided, the shared keychain service will be used.
 
 @return The preference value, or @c nil if not available.
 */
+ (id)securePreferencesValueForKey:(NSString *)key inKeychain:(id<BRKeychainService>)keychain;

@end
