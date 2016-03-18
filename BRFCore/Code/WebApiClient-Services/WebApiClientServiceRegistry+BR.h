//
//  WebApiClientServiceRegistry+BR.h
//  BRFCore
//
//  Created by Matt on 18/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import "WebApiClientServiceRegistry.h"

#import "BRServiceRegistry+BR.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebApiClientServiceRegistry (BR)

/**
 Set the @c WebApiClient to use.
 
 @param webApiClient The client to use.
 */
- (void)setWebApiClient:(id<SupportingWebApiClient>)webApiClient;

@end

NS_ASSUME_NONNULL_END
