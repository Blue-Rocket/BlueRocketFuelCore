//
//  WebApiClientServiceRegistry.m
//  BRFCore
//
//  Created by Matt on 18/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import "WebApiClientServiceRegistry+BR.h"

@implementation WebApiClientServiceRegistry {
	id<SupportingWebApiClient> webApiClient;
}

@synthesize webApiClient;

@end

@implementation WebApiClientServiceRegistry (BR)

- (void)setWebApiClient:(id<SupportingWebApiClient>)client {
	webApiClient = client;
}

@end
