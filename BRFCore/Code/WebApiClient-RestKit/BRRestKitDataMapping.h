//
//  BRRestKitDataMapping.h
//  BlueRocketFuelCore
//
//  Created by Matt on 13/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <RestKit/ObjectMapping.h>
#import <WebApiClient/RestKitWebApiDataMapper.h>

/**
 Utility class to generate RestKit object mapping instances for domain objects.
 */
@interface BRRestKitDataMapping : NSObject

/**
 Get the class of the app user. This defaults to @c BRAppUser.
 */
+ (Class)appUserClass;

/**
 Set the class of the app user. This class is expected to conform to the @c BRUser protocol.
 
 @param theClass The class to set.
 */
+ (void)setAppUserClass:(Class)theClass;

/**
 Get a mapping key transformer, to automatically map between @c snake_case for server keys and @c llamaCase
 for ObjC object keys. Extending classes may want to override this behavior.
 */
+ (NSString * (^)(RKObjectMapping *mapping, NSString *sourceKey))sourceToDestinationKeyTransformationBlock;

/**
 Register all supported object mappings with a specific @c RestKitWebApiDataMapper.
 
 @param dataMapper The @c RestKitWebApiDataMapper to register request and response mappings for.
 */
+ (void)registerObjectMappings:(RestKitWebApiDataMapper *)dataMapper;

/**
 Get a mapping for the @c BRAppUser class.
 
 @return An object mapping instance.
 */
+ (RKObjectMapping *)appUserMapping;

@end
