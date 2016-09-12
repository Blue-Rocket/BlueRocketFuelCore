//
//  AFNetworkingWebApiClientTask.h
//  WebApiClient
//
//  Created by Matt on 22/10/15.
//  Copyright © 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiClient.h"

@protocol WebApiRoute;

NS_ASSUME_NONNULL_BEGIN

/**
 Object used to track HTTP request state details during request operations.
 */
@interface AFNetworkingWebApiClientTask : NSObject

@property (nonatomic, strong, readonly) NSNumber *taskIdentifier;

@property (nonatomic, strong, readonly) id<WebApiRoute> route;

@property (nonatomic, strong, readonly) dispatch_queue_t callbackQueue;

@property (nonatomic, readonly, nullable) WebApiClientRequestProgressBlock progressBlock;

@property (nonatomic, strong, nullable) NSProgress *uploadProgress;

@property (nonatomic, strong, nullable) NSProgress *downloadProgress;

/**
 Initialize with values.
 
 @param taskIdentifier The @c NSURLSessionTask identifier.
 @param route          The route.
 @param queue          The queue to call blocks on. Defaults to the main queue if @c nil.
 @param progressBlock  An optional progress block.
 
 @return The initialized instance.
 */
- (id)initWithTaskIdentifier:(NSNumber *)taskIdentifier
					   route:(id<WebApiRoute>)route
					   queue:(nullable dispatch_queue_t)queue
			   progressBlock:(nullable WebApiClientRequestProgressBlock)progressBlock NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
