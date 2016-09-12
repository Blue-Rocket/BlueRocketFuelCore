//
//  AFNetworkingWebApiClientTask.m
//  WebApiClient
//
//  Created by Matt on 22/10/15.
//  Copyright © 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "AFNetworkingWebApiClientTask.h"

@implementation AFNetworkingWebApiClientTask {
	NSNumber *taskIdentifier;
	id<WebApiRoute> route;
	dispatch_queue_t callbackQueue;
	WebApiClientRequestProgressBlock progressBlock;
}

@synthesize taskIdentifier;
@synthesize route;
@synthesize callbackQueue;
@synthesize progressBlock;

- (id)init {
	return [self initWithTaskIdentifier:@(NSNotFound) route:@{} queue:nil progressBlock:nil];
}

- (id)initWithTaskIdentifier:(NSNumber *)theTaskIdentifier route:(id<WebApiRoute>)theRoute
					   queue:(dispatch_queue_t)theCallbackQueue
			   progressBlock:(nullable WebApiClientRequestProgressBlock)theProgressBlock {
	if ( (self = [super init]) ) {
		taskIdentifier = theTaskIdentifier;
		route = theRoute;
		callbackQueue = (theCallbackQueue ? theCallbackQueue : dispatch_get_main_queue());
		progressBlock = [theProgressBlock copy];
	}
	return self;
}

@end
