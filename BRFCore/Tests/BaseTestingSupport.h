//
//  BaseTestingSupport.h
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <XCTest/XCTest.h>

#import <BREnvironment/BREnvironment.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

/**
 A base @c XCTestCase class for other unit tests to extend.
 */
@interface BaseTestingSupport : XCTestCase

@property (nonatomic, readonly) NSBundle *bundle;
@property (nonatomic, readonly) BREnvironment *testEnvironment;

@end
