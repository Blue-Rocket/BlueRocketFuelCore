//
//  BRGradientView.h
//  BlueRocketFuelCore
//
//  Created by Matt on 13/10/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>
#import <BRStyle/Core.h>

typedef enum : NSUInteger {
	BRGradientViewGradientTypeLinear = 0,
} BRGradientViewGradientType;

NS_ASSUME_NONNULL_BEGIN

/**
 A view that renders a gradient within the view's bounds.
 */
@interface BRGradientView : UIView <BRUIStylish>

/** The type of gradient to render. */
@property (nonatomic, assign) IBInspectable BRGradientViewGradientType gradientType;

/** A starting coordinate for the first gradient stop position, each value expressed as a percentage of the view bounds from 0 to 1. */
@property (nonatomic, assign) IBInspectable CGPoint startCoordinate;

/** An ending coordinate for the last gradient stop position, each value expressed as a percentage of the view bounds from 0 to 1. */
@property (nonatomic, assign) IBInspectable CGPoint endCoordinate;

/** A starting color for the first gradient stop position. */
@property (nonatomic, strong) IBInspectable UIColor *startColor;

/** An ending color for the last gradient stop position. */
@property (nonatomic, strong) IBInspectable UIColor *endColor;

@end

NS_ASSUME_NONNULL_END
