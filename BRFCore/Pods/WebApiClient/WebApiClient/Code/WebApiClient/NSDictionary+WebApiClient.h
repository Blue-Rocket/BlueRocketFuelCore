//
//  NSDictionary+WebApiClient.h
//  WebApiClient
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiResponse.h"
#import "WebApiRoute.h"

NS_ASSUME_NONNULL_BEGIN

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
 Extract query parameters from a URL into a dictionary.
 
 @param url                       The URL to extract query parameters from.
 @param urlWithoutQueryParameters An optional pointer to a URL to place a copy of @c url with the query parameters removed.
 
 @return The extracted query parameters, or @c nil if there are none to extract.
 @since 1.1
 */
+ (nullable NSDictionary<NSString *, NSString *> *)dictionaryWithURLQueryParameters:(NSURL *)url url:(NSURL * __autoreleasing _Nullable * _Nullable)urlWithoutQueryParameters;

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
@property (nonatomic, readwrite, nullable) NSString *serializationName;
@property (nonatomic, readwrite, nullable) NSString *contentType;
@property (nonatomic, readwrite, nullable) NSString *dataMapper;
@property (nonatomic, readwrite, getter=isPreventUserInteraction) BOOL preventUserInteraction;
@property (nonatomic, readwrite, getter=isGzip) BOOL gzip;
@property (nonatomic, readwrite, getter=isSaveAsResource) BOOL saveAsResource;
@property (nonatomic, readwrite, nullable) NSDictionary<NSString *, NSString *> *requestHeaders;
@end

/**
 Extension to @c NSMutableDictionary to implement writable properties for web API.
 */
@interface NSMutableDictionary (MutableWebApiResponse)

@property (nonatomic, readwrite) NSString *routeName;
@property (nonatomic, readwrite) NSInteger statusCode;
@property (nonatomic, readwrite, nullable) id responseObject;
@property (nonatomic, readwrite, nullable) NSDictionary *responseHeaders;

/**
 Set an object on the receiver if non-nil, otherwise remove that key.
 
 @param object The object to set, or @c nil to remove any value associated with @c key.
 @param key The key of the object to set or remove.
 */
- (void)setOrRemoveObject:(nullable id)object forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END

