//
//  RoutingWebApiClient.h
//  WebApiClient
//
//  Created by Matt on 27/05/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "SupportingWebApiClient.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A @c WebApiClient that delegates all calls to another @c WebApiClient based on route names.
 This allows different clients to be used for different routes, without the consumer of the
 @c WebApiClient having to deal with different clients.
 
 Simply configure the @c clients dictionary with a mapping of route names to other client
 instances, and then use this client anywhere needed.

 @since 1.1
 */
@interface RoutingWebApiClient : NSObject <SupportingWebApiClient>

/** A mapping of route names to associated @c WebApiClient instances to use. */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id<WebApiClient>> *clients;

/** The default @c WebApiClient to use if no matching route is available in the @c clients dictionary. */
@property (nonatomic, strong) id<WebApiClient> defaultClient;

/**
 Initialize with a default client delegate.
 
 @param client The client to use by default, if not specific client is configured in the @c clients dictionary.
 
 @return The initialized instance.
 */
- (instancetype)initWithDefaultClient:(id<WebApiClient>)client NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
