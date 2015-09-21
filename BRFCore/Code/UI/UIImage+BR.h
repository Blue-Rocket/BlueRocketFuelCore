//
//  Created by Shawn McKee on 11/21/13.
//
//  Copyright (c) 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>

@interface UIImage (BR)

/**
 Calcualte a size to aspect-fit a given size into a maximum size.
 
 @param size    The size to scale.
 @param maxSize The maximum allowed size.
 
 @return The @c size transformed to maintain its aspect ratio but scaled to fit within @c maxSize.
 */
+ (CGSize)size:(CGSize)size toFit:(CGSize)maxSize;

/**
 Calculate a size to aspect-fill a given size into a maximum size.
 
 @param size    The size to scale.
 @param maxSize The maximum allowed size.
 
 @return The @c size transformed to maintain its aspect ratio but scaled to maximually fill @c maxSize. 
         The final size can thus be larger than @c maxSize in one direction.
 */
+ (CGSize)size:(CGSize)size toFill:(CGSize)maxSize;

- (UIImage *)resizedImageByWidth:(NSUInteger)width;
- (UIImage *)resizedImageByHeight:(NSUInteger)height;
- (UIImage*) croppedImageWithRect: (CGRect) rect;
- (UIImage*)rotate:(UIImageOrientation)orient;

@end
