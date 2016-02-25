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

#import "BRAppUser.h"

#import <BREnvironment/BREnvironment.h>
#import <BRLocalize/Core.h>
#import "BRSimpleKeychainService.h"
#import "NSString+BR.h"

NSString * const BREnvironmentKeyPasswordMinLength = @"validation.password.minLength";

static NSString *const BRAppUserRecordIdPreference = @"BRAppUserRecordIdPreference";
static NSString *const BRAppUserTypePreference = @"BRAppUserTypePreference";
static NSString *const BRAppUserNamePreference = @"BRAppUserNamePreference";
static NSString *const BRAppUserFirstNamePreference = @"BRAppUserFirstNamePreference";
static NSString *const BRAppUserLastNamePreference = @"BRAppUserLastNamePreference";
static NSString *const BRAppUserWebsitePreference = @"BRAppUserWebsitePreference";
static NSString *const BRAppUserPhonePreference = @"BRAppUserPhonePreference";
static NSString *const BRAppUserAddressPreference = @"BRAppUserAddressPreference";
static NSString *const BRAppUserAuthenticationTokenPreference = @"BRAppUserAuthenticationTokenPreference";

static id CurrentUser;

@implementation BRAppUser {
	id<BRKeychainService> keychainService;
}

@synthesize keychainService;

+ (instancetype)currentUser {
	return [self currentUserFromUserDefaults:nil keychain:nil];
}

+ (instancetype)currentUserFromUserDefaults:(NSUserDefaults *)userDefaults keychain:(id<BRKeychainService>)keychain {
	static dispatch_once_t pred = 0;
	dispatch_once(&pred, ^{
		BRAppUser *user = [[self alloc] init];
		[user loadFromUserDefaults:userDefaults	keychain:keychain];
		CurrentUser = user;
	});
	return CurrentUser;
}

+ (void)replaceCurrentUser:(BRAppUser *)theUser {
	[self replaceCurrentUser:theUser inUserDefaults:nil keychain:nil];
}

+ (void)replaceCurrentUser:(id<BRUser>)theUser inUserDefaults:(NSUserDefaults *)userDefaults keychain:(id<BRKeychainService>)keychain {
	NSParameterAssert(theUser == nil || [theUser isKindOfClass:[self class]]);
	CurrentUser = theUser;
	if ( !userDefaults ) {
		userDefaults = [NSUserDefaults standardUserDefaults];
	}
	if ( !keychain ) {
		keychain = [BRSimpleKeychainService sharedService];
	}
	if ( theUser == nil ) {
		[@[BRAppUserRecordIdPreference, BRAppUserTypePreference, BRAppUserNamePreference, BRAppUserFirstNamePreference, BRAppUserLastNamePreference] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[userDefaults removeObjectForKey:obj];
		}];
		[userDefaults synchronize];
		[@[BRAppUserAuthenticationTokenPreference, BRKeychainServiceKeyPassword, BRKeychainServiceKeyUsername] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[keychain setStringValue:nil forKey:(NSString *)obj];
		}];
	} else {
		[(BRAppUser *)theUser saveToUserDefaults:userDefaults keychain:keychain];
	}
}

- (BOOL)isDifferentFrom:(id<BREntity>)other {
	if ( [other isKindOfClass:[self class]] == NO ) {
		// not same class: immediately result in YES
		return YES;
	}
	return [self isDifferentFromBRAppUser:(BRAppUser *)other];
}

#define ObjectPropertiesSame(prop) ((self.prop == nil && other.prop == nil) || (self.prop != nil && [self.prop isEqual:other.prop]))

- (BOOL)isDifferentFromBRAppUser:(BRAppUser *)other {
	return ((ObjectPropertiesSame(uniqueId)
			 && ObjectPropertiesSame(type)
			 && ObjectPropertiesSame(email)
			 && ObjectPropertiesSame(firstName)
			 && ObjectPropertiesSame(lastName)
			 && ObjectPropertiesSame(name)
			 && ObjectPropertiesSame(phone)
			 && ObjectPropertiesSame(website)
			 && ObjectPropertiesSame(address)) == NO);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
	BRAppUser *copy = [[[self class] allocWithZone:zone] init];
	copy.uniqueId = self.uniqueId;
	copy.type = self.type;
	copy.email = self.email;
	copy.name = self.name;
	copy.firstName = self.firstName;
	copy.lastName = self.lastName;
	copy.phone = self.phone;
	copy.website = self.website;
	copy.address = self.address;
	return copy;
}

