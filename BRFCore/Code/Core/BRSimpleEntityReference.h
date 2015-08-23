//
//  BRSimpleEntityReference.h
//  BlueRocketFuelCore
//
//  Created by Matt on 19/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BREntityReference.h"

/**
 Basic implementation of the @c BREntityReference protocol.
 */
@interface BRSimpleEntityReference : NSObject <BREntityReference>

/**
 Create a new instance.
 
 @param uniqueId The @c uniqueId value.
 @param displayName The @c displayName value.
 @param info An optional set of data to associate with the reference.
 */
- (instancetype)initWithUniqueId:(NSString *)uniqueId displayName:(NSString *)displayName info:(NSDictionary *)info;

@end
