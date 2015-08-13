//
//  BRFCRestKitDataMapping.m
//  BlueRocketFuelCore
//
//  Created by Matt on 13/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BRFCRestKitDataMapping.h"

#import "BRAppUser.h"

@implementation BRFCRestKitDataMapping

+ (void)registerObjectMappings:(RestKitWebApiDataMapper *)dataMapper {
	RKObjectMapping *appUserMapping = [self appUserMapping];
	[dataMapper registerRequestObjectMapping:appUserMapping forRoutePath:@"register"];
	[dataMapper registerResponseObjectMapping:appUserMapping forRoutePath:@"register"];
}

+ (RKObjectMapping *)appUserMapping {
	RKObjectMapping* mapping = [RKObjectMapping mappingForClass:[BRAppUser class]];
	[mapping addAttributeMappingsFromArray:@[
											 NSStringFromSelector(@selector(recordId)),
											 NSStringFromSelector(@selector(type)),
											 NSStringFromSelector(@selector(name)),
											 NSStringFromSelector(@selector(firstName)),
											 NSStringFromSelector(@selector(lastName)),
											 NSStringFromSelector(@selector(website)),
											 NSStringFromSelector(@selector(phone)),
											 NSStringFromSelector(@selector(address)),
											 NSStringFromSelector(@selector(email)),
											 NSStringFromSelector(@selector(password)),
											 ]];
	[mapping addAttributeMappingsFromDictionary:@{
												  @"passwordAgain" : @"password_confirmation",
												  }];
	return mapping;
}

@end
