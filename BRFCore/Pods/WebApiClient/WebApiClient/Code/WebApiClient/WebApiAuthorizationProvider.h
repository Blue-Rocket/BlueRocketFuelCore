//
//  WebApiAuthorizationProvider.h
//  WebApiClient
//
//  Created by Matt on 16/09/15.
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

@protocol WebApiRoute;

/**
 API for a provider of request authorization details.
 */
@protocol WebApiAuthorizationProvider <NSObject>

/**
 Configure any necessary authorization support for a HTTP request.
 
 @param route   The route of the request.
 @param request The request to configure.
 */
- (void)configureAuthorizationForRoute:(id<WebApiRoute>)route request:(NSMutableURLRequest *)request;

@end
