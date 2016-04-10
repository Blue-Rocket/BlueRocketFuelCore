//
//  UIImage_BRTests.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BaseTestingSupport.h"

#import "UIImage+BR.h"

@interface UIImage_BRTests : BaseTestingSupport

@end

@implementation UIImage_BRTests

- (void)testAspectFitZero {
	CGSize result = [UIImage size:CGSizeMake(180, 120) toFit:CGSizeZero];
	assertThatFloat(result.width, closeTo(0, 0.001));
	assertThatFloat(result.height, closeTo(0, 0.001));
}

- (void)testAspectFitFromZero {
	CGSize result = [UIImage size:CGSizeZero toFit:CGSizeMake(120, 120)];
	assertThatFloat(result.width, closeTo(0, 0.001));
	assertThatFloat(result.height, closeTo(0, 0.001));
}

- (void)testAspectFitSmallerWidth {
	CGSize result = [UIImage size:CGSizeMake(180, 120) toFit:CGSizeMake(120, 120)];
	assertThatFloat(result.width, closeTo(120, 0.001));
	assertThatFloat(result.height, closeTo(80, 0.001));
}

- (void)testAspectFitSmallerHeight {
	CGSize result = [UIImage size:CGSizeMake(180, 120) toFit:CGSizeMake(180, 80)];
	assertThatFloat(result.width, closeTo(120, 0.001));
	assertThatFloat(result.height, closeTo(80, 0.001));
}

- (void)testAspectFitScaleLarger {
	CGSize result = [UIImage size:CGSizeMake(180, 120) toFit:CGSizeMake(320, 240)];
	assertThatFloat(result.width, closeTo(320, 0.001));
	assertThatFloat(result.height, closeTo(214, 0.001));
}

- (void)testAspectFillZero {
	CGSize result = [UIImage size:CGSizeMake(180, 120) toFill:CGSizeZero];
	assertThatFloat(result.width, closeTo(0, 0.001));
	assertThatFloat(result.height, closeTo(0, 0.001));
}

- (void)testAspectFillFromZero {
	CGSize result = [UIImage size:CGSizeZero toFill:CGSizeMake(120, 120)];
	assertThatFloat(result.width, closeTo(0, 0.001));
	assertThatFloat(result.height, closeTo(0, 0.001));
}

- (void)testAspectFillSmallerWidth {
	CGSize result = [UIImage size:CGSizeMake(180, 120) toFill:CGSizeMake(120, 120)];
	assertThatFloat(result.width, closeTo(180, 0.001));
	assertThatFloat(result.height, closeTo(120, 0.001));
}

- (void)testAspectFillSmallerHeight {
	CGSize result = [UIImage size:CGSizeMake(180, 120) toFill:CGSizeMake(180, 80)];
	assertThatFloat(result.width, closeTo(180, 0.001));
	assertThatFloat(result.height, closeTo(120, 0.001));
}

- (void)testAspectFillScaleLarger {
	CGSize result = [UIImage size:CGSizeMake(180, 120) toFill:CGSizeMake(320, 240)];
	assertThatFloat(result.width, closeTo(360, 0.001));
	assertThatFloat(result.height, closeTo(240, 0.001));
}

@end
