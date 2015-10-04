//
//  NSDictionary+WebApiClient.h
//  WebApiClient
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiResponse.h"
#import "WebApiRoute.h"

/**
 Extension to @c NSDictionary to implement some web API support.
 */
@interface NSDictionary (WebApiClient) <WebApiRoute, WebApiResponse>

/**
 Encode the keys and values as a URL query string, e.g. foo=bar&bam=baz.
 
 @return A string suitable for using as the query component of a URL.
 */
- (NSString *)asURLQueryParameterString;

/**
 Transform a serialization enum into a string.
 
 @param serialization The serialization enum to transform.
 @return A string value for the enum.
 */
 + (NSString *)nameForWebApiSerialization:(WebApiSerialization)serialization;

/**
 Transform a serialization name into an enum value.
 
 @param string The serialization name to transform. This must be a valid string as returned from nameForWebApiSerialization:.
 @return An enum value.
 */
 + (WebApiSerialization)webApiSerializationForName:(NSString *)string;
 
@end

/**
 Extension to @c NSMutableDictionary to implement writable properties for web API.
 */
@interface NSMutableDictionary (MutableWebApiRoute)

@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSString *path;
@property (nonatomic, readwrite) NSString *method;
@property (nonatomic, readwrite) WebApiSerialization serialization;
@property (nonatomic, readwrite) NSString *serializationName;
@property (nonatomic, readwrite) NSString *contentType;
@property (nonatomic, readwrite) NSString *dataMapper;
@property (nonatomic, readwrite, getter=isPreventUserInteraction) BOOL preventUserInteraction;

@end

/**
 Extension to @c NSMutableDictionary to implement writable properties for web API.
 */
@interface NSMutableDictionary (MutableWebApiResponse)

@property (nonatomic, readwrite) NSString *routeName;
@property (nonatomic, readwrite) NSInteger statusCode;
@property (nonatomic, readwrite) id responseObject;
@property (nonatomic, readwrite) NSDictionary *responseHeaders;

/**
 Set an object on the receiver if non-nil, otherwise remove that key.
 
 @param object The object to set, or @c nil to remove any value associated with @c key.
 @param key The key of the object to set or remove.
 */
- (void)setOrRemoveObject:(id)object forKey:(NSString *)key;

@end
