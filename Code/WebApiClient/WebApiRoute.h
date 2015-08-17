//
//  WebApiRoute.h
//  BlueRocketFuelCore
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

/**
 Types of serialization to use for requests.
 */
typedef enum : NSUInteger {
	/** Serialize into the HTTP body as @c application/json JSON encoded data. */
	WebApiSerializationJSON = 0,
	
	/** Serialize into URL query parameters for @c GET, @c HEAD, @c DELETE requests, or into the HTTP body for other requests. */
	WebApiSerializationURL	= 1,
	
	/** Serialize into the HTTP body as @c multipart/form-data. */
	WebApiSerializationForm = 2,
	
	/** Send raw data in the HTTP body. */
	WebApiSerializationNone = 3,
} WebApiSerialization;

/** A standard route name for user registration. */
extern NSString * const WebApiRouteRegister;

/** A standard route name for user login. */
extern NSString * const WebApiRouteLogin;

/**
 An API route configuration object.
 */
@protocol WebApiRoute <NSObject>

/** The name to use for this route.*/
@property (nonatomic, readonly) NSString *name;

/** The path to use for this route. */
@property (nonatomic, readonly) NSString *path;

/** The HTTP method to use for this route. */
@property (nonatomic, readonly) NSString *method;

/** The parameter serialization to use for this route. */
@property (nonatomic, readonly) WebApiSerialization serialization;

/** A specific MIME type to use for the HTTP @c Content-Type header, or for multi-part requests for the data body part. */
@property (nonatomic, readonly) NSString *contentType;

/** The name of a @c WebApiDataMapper to use for mapping the request parameters from/to native objects. */
@property (nonatomic, readonly) NSString *dataMapper;

/** Flag to indicate that while this API endpoint is being called, no user interaction should be allowed. */
@property (nonatomic, readonly, getter=isPreventUserInteraction) BOOL preventUserInteraction;

/**
 Get a route property by keyed subscript.
 
 @param key The key of the object to get.
 @return The associated value, or @nil if not available.
 */
- (id)objectForKeyedSubscript:(id)key;

@end

@protocol MutableWebApiRoute <WebApiRoute>

/**
 Set a route property.
 
 @param obj The object to set.
 @param key The property to set the object for.
 */
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

@end
