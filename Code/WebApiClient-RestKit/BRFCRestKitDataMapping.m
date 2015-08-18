//
//  BRFCRestKitDataMapping.m
//  BlueRocketFuelCore
//
//  Created by Matt on 13/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BRFCRestKitDataMapping.h"

#import <TransformerKit/TTTStringTransformers.h>
#import "BRAppUser.h"
#import "WebApiRoute.h"

static Class kAppUserClass;

@implementation BRFCRestKitDataMapping

+ (Class)appUserClass {
	Class c = kAppUserClass;
	if ( !c ) {
		c = [BRAppUser class];
		kAppUserClass = c;
	}
	return c;
}

+ (void)setAppUserClass:(Class)theClass {
	NSParameterAssert([theClass conformsToProtocol:@protocol(BRUser)]);
	kAppUserClass = theClass;
}

+ (NSString * (^)(RKObjectMapping *mapping, NSString *sourceKey))sourceToDestinationKeyTransformationBlock {
	return ^(RKObjectMapping *mapping, NSString *sourceKey) {
		NSValueTransformer *normalizedKey = [[NSValueTransformer valueTransformerForName:TTTSnakeCaseStringTransformerName] reverseTransformedValue:sourceKey];
		NSString *destKey = [[NSValueTransformer valueTransformerForName:TTTLlamaCaseStringTransformerName] transformedValue:normalizedKey];
		return destKey;
	};
}

+ (void)registerObjectMappings:(RestKitWebApiDataMapper *)dataMapper {
	RKObjectMapping *appUserMapping = [self appUserMapping];
	RKObjectMapping *apiUserEncoding = [appUserMapping inverseMapping];
	[dataMapper registerRequestObjectMapping:apiUserEncoding forRouteName:WebApiRouteLogin];
	[dataMapper registerResponseObjectMapping:appUserMapping forRouteName:WebApiRouteLogin];
	[dataMapper registerRequestObjectMapping:apiUserEncoding forRouteName:WebApiRouteRegister];
	[dataMapper registerResponseObjectMapping:appUserMapping forRouteName:WebApiRouteRegister];
}

+ (RKObjectMapping *)appUserMapping {
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[self appUserClass]];
	[mapping setSourceToDestinationKeyTransformationBlock:[self sourceToDestinationKeyTransformationBlock]];
	[mapping addAttributeMappingsFromArray:@[
											 @"name",
											 @"first_name",
											 @"last_name",
											 @"website",
											 @"phone",
											 @"address",
											 @"email",
											 @"password",
											 ]];
	[mapping addAttributeMappingsFromDictionary:@{@"id" : @"uniqueId",
												  @"password_confirmation" : @"passwordAgain",
												  @"token" : @"authenticationToken",
												  @"user_type" : @"type"
												  }];
	return mapping;
}

@end
