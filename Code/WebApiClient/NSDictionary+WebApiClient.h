//
//  NSDictionary+WebApiClient.h
//  BlueRocketFuelCore
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

@end

/**
 Extension to @c NSMutableDictionary to implement writable properties for web API.
 */
@interface NSMutableDictionary (MutableWebApiRoute)

@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSString *path;
@property (nonatomic, readwrite) NSString *method;
@property (nonatomic, readwrite) WebApiSerialization serialization;
@property (nonatomic, readwrite) NSString *contentType;
@property (nonatomic, readwrite) NSString *dataMapper;
@property (nonatomic, readwrite, getter=isPreventUserInteraction) BOOL preventUserInteraction;

@end

/**
 Extension to @c NSMutableDictionary to implement writable properties for web API.
 */
@interface NSMutableDictionary (MutableWebApiResponse)

@property (nonatomic, readwrite) NSInteger statusCode;
@property (nonatomic, readwrite) id responseObject;
@property (nonatomic, readwrite) NSDictionary *responseHeaders;

@end