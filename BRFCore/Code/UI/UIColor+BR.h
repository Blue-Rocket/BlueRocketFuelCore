//
//  UIColor+BR.h
//  BlueRocketFuel
//
//  Created by Estevan Hernandez on 11/2/16.
//  Copyright © 2016 Blue Rocket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (BR)

/*!
 @brief returns UIColor from a hex value
 @discussion if you pass 0xFF0000, the UIColor returned will be red
 @param (unsigned long) rgb
 @return UIColor
 */
+ (UIColor *)colorFromRGBHex:(uint64_t)rgb;
/*!
 @brief returns UIColor from a hex value
 @discussion if you pass 0xFF0000FF, the UIColor returned will be red with alpha 1.0
 @param (unsigned long) rgba
 @return UIColor
 */
+ (UIColor *)colorFromRGBAHex:(uint64_t)rgba;
/*!
 @brief returns UIColor from a hex value
 @discussion if you pass 0xFF0000 and 0.5, the UIColor returned will be red with alpha 0.5 (%50)
 @param (unsigned long) rgb
 @param (CGFloat) alpha
 @return UIColor
 */
+ (UIColor *)colorFromRGBHex:(uint64_t)rgb withOpacity:(CGFloat)alpha;

@end
