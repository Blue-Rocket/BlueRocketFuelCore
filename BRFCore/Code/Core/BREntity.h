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

/**
 Test if an entity is different from the receiver.
 
 Difference is defined as having property values that differ between the two objects. This is designed
 to be used to tell if something has changed, for example when refreshing cached data from a server.
 
 @param other The other object to compare to.
 
 @return @c YES if the receiver differs from @c other.
 */
- (BOOL)isDifferentFrom:(id<BREntity>)other;

@end
