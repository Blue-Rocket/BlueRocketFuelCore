//
//  NSObject+BRLocalizableUI.h
//  BlueRocketFuelCore
//
//  Created by Matt on 17/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>

/**
 Extension of NSObject to support @c BRLocalizable. This category will invoke @c localizeWithAppStrings:
 on any object that conforms to @c BRLocalizable when the @c awakeFromNib method is invoked.
 */
@interface NSObject (BRLocalize)

@end
