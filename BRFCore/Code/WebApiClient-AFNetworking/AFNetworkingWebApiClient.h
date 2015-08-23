//
//  AFNetworkingWebApiClient.h
//  BlueRocketFuelCore
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiClientSupport.h"

@interface AFNetworkingWebApiClient : WebApiClientSupport

/** An array of active task identifiers, as @c NSNumber instances. */
@property (nonatomic, readonly) NSArray *activeTaskIdentifiers;

/**
 Get a route associated with an active task identifer.
 
 @param identifier The @c NSURLSessionTask identifier to get the route for.
 @return The route associated with the identifier, or @c nil if not available.
 @see activeTaskIdentifiers
 */
- (id<WebApiRoute>)routeForActiveTaskIdentifier:(NSUInteger)identifier;

@end
