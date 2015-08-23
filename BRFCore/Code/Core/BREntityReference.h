//
//  BREntityReference.h
//  BlueRocketFuelCore
//
//  Created by Matt on 19/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

/**
 A reference to some BREntity. Useful in scenarios where just links to entity objects are used,
 for example a search result might return reference instances instead of full object instances.
 */
@protocol BREntityReference <NSObject>

/** The unique ID of the entity this object refers to. */
@property (nonatomic, readonly) NSString *uniqueId;

/** Get a suitable display name for this object. */
@property (nonatomic, readonly) NSString *displayName;

/** Get an optional info dictionary with arbitrary details associated with the object reference. */
@property (nonatomic, readonly) NSDictionary *info;

@end
