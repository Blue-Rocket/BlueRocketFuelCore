//
//  BRSlideshowSlideView.h
//  BRFCore
//
//  Created by Matt on 19/10/15.
//  Copyright © 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>

/**
 A slideshow slide view that supports both zooming and non-zooming modes.
 */
@interface BRSlideshowSlideView : UIView

/**
 Show a specific image resource. The supported types are @c PNG, @c JPG, and @c PDF.
 
 @param imagePath The image resource to show.
 @param allowZoom Flag to enable zooming the image resource.
 */
- (void)showImageResource:(NSString *)imagePath withZoom:(BOOL)allowZoom;

@end
