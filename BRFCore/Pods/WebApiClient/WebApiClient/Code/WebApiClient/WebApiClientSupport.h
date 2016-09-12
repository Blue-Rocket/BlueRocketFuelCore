//
//  WebApiClientSupport.h
//  WebApiClient
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "SupportingWebApiClient.h"

@protocol WebApiAuthorizationProvider;
@protocol WebApiDataMapper;
@protocol WebApiErrorExtractor;
@class BREnvironment;

NS_ASSUME_NONNULL_BEGIN

/** The HTTP header name to put the @c appApiKey value in. */
extern NSString * const WebApiClientSupportAppApiKeyDefaultHTTPHeaderName;

/** The HTTP header name to put the @c appId value in. */
extern NSString * const WebApiClientSupportAppIdDefaultHTTPHeaderName;

/**
 An abstract implementation of @c SupportingWebApiClient, for concrete implementations to extend.
 
 This class provides a set of core configuration and utility methods to help actual implementations of @c WebApiClient.
 */
@interface WebApiClientSupport : NSObject <SupportingWebApiClient>

/** A provider of authorization details. */
@property (nonatomic, weak, nullable) id<WebApiAuthorizationProvider> authorizationProvider;

/** A global error extractor. */
@property (nonatomic, strong, nullable) id<WebApiErrorExtractor> errorExtractor;

/** An API key to add as a header value to each request. */
@property (nonatomic, strong, nullable) NSString *appApiKey;

/** The HTTP header name to use for the API key. */
@property (nonatomic, strong) NSString *appApiKeyHTTPHeaderName;

/** An application ID to add as a heder value to each request. */
@property (nonatomic, strong, nullable) NSString *appId;

/** The HTTP header name to use for the application ID. */
@property (nonatomic, strong) NSString *appIdHTTPHeaderName;

/** A set of HTTP header names and associated values to add to every HTTP request. */
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *globalHTTPRequestHeaders;

/**
 Init with a custom environment.
 
 @param environment The environment to use.
 @return The new instance.
 */
- (id)initWithEnvironment:(BREnvironment *)environment NS_DESIGNATED_INITIALIZER;

/**
 Configure default routes in the receiver. Extending classes can override to customize the instance.
 
 @param environment The environment to configure the routes from.
 */
- (void)loadDefaultRoutes:(BREnvironment *)environment;

/**
 Configure the base API URL in the receiver. Extending classes can override to customize the instance.
 
 @param environment The environment to configure the base API URL from.
 @return The base API URL to use.
 */
- (NSURL *)setupBaseApiURL:(BREnvironment *)environment;

/**
 Register a new route.
 
 Extending classes can override this to customize the route registration process, but they should
 invoke this method at some point of their implementation.
 
 @param route The route configuration.
 @param name The name of the route. Names are unique for a given instance @c WebApiClientSupport.
 */
- (void)registerRoute:(id<WebApiRoute>)route forName:(NSString *)name;

/**
 Get a base URL for the routes managed by this client.
 
 @return The base URL, wich is composed of the URL protocol, host, and port.
 */
- (NSURL *)baseApiURL;

/**
 Turn an arbitrary parameters object into a @c NSDictionary.
 
 This implementation will return the @c parameters instance if that is already a dictionary. Otherwise
 it will look at the properties defined on the object and return a dictionary of the values associated
 with those properties.
 
 @param parameters A parameters object, such as a dictionary or arbitrary model object.
 */
- (NSDictionary *)dictionaryForParametersObject:(id)parameters;

/**
 Get a data mapper for a specific route.
 
 @param route The route to get a data mapper for.
 @return The configured data mapper, or @c nil if no data mapper configured for the given route.
 */
- (nullable id<WebApiDataMapper>)dataMapperForRoute:(id<WebApiRoute>)route;

/**
 Add any HTTP request headers configured with a route, plus any global HTTP headers configured on the @c globalHTTPRequestHeaders properties,
 to a given request. If the route defines the same HTTP header name as configured in @c globalHTTPRequestHeaders, the global value will 
 @b not be added to the request.
 
 @b Note this does not add the authorization related headers included by @c addAuthorizationHeadersToRequest:forRoute:.
 
 @param request The request to add the HTTP headers to.
 @param route   The route.
 */
- (void)addRequestHeadersToRequest:(NSMutableURLRequest *)request forRoute:(id<WebApiRoute>)route;

/**
 Add authorization headers to a request for a given route.
 
 This method will populate the @c appApiKeyHTTPHeaderName and @c appIdHTTPHeaderName, if the @c appApiKey and @c appId properties are non-nil.
 If an @c authorizationProvider is configured @c configureAuthorizationForRoute:request: will be invoked.
 
 @param request The request to add headers to.
 @param route The route.
 */
- (void)addAuthorizationHeadersToRequest:(NSMutableURLRequest *)request forRoute:(id<WebApiRoute>)route;

/**
 Find available cookies for a specific route, or all routes.
 
 @param name      The name of the API endpoint route to get applicable cookies for, or @c nil to get all cookies for the @c baseApiURL configured on the receiver.
 @param cookieJar The cookie storage to extract the cookies from. Pass @c nil to use the shared cookie storage provided by the OS.
 
 @return An array of all applicable cookies.
 */
- (NSArray<NSHTTPCookie *> *)cookiesForAPI:(nullable NSString *)name inCookieStorage:(nullable NSHTTPCookieStorage *)cookieJar;

@end

NS_ASSUME_NONNULL_END
