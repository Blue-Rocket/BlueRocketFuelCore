//
//  BRKeychainService.h
//  BlueRocketFuelCore
//
//  Created by Matt on 11/08/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
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

#import <Foundation/Foundation.h>

/** A keychain key to store a username in. */
extern NSString * const BRKeychainServiceKeyUsername;

/** A keychain key to store a password in. */
extern NSString * const BRKeychainServiceKeyPassword;

/**
 API for a service to get/set simple values in the OS keychain.
 */
@protocol BRKeychainService <NSObject>

/**
 Get a string value from the keychain for a given key.
 
 @param key The key to the the value for.
 @return The found, decrypted value, or @c nil if not found.
 */
- (NSString *)stringValueForKey:(NSString *)key;

/**
 Set a string value in the keychain for a given key.
 
 @param value The value to set. Pass @c nil or an empty value to remove the key from the keychain.
 @param key The key to set.
 */
- (void)setStringValue:(NSString *)value forKey:(NSString *)key;

/**
 Get a username and password pair, previously set via setStringValue:forKey: using the @c BRKeychainServiceKeyUsername and @c BRKeychainServiceKeyPassword constants.
 
 @param username A pointer to return the username to.
 @param password A pointer to return the password to.
 */
- (void)getUsername:(NSString * __autoreleasing *)username password:(NSString * __autoreleasing *)password;

@end