#pragma mark -

- (void)initializeWithDictionary:(NSDictionary *)dictionary {
    self.uniqueId = [NSString stringWithFormat:@"%lu",[[dictionary objectForKey:@"id"] unsignedLongValue]];
    self.email = [dictionary objectForKey:@"email"];
    self.name = [dictionary objectForKey:@"name"];
    self.firstName = [dictionary objectForKey:@"first_name"];
    self.lastName = [dictionary objectForKey:@"last_name"];
    self.phone = [dictionary objectForKey:@"phone"];
    self.website = [dictionary objectForKey:@"website"];
    self.address = [dictionary objectForKey:@"address"];
    if ([dictionary objectForKey:@"password"]) self.password = [dictionary objectForKey:@"password"];
    if ([dictionary objectForKey:@"token"]) self.authenticationToken = [dictionary objectForKey:@"token"];
}

- (void)clear {
    self.uniqueId = nil;
    self.type = nil;
    self.email = nil;
    self.name = nil;
    self.firstName = nil;
    self.lastName = nil;
    self.password = nil;
    self.website = nil;
    self.address = nil;
    self.phone = nil;
    self.authenticationToken = nil;
}

- (void)saveToUserDefaults:(NSUserDefaults *)userDefaults keychain:(id<BRKeychainService>)keychain {
	if ( keychain ) {
		keychainService = keychain;
	} else {
		keychain = keychainService;
	}
	[BRAppUser setPreferencesValue:self.uniqueId forKey:BRAppUserRecordIdPreference inUserDefaults:userDefaults];
	[BRAppUser setPreferencesValue:self.type forKey:BRAppUserTypePreference inUserDefaults:userDefaults];
	[BRAppUser setPreferencesValue:self.name forKey:BRAppUserNamePreference inUserDefaults:userDefaults];
	[BRAppUser setPreferencesValue:self.firstName forKey:BRAppUserFirstNamePreference inUserDefaults:userDefaults];
	[BRAppUser setPreferencesValue:self.lastName forKey:BRAppUserLastNamePreference inUserDefaults:userDefaults];
	[BRAppUser setPreferencesValue:self.website forKey:BRAppUserWebsitePreference inUserDefaults:userDefaults];
	[BRAppUser setPreferencesValue:self.phone forKey:BRAppUserPhonePreference inUserDefaults:userDefaults];
	[BRAppUser setPreferencesValue:self.address forKey:BRAppUserAddressPreference inUserDefaults:userDefaults];
	if ( _email ) {
		[BRAppUser setSecurePreferencesValue:_email forKey:BRKeychainServiceKeyUsername inKeychain:keychain];
		if ( self == CurrentUser ) {
			_email = nil;
		}
	}
	if ( _authenticationToken ) {
		[BRAppUser setSecurePreferencesValue:_authenticationToken forKey:BRAppUserAuthenticationTokenPreference inKeychain:keychain];
		if ( self == CurrentUser ) {
			_authenticationToken = nil;
		}
	}
	if ( _password ) {
		[BRAppUser setSecurePreferencesValue:_password forKey:BRKeychainServiceKeyPassword inKeychain:keychain];
		if ( self == CurrentUser ) {
			_password = nil;
		}
	}
	if ( self == CurrentUser ) {
		_passwordAgain = nil;
	}
	[(userDefaults ? userDefaults : [NSUserDefaults standardUserDefaults]) synchronize];
}

- (void)loadFromUserDefaults:(NSUserDefaults *)userDefaults keychain:(id<BRKeychainService>)keychain {
	self.uniqueId = [BRAppUser preferencesValueForKey:BRAppUserRecordIdPreference inUserDefaults:userDefaults];
	self.type = [BRAppUser preferencesValueForKey:BRAppUserTypePreference inUserDefaults:userDefaults];
	self.name = [BRAppUser preferencesValueForKey:BRAppUserNamePreference inUserDefaults:userDefaults];
	self.firstName = [BRAppUser preferencesValueForKey:BRAppUserFirstNamePreference inUserDefaults:userDefaults];
	self.lastName = [BRAppUser preferencesValueForKey:BRAppUserLastNamePreference inUserDefaults:userDefaults];
	self.website = [BRAppUser preferencesValueForKey:BRAppUserWebsitePreference inUserDefaults:userDefaults];
	self.phone = [BRAppUser preferencesValueForKey:BRAppUserPhonePreference inUserDefaults:userDefaults];
	self.address = [BRAppUser preferencesValueForKey:BRAppUserAddressPreference inUserDefaults:userDefaults];
	
	keychainService = keychain; // maintain reference for secure fields
}

