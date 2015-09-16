//
//  WebApiClientEnvironment.h
//  WebApiClient
//
//  Created by Matt on 19/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

/** A BREnvironment key for the protocol to use for the server endpoints, e.g. @c http or @c https. */
extern NSString * const WebApiClientSupportServerProtocolEnvironmentKey;

/** A BREnvironment key for the host to use for the server endpoints, e.g. @c example.com. */
extern NSString * const WebApiClientSupportServerHostEnvironmentKey;

/** A BREnvironment key for the port to use for the server endpoints, e.g. @c 80, @c 443. */
extern NSString * const WebApiClientSupportServerPortEnvironmentKey;

/** A BREnvironment key for the @c appApiKey value to use. */
extern NSString * const WebApiClientSupportAppApiKeyEnvironmentKey;

