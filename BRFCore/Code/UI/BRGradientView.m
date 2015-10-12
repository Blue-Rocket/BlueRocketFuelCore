//
//  BRGradientView.m
//  BlueRocketFuelCore
//
//  Created by Matt on 13/10/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BRGradientView.h"

@implementation BRGradientView

@dynamic uiStyle;

+ (Class)layerClass {
	return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer {
	return (CAGradientLayer *)self.layer;
}

- (void)setStartCoordinate:(CGPoint)startCoordinate {
	[self gradientLayer].startPoint = startCoordinate;
}

- (CGPoint)startCoordinate {
	return [self gradientLayer].startPoint;
}

- (void)setEndCoordinate:(CGPoint)endCoordinate {
	[self gradientLayer].endPoint = endCoordinate;
}

- (CGPoint)endCoordinate {
	return [self gradientLayer].endPoint;
}

- (NSMutableArray *)gradientStopColors {
	NSArray *layerColors = [self gradientLayer].colors;
	NSMutableArray *colors = [[NSMutableArray alloc] initWithCapacity:layerColors.count];
	for ( id cgColor in layerColors ) {
		UIColor *c = [UIColor colorWithCGColor:(CGColorRef)cgColor];
		[colors addObject:c];
	}
	return colors;
}

- (void)setGradientStopColors:(NSArray *)colors {
	NSMutableArray *layerColors = [[NSMutableArray alloc] initWithCapacity:colors.count];
	for ( UIColor *c in colors ) {
		[layerColors addObject:(id)c.CGColor];
	}
	[self gradientLayer].colors = layerColors;
}

- (void)setStartColor:(UIColor *)startColor {
	NSMutableArray *colors = [self gradientStopColors];
	if ( colors.count < 1 ) {
		[colors addObject:startColor];
	} else {
		colors[0] = startColor;
	}
	[self setGradientStopColors:colors];
}

- (UIColor *)startColor {
	CGColorRef cgColor = (__bridge CGColorRef)[[self gradientLayer].colors firstObject];
	return (cgColor ? [UIColor colorWithCGColor:cgColor] : nil);
}

- (void)setEndColor:(UIColor *)endColor {
	NSMutableArray *colors = [self gradientStopColors];
	while ( colors.count < 2 ) {
		[colors addObject:endColor];
	}
	colors[colors.count - 1] = endColor;
	[self setGradientStopColors:colors];
}

- (UIColor *)endColor {
	CGColorRef cgColor = (__bridge CGColorRef)[[self gradientLayer].colors lastObject];
	return (cgColor ? [UIColor colorWithCGColor:cgColor] : nil);
}

- (void)uiStyleDidChange:(BRUIStyle *)style {
	UIColor *startColor = style.colors.primaryColor;
	UIColor *endColor = style.colors.secondaryColor;
	if ( startColor && endColor ) {
		[self setGradientStopColors:@[startColor, endColor]];
	}
}

@end
