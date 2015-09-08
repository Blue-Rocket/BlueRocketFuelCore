//
//  WebApiClientUserService.m
//  WebApiClientUserService
//
//  Created by Matt on 11/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiClientUserService.h"

#import <BRCocoaLumberjack/BRCocoaLumberjack.h>
#import "BRAppUser.h"

@implementation WebApiClientUserService

- (id)init {
	if ( (self = [super init]) ) {
		self.appUserClass = [BRAppUser class];
	}
	return self;
}

- (id<BRUserRegistration>)newUser {
	return [self.appUserClass new];
}

- (id<BRUser>)activeUser {
	return [self.appUserClass currentUser];
}

- (NSError *)errorForResponse:(id<WebApiResponse>)response error:(NSError *)error {
	NSError *result = error;
	if ( response.statusCode == 422 ) {
		NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:4];
		[userInfo addEntriesFromDictionary:error.userInfo];
		
		// extract server-assigned code and localized message, if available
		id responseObj = response.responseObject;
		NSInteger code = [[responseObj valueForKeyPath:@"code"] integerValue];
		NSString *message = [responseObj valueForKeyPath:@"message"];
		if ( message ) {
			userInfo[NSLocalizedDescriptionKey] = message;
		}
		if ( error ) {
			userInfo[NSUnderlyingErrorKey] = error;
		}
		result = [NSError errorWithDomain:BRServiceValidationErrorDomain code:(code ? code : response.statusCode) userInfo:userInfo];
	}
	return result;
}

- (void)registerNewUser:(id<BRUserRegistration>)newUser finished:(void (^)(id<BRUser>, NSError *))callback {
	void (^doCallback)(id<BRUser>, NSError *) = ^(id<BRUser> user, NSError *error) {
		if ( callback ) {
			callback(user, error);
		}
	};
	
	[self.client requestAPI:WebApiRouteRegister withPathVariables:nil parameters:newUser data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		log4Debug(@"Got register response: %@; error: %@", response, error);
		BRAppUser *user = nil;
		if ( error ) {
			// map into business error, if possible
			error = [self errorForResponse:response error:error];
		} else {
			user = response.responseObject;
			[self.appUserClass replaceCurrentUser:user];
		}
		doCallback(user, error);
	}];
}

- (void)loginWithUserDetails:(id<BRUserRegistration>)userDetails finished:(void (^)(id<BRUser> user, NSError *error))callback {
	void (^doCallback)(id<BRUser>, NSError *) = ^(id<BRUser> user, NSError *error) {
		if ( callback ) {
			callback(user, error);
		}
	};
	[self.client requestAPI:WebApiRouteLogin withPathVariables:nil parameters:userDetails data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		log4Debug(@"Got login response: %@; error: %@", response, error);
		BRAppUser *user = nil;
		if ( error ) {
			// TODO: handle error here, i.e. bad password?
			[[NSNotificationCenter defaultCenter] postNotificationName:BRUserServiceNotificationLoginDidFail object:nil
															  userInfo:@{NSUnderlyingErrorKey : error}];
		} else {
			user = response.responseObject;
			[self.appUserClass replaceCurrentUser:user];
			[[NSNotificationCenter defaultCenter] postNotificationName:BRUserServiceNotificationLoginDidSucceed object:user userInfo:nil];
		}
		doCallback(user, error);
	}];
}

- (void)requestPasswordReset:(NSString *)email  finished:(void (^)(BOOL success, NSError *error))callback {
	void (^doCallback)(BOOL, NSError *) = ^(BOOL success, NSError *error) {
		if ( callback ) {
			callback(success, error);
		}
	};
	id<BRUserRegistration> newUser = [self newUser];
	newUser.email = email;
	[self.client requestAPI:WebApiRouteLogin withPathVariables:nil parameters:newUser data:nil finished:^(id<WebApiResponse> response, NSError *error) {
		log4Debug(@"Got reset password response: %@; error: %@", response, error);
		doCallback((error == nil), error);
	}];
}

- (void)logout {
	[self.appUserClass replaceCurrentUser:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:BRUserServiceNotificationLogoutDidSucceed object:nil userInfo:nil];
}

@end
