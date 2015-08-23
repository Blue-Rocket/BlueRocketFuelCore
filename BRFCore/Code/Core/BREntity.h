//
//  BREntity.h
//  BlueRocketFuelCore
//
//  Created by Matt on 19/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

/**
 A persitable domain object with a unique identifier.
 */
@protocol BREntity <NSObject>

/** A unique ID assigned by the system to the entity. */
@property (nonatomic, readonly) NSString *uniqueId;

@end
