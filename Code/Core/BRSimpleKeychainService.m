//
//  BRSimpleKeychainService.m
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

#import "BRSimpleKeychainService.h"

#import <BRCocoaLumberjack/BRCocoaLumberjack.h>

@implementation BRSimpleKeychainService

+ (instancetype)sharedService {
	static dispatch_once_t onceToken;
	static BRSimpleKeychainService *shared;
	dispatch_once(&onceToken, ^{
		shared = [BRSimpleKeychainService new];
	});
	return shared;
}

- (void)getUsername:(NSString * __autoreleasing *)username password:(NSString * __autoreleasing *)password {
	if ( username ) {
		*username = [self stringValueForKey:BRKeychainServiceKeyUsername];
	}
	if ( password ) {
		*password = [self stringValueForKey:BRKeychainServiceKeyPassword];
	}
}

- (NSString *)keychainAccountForKey:(NSString *)key {
	NSString *ident = [[NSBundle mainBundle] bundleIdentifier];
	if ( !ident ) {
		ident = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
	}
	return (ident ? [ident stringByAppendingFormat:@".%@", key] : key);
}

- (NSString *)stringValueForKey:(NSString *)key {
	NSDictionary *queryDictionary = @{(__bridge id)kSecAttrAccount : [self keychainAccountForKey:key],
									  (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
									  (__bridge id)kSecReturnData : (id)kCFBooleanTrue,
									  (__bridge id<NSCopying>)(kSecAttrAccessible) : (__bridge id)kSecAttrAccessibleWhenUnlocked};
	
	CFDataRef keyDataRef;
	OSStatus errCheck = SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, (CFTypeRef *)&keyDataRef);
	NSString *result = nil;
	if ( errCheck == noErr ) {
		result = [[NSString alloc] initWithData:(NSData *)CFBridgingRelease(keyDataRef) encoding:NSUTF8StringEncoding];
	}
	return result;
}

- (void)setStringValue:(NSString *)value forKey:(NSString *)key {
	NSDictionary *queryDictionary = @{(__bridge id)kSecAttrAccount : [self keychainAccountForKey:key],
									  (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
									  (__bridge id)kSecReturnData : (id)kCFBooleanTrue,
									  (__bridge id<NSCopying>)(kSecAttrAccessible) : (__bridge id)kSecAttrAccessibleWhenUnlocked};
	
	NSDictionary *updateAttributes = ([value length] == 0 ? nil  : @{(__bridge id)kSecValueData : [value dataUsingEncoding:NSUTF8StringEncoding]});
	CFDataRef keyDataRef = NULL;
	OSStatus error = SecItemCopyMatching((__bridge CFDictionaryRef)queryDictionary, (CFTypeRef *)&keyDataRef);
	if ( error == noErr ) {
		if ( [value length] == 0 ) {
			// delete the key if value is nil or empty
			error = SecItemDelete((__bridge CFDictionaryRef)queryDictionary);
			if ( error != noErr ) {
				DDLogError(@"Error deleting keychain entry %@: %d", key, (int)error);
			} else {
				DDLogVerbose(@"Deleted keychain entry %@", key);
			}
		} else {
			error = SecItemUpdate((__bridge CFDictionaryRef)queryDictionary, (__bridge CFDictionaryRef)updateAttributes);
			if ( error != noErr ) {
				DDLogVerbose(@"Error updating keychain entry %@, will try to delete and then add: %d", key, (int)error);
				error = SecItemDelete((__bridge CFDictionaryRef)queryDictionary);
				if ( error != noErr ) {
					DDLogError(@"Error setting keychain entry %@ (update failed, then delete failed): %d", key, (int)error);
				} else {
					DDLogVerbose(@"Deleted keychain entry %@, will now try to add", key);
					NSMutableDictionary *addDictionary = [queryDictionary mutableCopy];
					[addDictionary addEntriesFromDictionary:updateAttributes];
					error = SecItemAdd((__bridge CFDictionaryRef)addDictionary, (CFTypeRef *)&keyDataRef);
					if ( error != noErr ) {
						DDLogError(@"Error adding keychain entry %@ (updated failed, then delete succeeded, then add failed: %d", key, (int)error);
					} else {
						DDLogVerbose(@"Set keychain entry %@ after deleting existing entry and then adding again", key);
					}
				}
			} else {
				DDLogVerbose(@"Updated keychain entry %@", key);
			}
		}
	} else {
		if ( [value length] > 0 ) {
			NSMutableDictionary *addDictionary = [queryDictionary mutableCopy];
			[addDictionary addEntriesFromDictionary:updateAttributes];
			error = SecItemAdd((__bridge CFDictionaryRef)addDictionary, (CFTypeRef *)&keyDataRef);
			if ( error != noErr) {
				DDLogError(@"Error adding keychain entry %@: %d", key, (int)error);
			} else {
				DDLogVerbose(@"Added keychain entry %@", key);
			}
		}
	}
	if ( keyDataRef != NULL ) {
		CFRelease(keyDataRef);
	}
}

@end
