//
//  WebApiClientUserService.h
//  WebApiClientUserService
//
//  Created by Matt on 11/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <WebApiClient/WebApiClient-Core.h>
#import "BRUserService.h"

NS_ASSUME_NONNULL_BEGIN

/** A standard route name for user registration. */
extern NSString * const WebApiRouteRegister;

/** A standard route name for user login. */
extern NSString * const WebApiRouteLogin;

/** A standard route name for requesting a password to be reset. */
extern NSString * const WebApiRouteResetPassword;

/** A standard route name for getting a user profile (account details). */
extern NSString * const WebApiRouteGetUser;

/** A standard route name for updating a user profile (account details). */
extern NSString * const WebApiRouteUpdateUser;

/** A BREnvironment key for a "return URL" to include in the password reset parameters. */
extern NSString * const WebApiClientUserServiceResetPasswordReturnURLEnvironmentKey;

/**
 Implementation of @c BRUserService using @c WebApiClient for login and registration requests.
 
 This class also conforms to @c WebApiAuthorizationProvider so that it can act as an authentication
 provider for client requests. When @c configureAuthorizationForRoute:request: is called to authorize
 a request, the active user's @c authenticationToken will be added to the request as a HTTP header.
 The HTTP header defaults to
 
     Authorization Token token="123"
 
 where @b 123 is the @c authenticationToken value. The header name and value can be configured via
 the @c authenticationTokenHeaderName and @c authenticationTokenHeaderTemplate properties.
 */
@interface WebApiClientUserService : NSObject <BRUserService, WebApiAuthorizationProvider>

/** The class of the app user; must conform to @c BRUserRegistration. This defaults to @c BRAppUser. */
@property (nonatomic, strong) Class appUserClass;

/** The @c WebApiClient implementation to use. */
@property (nonatomic, strong) id<WebApiClient> client;

/**
 Flag to enable including the API authorization header for requests that are not included in the
 @c internalHostNames property when responding to @c WebApiAuthorizationProvider methods.
 */
@property (nonatomic, assign, getter=isIncludeAuthorizationOnExternalRequests) BOOL includeAuthorizationOnExternalRequests;

/**
 A set of host names that are considered @i internal, when @c includeAuthorizationOnExternalRequests is @c NO.
 Defaults to host specified in the @c BREnvironment key @c WebApiClientSupportServerHostEnvironmentKey.
 */
@property (nonatomic, strong) NSSet<NSString *> *internalHostNames;

/**
 The HTTP header name to use for posting the user authentication token. Defaults to @c Authorization.
 Set to @c nil to omit the authentication token header entirely.
 */
@property (nonatomic, strong, nullable) NSString * authenticationTokenHeaderName;

/**
 A string template for formatting the authentication token HTTP header value. The template must accept a single
 object parameter, which will be passed the active user's @c authenticationToken value.
 
 Defaults to `"Token token="%@"`. If @c nil then the raw token value will be used directly as the header value.
 */
@property (nonatomic, strong, nullable) NSString * authenticationTokenHeaderTemplate;

@end

NS_ASSUME_NONNULL_END
