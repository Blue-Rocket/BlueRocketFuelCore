//
//  WebApiClient.c
//  WebApiClient
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiClient.h"

NSString * const WebApiClientErrorDomain = @"WebApiClientError";

const NSInteger WebApiClientErrorRouteNotAvailable = 2000;
const NSInteger WebApiClientErrorResponseTimeout = 2001;

NSString * const WebApiClientRequestWillBeginNotification = @"WebApiClientRequestWillBegin";

NSString * const WebApiClientRequestDidBeginNotification = @"WebApiClientRequestDidBegin";

NSString * const WebApiClientRequestDidProgressNotification = @"WebApiClientRequestDidProgress";

NSString * const WebApiClientResponseDidProgressNotification = @"WebApiClientResponseDidProgress";

NSString * const WebApiClientRequestDidSucceedNotification = @"WebApiClientRequestDidSucceed";

NSString * const WebApiClientRequestDidFailNotification = @"WebApiClientRequestDidFail";

NSString * const WebApiClientRequestDidCancelNotification = @"WebApiClientRequestDidCancel";

NSString * const WebApiClientURLRequestNotificationKey = @"request";

NSString * const WebApiClientURLResponseNotificationKey = @"response";

NSString * const WebApiClientProgressNotificationKey = @"progress";

NSString * const WebApiClientJSONContentType = @"application/json";

NSString * const WebApiClientJSONAPIContentType = @"application/vnd.api+json";
