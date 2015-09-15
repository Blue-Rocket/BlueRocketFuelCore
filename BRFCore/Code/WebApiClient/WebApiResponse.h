//
//  WebApiResponse.h
//  BlueRocketFuelCore
//
//  Created by Matt on 17/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

@protocol WebApiRoute;

/**
 A WebApiResponse object represents a response to a HTTP URL request.
 */
@protocol  WebApiResponse <NSObject>

/** The route used by the client. */
@property (nonatomic, readonly) id<WebApiRoute> route;

/** The HTTP status code of the receiver. */
@property (nonatomic, readonly) NSInteger statusCode;

/** A dictionary of all response headers. */
@property (nonatomic, readonly) NSDictionary *responseHeaders;

/** The response object, or @c nil if none available. */
@property (nonatomic, readonly) id responseObject;

@end
