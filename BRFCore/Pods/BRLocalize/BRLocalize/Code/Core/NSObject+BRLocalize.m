//
//  NSObject+BRLocalizableUI.m
//  BlueRocketFuelCore
//
//  Created by Matt on 17/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "NSObject+BRLocalize.h"

#import <objc/objc-runtime.h>
#import "BRLocalizable.h"
#import "NSBundle+BRLocalize.h"

static IMP original_awakeFromNib;//(id, SEL);

static void brrf_awakeFromNib(id self, SEL _cmd) {
	((void(*)(id,SEL))original_awakeFromNib)(self, _cmd);
	if ( ![self conformsToProtocol:@protocol(BRLocalizable)] ) {
		return;
	}
	NSDictionary *strings = [NSBundle appStrings];
	[self localizeWithAppStrings:strings];
}

@implementation NSObject (BRLocalize)

+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Class class = [self class];
		
		SEL originalSelector = @selector(awakeFromNib);
		Method originalMethod = class_getInstanceMethod(class, originalSelector);
		original_awakeFromNib = method_setImplementation(originalMethod, (IMP)brrf_awakeFromNib);
	});
}

@end
