//
//  UIColor+BR.m
//  BlueRocketFuel
//
//  Created by Estevan Hernandez on 11/2/16.
//  Copyright © 2016 Blue Rocket. All rights reserved.
//

#import "UIColor+BR.h"

@implementation UIColor (BR)
+ (UIColor *)colorFromRGBHex:(uint64_t)rgb {
	if (rgb > 0xFFFFFF) {
		NSLog(@"WARNING: colorFromRGBHex expects 6 bytes\nsterilizing input to 6 bytes, behaviour undefined.");
		rgb = rgb&0xFFFFFF;
	}
	CGFloat red =	((rgb&0xFF0000)>>2*8)/255.0f;
	CGFloat green = ((rgb&0x00FF00)>>1*8)/255.0f;
	CGFloat blue =	((rgb&0x0000FF)>>0*8)/255.0f;
	CGFloat alpha = 0xFF/255.0f;
	
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGFloat components[] = {red, green, blue, alpha};
	CGColorRef cgColor = CGColorCreate(colorSpaceRef, components);
	UIColor *color = [UIColor colorWithCGColor:cgColor];
	CGColorSpaceRelease(colorSpaceRef);
	CGColorRelease(cgColor);
	return color;
}

+ (UIColor *)colorFromRGBAHex:(uint64_t)rgba {
	if (rgba > 0xFFFFFFFF) {
		NSLog(@"WARNING: colorFromRGBAHex expects 8 bytes\nsterilizing input to 8 bytes, behaviour undefined.");
		rgba = rgba&0xFFFFFFFF;
	}
	CGFloat red =	((rgba&0xFF000000)>>3*8)/255.0f;
	CGFloat green = ((rgba&0x00FF0000)>>2*8)/255.0f;
	CGFloat blue =	((rgba&0x0000FF00)>>1*8)/255.0f;
	CGFloat alpha = ((rgba&0x000000FF)>>0*8)/255.0f;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGFloat components[] = {red, green, blue, alpha};
	CGColorRef cgColor = CGColorCreate(colorSpaceRef, components);
	UIColor *color = [UIColor colorWithCGColor:cgColor];
	CGColorSpaceRelease(colorSpaceRef);
	CGColorRelease(cgColor);
	return color;
}

+ (UIColor *)colorFromRGBHex:(uint64_t)rgb withOpacity:(CGFloat)alpha {
	if (rgb > 0xFFFFFF) {
		NSLog(@"WARNING: colorFromRGBAHex expects 8 bytes\nsterilizing input to 8 bytes, behaviour undefined.");
		rgb = rgb&0xFFFFFF;
	}
	CGFloat red =	((rgb&0xFF0000)>>2*8)/255.0f;
	CGFloat green = ((rgb&0x00FF00)>>1*8)/255.0f;
	CGFloat blue =	((rgb&0x0000FF)>>0*8)/255.0f;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGFloat components[] = {red, green, blue, alpha};
	CGColorRef cgColor = CGColorCreate(colorSpaceRef, components);
	UIColor *color = [UIColor colorWithCGColor:cgColor];
	CGColorSpaceRelease(colorSpaceRef);
	CGColorRelease(cgColor);
	return color;
}

@end

