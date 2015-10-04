//
//  WebApiClientUserService.m
//  WebApiClientUserService
//
//  Created by Matt on 11/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiClientUserService.h"

#import <BRCocoaLumberjack/BRCocoaLumberjack.h>
#import <BREnvironment/BREnvironment.h>
#import "BRAppUser.h"

NSString * const WebApiRouteRegister = @"register";
NSString * const WebApiRouteLogin = @"login";
NSString * const WebApiRouteGetUser = @"user";
NSString * const WebApiRouteUpdateUser = @"userUpdate";

@implementation WebApiClientUserService

- (id)init {
	if ( (self = [super init]) ) {
		self.appUserClass = [BRAppUser class];
		self.internalHostNames = [NSSet setWithObject:[BREnvironment sharedEnvironment][WebApiClientSupportServerHostEnvironmentKey]];
	}
	return self;
}

- (id<BRUserRegistration>)newUser {
	return [self.appUserClass new];
}

- (id<BRUser>)activeUser {
	return [self.appUserClass currentUser];
}

#pragma mark - WebApiAuthorizationProvider

- (void)configureAuthorizationForRoute:(id<WebApiRoute>)route request:(NSMutableURLRequest *)request {
	BOOL include = YES;
	if ( self.includeAuthorizationOnExternalRequests == NO ) {
		// check if external request or not
		include = [self.internalHostNames containsObject:request.URL.host];
	}
	if ( include ) {
		id<BRUser> activeUser = [self activeUser];
		if ( activeUser.authenticated ) {
			// toss in a standard auth token header
			[request setValue:[NSString stringWithFormat:@"token %@", activeUser.authenticationToken] forHTTPHeaderField:@"Authorization"];
		}
	}
}

#pragma mark - Public API

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

- (void)registerNewUser:(id<BRUserRegistration>)newUser finished:(void (^)(id<BRUser> _Nullable, NSError * _Nullable))callback {
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

- (void)loginWithUserDetails:(id<BRUserRegistration>)userDetails finished:(void (^)(id<BRUser> _Nullable, NSError * _Nullable))callback {
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

- (void)updateUserDetails:(id<BRUserRegistration>)userDetails finished:(nullable void (^)(id<BRUser> _Nullable, NSError * _Nullable))callback {
	void (^doCallback)(id<BRUser>, NSError *) = ^(id<BRUser> user, NSError *error) {
		if ( callback ) {
			callback(user, error);
		}
	};
	NSString *userId = userDetails.uniqueId;
	NSDictionary *params = @{ @"userId" : (userId ? userId : [NSNull null]) };
	[self.client requestAPI:WebApiRouteUpdateUser withPathVariables:params parameters:userDetails data:nil finished:^(id<WebApiResponse>  _Nonnull response, NSError * _Nullable error) {
		BRAppUser *user = nil;
		if ( !error ) {
			user = response.responseObject;
		}
		if ( user ) {
			[self.appUserClass replaceCurrentUser:user];
			[[NSNotificationCenter defaultCenter] postNotificationName:BRUserServiceNotificationUserDetailsDidChange object:user userInfo:nil];
		}
		doCallback([self activeUser], error);
	}];
}

- (void)fetchUserDetails:(const BOOL)update finished:(nullable void (^)(id<BRUser> _Nullable, NSError * _Nullable))callback {
	void (^doCallback)(id<BRUser>, NSError *) = ^(id<BRUser> user, NSError *error) {
		if ( callback ) {
			callback(user, error);
		}
	};
	id<BRUser> activeUser = [self activeUser];
	NSString *userId = activeUser.uniqueId;
	NSDictionary *params = @{ @"userId" : (userId ? userId : [NSNull null]) };
	[self.client requestAPI:WebApiRouteGetUser withPathVariables:params parameters:nil data:nil finished:^(id<WebApiResponse>  _Nonnull response, NSError * _Nullable error) {
		id<BRUser> user = nil;
		if ( !error ) {
			user = response.responseObject;
		}
		if ( user && update && [user isDifferentFrom:activeUser] ) {
			log4Debug(@"User details fetched from server differ from local cached copy: updating with server values.");
			[self.appUserClass replaceCurrentUser:user];
			[[NSNotificationCenter defaultCenter] postNotificationName:BRUserServiceNotificationUserDetailsDidChange object:user userInfo:nil];
		}
		doCallback(user, error);
	}];
}

- (void)requestPasswordReset:(NSString *)email  finished:(void (^)(BOOL, NSError * _Nullable))callback {
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
	
	// clear out any cookies associated with our client
	NSHTTPCookieStorage *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
	for ( NSHTTPCookie *cookie in [self.client cookiesForAPI:nil inCookieStorage:cookies] ) {
		[cookies deleteCookie:cookie];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:BRUserServiceNotificationLogoutDidSucceed object:nil userInfo:nil];
}

@end
