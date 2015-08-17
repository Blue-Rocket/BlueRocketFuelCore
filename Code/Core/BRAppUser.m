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

@implementation BRAppUser

+ (instancetype)currentUser {
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
		CurrentUser = [[self alloc] init];
    });
    return CurrentUser;
}

+ (void)replaceCurrentUser:(BRAppUser *)theUser {
	NSParameterAssert(theUser == nil || [theUser isKindOfClass:[self class]]);
	CurrentUser = theUser;
	if ( theUser == nil ) {
		NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
		[@[BRAppUserRecordIdPreference, BRAppUserTypePreference, BRAppUserNamePreference, BRAppUserFirstNamePreference, BRAppUserLastNamePreference] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[def removeObjectForKey:obj];
		}];
		[def synchronize];
		[@[BRAppUserAuthenticationTokenPreference, BRKeychainServiceKeyPassword, BRKeychainServiceKeyUsername] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			[[BRSimpleKeychainService sharedService] setStringValue:nil forKey:(NSString *)obj];
		}];
	}
}

- (void)initializeWithDictionary:(NSDictionary *)dictionary {
    self.recordId = [NSString stringWithFormat:@"%d",[[dictionary objectForKey:@"id"] intValue]];
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
    self.recordId = nil;
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

#pragma mark - Identification

- (void)setRecordId:(NSString *)recordId {
    [BRAppUser setPreferencesValue:recordId forKey:BRAppUserRecordIdPreference];
}

- (NSString *)recordId {
    return [BRAppUser preferencesValueForKey:BRAppUserRecordIdPreference];
}

- (void)setType:(NSString *)type {
    [BRAppUser setPreferencesValue:type forKey:BRAppUserTypePreference];
}

- (NSString *)type {
    return [BRAppUser preferencesValueForKey:BRAppUserTypePreference];
}


- (void)setName:(NSString *)name {
    [BRAppUser setPreferencesValue:name forKey:BRAppUserNamePreference];
}

- (NSString *)name {
    return [BRAppUser preferencesValueForKey:BRAppUserNamePreference];
}

- (void)setFirstName:(NSString *)firstName {
    [BRAppUser setPreferencesValue:firstName forKey:BRAppUserFirstNamePreference];
}

- (NSString *)firstName {
    return [BRAppUser preferencesValueForKey:BRAppUserFirstNamePreference];
}

- (void)setLastName:(NSString *)lastName {
    [BRAppUser setPreferencesValue:lastName forKey:BRAppUserLastNamePreference];
}

- (NSString *)lastName {
    return [BRAppUser preferencesValueForKey:BRAppUserLastNamePreference];
}

- (void)setEmail:(NSString *)email {
    [BRAppUser setSecurePreferencesValue:email forKey:BRKeychainServiceKeyUsername];
}

- (NSString *)email {
    return [BRAppUser securePreferencesValueForKey:BRKeychainServiceKeyUsername];
}

- (void)setWebsite:(NSString *)website {
    [BRAppUser setPreferencesValue:website forKey:BRAppUserWebsitePreference];
}

- (NSString *)website {
    return [BRAppUser preferencesValueForKey:BRAppUserWebsitePreference];
}

- (void)setPhone:(NSString *)phone {
    [BRAppUser setPreferencesValue:phone forKey:BRAppUserPhonePreference];
}

- (NSString *)phone {
    return [BRAppUser preferencesValueForKey:BRAppUserPhonePreference];
}

- (void)setAddress:(NSString *)address {
    [BRAppUser setPreferencesValue:address forKey:BRAppUserAddressPreference];
}

- (NSString *)address {
    return [BRAppUser preferencesValueForKey:BRAppUserAddressPreference];
}



- (void)setPassword:(NSString *)password {
    [BRAppUser setSecurePreferencesValue:password forKey:BRKeychainServiceKeyPassword];
}

- (NSString *)password {
    return [BRAppUser securePreferencesValueForKey:BRKeychainServiceKeyPassword];
}

#pragma mark - Authentication

- (BOOL)isNewUser {
    return ([BRAppUser preferencesValueForKey:BRAppUserRecordIdPreference] == nil);
}

- (BOOL)isAuthenticated {
    return !([self authenticationToken] == nil);
}

- (void)setAuthenticationToken:(NSString *)authenticationToken {
	[BRAppUser setSecurePreferencesValue:authenticationToken forKey:BRAppUserAuthenticationTokenPreference];
}

- (NSString *)authenticationToken {
    return [BRAppUser securePreferencesValueForKey:BRAppUserAuthenticationTokenPreference];
}

#pragma mark - Preferences Management

+ (void)setPreferencesValue:(id)value forKey:(NSString *)key {
    if ([value isKindOfClass:[NSNull class]]) value = nil;
    if (!key) return;
    if (!value) [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    else [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)preferencesValueForKey:(NSString *)key {
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

+ (void)setSecurePreferencesValue:(NSString *)value forKey:(NSString *)key {
	[[BRSimpleKeychainService sharedService] setStringValue:value forKey:key];
}

+ (id)securePreferencesValueForKey:(NSString *)key {
	return [[BRSimpleKeychainService sharedService] stringValueForKey:key];
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
