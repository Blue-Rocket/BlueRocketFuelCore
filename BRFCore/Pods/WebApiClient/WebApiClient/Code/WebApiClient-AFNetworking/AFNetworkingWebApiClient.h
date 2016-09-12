//
//  AFNetworkingWebApiClient.h
//  WebApiClient
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiClientSupport.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AFURLResponseSerialization;

/**
 Implementation of @c WebApiClient using AFNetworking with NSURLSessionManager.
 
 @b Note: the @c blockingRequestAPI:withPathVariables:parameters:data:maximumWait:error: method uses
          background threads to complete the HTTP request. It simply blocks the calling thread and
          waits for the background work to complete.
 */
@interface AFNetworkingWebApiClient : WebApiClientSupport

/** A URL response serialization object to use. This will default to one that accepts any type of data. */
@property (nonatomic, strong) id<AFURLResponseSerialization> responseSerializer;

/** An array of active task identifiers, as @c NSNumber instances. */
@property (nonatomic, readonly) NSArray<NSNumber *> *activeTaskIdentifiers;

/** 
 A dictionary of @c WebApiSerialization name keys to acceptable HTTP @c Content-Type header values. This will
 influence the @c Accept HTTP header value of requests. If you'd like to support json:api, you can configure 
 this with the @c WebApiClientJSONAPIContentType, for example `@{ @"json" : @"application/vnd.api+json" }`.
 */
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *defaultSerializationAcceptableContentTypes;

@end

NS_ASSUME_NONNULL_END
