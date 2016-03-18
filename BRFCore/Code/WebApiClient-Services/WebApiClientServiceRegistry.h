//
//  WebApiClientServiceRegistry.h
//  BRFCore
//
//  Created by Matt on 18/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import "BRServiceRegistry.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SupportingWebApiClient;

/**
 Extension of @c BRServiceRegistry that adds support for a @c WebApiClient service.
 */
@interface WebApiClientServiceRegistry : BRServiceRegistry

/** The @c WebApiClient to use. */
@property (nonatomic, readonly) id<SupportingWebApiClient> webApiClient;

@end

NS_ASSUME_NONNULL_END