- (NSString *)email {
	// fetch from secure storage every time if we are the active user
	return (self == CurrentUser ? [BRAppUser securePreferencesValueForKey:BRKeychainServiceKeyUsername inKeychain:keychainService] : _email);
}

- (NSString *)authenticationToken {
	// fetch from secure storage every time if we are the active user
	return (self == CurrentUser ? [BRAppUser securePreferencesValueForKey:BRAppUserAuthenticationTokenPreference inKeychain:keychainService] : _authenticationToken);
}

- (NSString *)password {
	// fetch from secure storage every time if we are the active user
	return (self == CurrentUser ? [BRAppUser securePreferencesValueForKey:BRKeychainServiceKeyPassword inKeychain:keychainService] : _password);
}

- (BOOL)isNewUser {
    return (self.uniqueId == nil);
}

- (BOOL)isAuthenticated {
    return (self.authenticationToken != nil);
}

#pragma mark - Persistence support

+ (void)setPreferencesValue:(id)value forKey:(NSString *)key inUserDefaults:(NSUserDefaults *)userDefaults {
	if ( !key ) {
		return;
	}
	if ( !userDefaults ) {
		userDefaults = [NSUserDefaults standardUserDefaults];
	}
	if ( [value isKindOfClass:[NSNull class]] ) {
			value = nil;
	}
	if ( !value ) {
		[userDefaults removeObjectForKey:key];
	} else {
		[userDefaults setObject:value forKey:key];
	}
}

+ (id)preferencesValueForKey:(NSString *)key inUserDefaults:(NSUserDefaults *)userDefaults {
	if ( !userDefaults ) {
		userDefaults = [NSUserDefaults standardUserDefaults];
	}
    return [userDefaults objectForKey:key];
}

+ (void)setSecurePreferencesValue:(NSString *)value forKey:(NSString *)key inKeychain:(id<BRKeychainService>)keychain {
	if ( !keychain ) {
		keychain = [BRSimpleKeychainService sharedService];
	}
	[keychain setStringValue:value forKey:key];
}

+ (id)securePreferencesValueForKey:(NSString *)key inKeychain:(id<BRKeychainService>)keychain {
	if ( !keychain ) {
		keychain = [BRSimpleKeychainService sharedService];
	}
	return [keychain stringValueForKey:key];
}

#pragma mark - Validation

- (NSString *)validateEmail {
	if ( [self.email length] < 1 ) {
		return [@"{validation.user.email.missing}" localizedString];
	}
	return ([self.email isValidEmailAddress] ? nil : [@"{validation.user.email.format}" localizedString]);
}

- (NSString *)validateFirstName {
	return ([self.firstName length] > 0 ? nil : [@"{validation.user.firstName.missing}" localizedString]);
}

- (NSString *)validateLastName {
	return ([self.lastName length] > 0 ? nil : [@"{validation.user.lastName.missing}" localizedString]);
}

- (NSString *)validatePhone {
	if ( [self.phone length] < 1 ) {
		return [@"{validation.user.phone.missing}" localizedString];
	}
	return ([self.phone isValidPhoneNumberForLocale:nil] ? nil : [@"{validation.user.phone.format}" localizedString]);
}

- (NSString *)validatePassword {
	NSNumber *minLength = [[BREnvironment sharedEnvironment] numberForKey:BREnvironmentKeyPasswordMinLength];
	return ([self.password length] >= [minLength unsignedIntegerValue] ? nil
			: [NSString stringWithFormat:[@"{validation.user.password.minLength}" localizedString], minLength]);
}

- (NSString *)validatePasswordAgain {
	if ( [self.passwordAgain length] < 1 ) {
		return [@"{validation.user.passwordAgain.missing}" localizedString];
	}
	return ([self.passwordAgain isEqualToString:self.password] ? nil : [@"{validation.user.passwordAgain.mismatch}" localizedString]);
}

@end
