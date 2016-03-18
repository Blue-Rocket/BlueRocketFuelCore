//
//  UIViewController+BR.m
//  BRFCore
//
//  Created by Matt on 18/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import "UIViewController+BR.h"

#import <objc/runtime.h>
#import "BRServiceRegistry.h"

static NSString * propertyNameForSelector(SEL aSEL, BOOL *setter) {
	NSString *name = NSStringFromSelector(aSEL);
	BOOL set = NO;
	if ( [name hasPrefix:@"set"] && [name hasSuffix:@":"] ) {
		set = YES;
		// turn name like "setFooBar:" into "fooBar"
		name = [[[name substringWithRange:NSMakeRange(3, 1)] lowercaseString] stringByAppendingString:[name substringWithRange:NSMakeRange(4, [name length] - 5)]];
	}
	if ( setter ) {
		*setter = set;
	}
	return name;
}

id dynamicServiceGetterIMP(id self, SEL _cmd) {
	id service = objc_getAssociatedObject(self, _cmd);
	BRServiceRegistry *reg = [BRServiceRegistry sharedRegistry];
	if ( service == nil && [reg respondsToSelector:_cmd] ) {
		IMP imp = [reg methodForSelector:_cmd];
		service = ((id(*)(id,SEL))imp)(reg, _cmd);
	}
	return service;
}

void dynamicServiceSetterIMP(id self, SEL _cmd, id service) {
	NSString *name = propertyNameForSelector(_cmd, NULL);
	SEL key = NSSelectorFromString(name);
	[self willChangeValueForKey:name];
	objc_setAssociatedObject(self, key, service, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey:name];
}

@implementation UIViewController (BR)

+ (BOOL)resolveInstanceMethod:(SEL)aSEL {
	if ( [BRServiceRegistry hasSharedRegistry] == NO ) {
		return [super resolveInstanceMethod:aSEL];
	}
	// dynamically resolve to BRServiceRegistry (or subclass) methods
	BRServiceRegistry *reg = [BRServiceRegistry sharedRegistry];
	if ( [reg respondsToSelector:aSEL] == NO ) {
		return [super resolveInstanceMethod:aSEL];
	}
	BOOL setter = NO;
	propertyNameForSelector(aSEL, &setter);
	
	IMP meth = (setter ? (IMP)dynamicServiceSetterIMP : (IMP)dynamicServiceGetterIMP);
	class_addMethod([self class], aSEL, meth, (setter ? "v@:@" : "@@:"));
	return YES;
}

- (BOOL)isDisabledForAsynchronousCall {
	NSNumber *n = objc_getAssociatedObject(self, @selector(isDisabledForAsynchronousCall));
	return [n boolValue];
}

- (void)setDisabledForAsynchronousCall:(BOOL)disabledForAsynchronousCall {
	NSNumber *n = objc_getAssociatedObject(self, @selector(isDisabledForAsynchronousCall));
	if ( [n boolValue] != disabledForAsynchronousCall ) {
		objc_setAssociatedObject(self, @selector(isDisabledForAsynchronousCall), @(disabledForAsynchronousCall), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		if ( disabledForAsynchronousCall && [self respondsToSelector:@selector(disableForAsynchronousCall)] ) {
			[self disableForAsynchronousCall];
		} else if ( !disabledForAsynchronousCall && [self respondsToSelector:@selector(enableFromAsynchronousCall)] ) {
			[self enableFromAsynchronousCall];
		}
	}
}

#pragma mark - Keyboard support

- (void)adjustForKeyboardWillShow:(NSNotification *)notification withReferenceView:(UIView *)refView intersectView:(UIView *)intersectView constraint:(NSLayoutConstraint *)constraint {
	NSDictionary *info = [notification userInfo];
	
	NSTimeInterval animationDuration;
	UIViewAnimationCurve animationCurve;
	CGRect keyboardEndFrame;
	
	[[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	[[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
	
	UIScrollView *scroller = ([refView isKindOfClass:[UIScrollView class]] ? (UIScrollView *)refView : nil);
	keyboardEndFrame = [refView convertRect:keyboardEndFrame fromView:nil];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:animationDuration];
	[UIView setAnimationCurve:animationCurve];
	
	if ( scroller ) {
		UIEdgeInsets insets = scroller.contentInset;
		insets.bottom = CGRectIntersection(keyboardEndFrame, scroller.bounds).size.height;
		scroller.contentInset = insets;
		scroller.scrollIndicatorInsets = UIEdgeInsetsMake(insets.top, 0, insets.bottom, 0);
	} else {
		CGRect intersection = CGRectIntersection(keyboardEndFrame, [refView convertRect:intersectView.bounds fromView:intersectView]);
		if ( intersection.size.height < 1 ) {
			// keyboard does not overlap, so nothing more to do
			return;
		}
		constraint.constant = -intersection.size.height;
		[refView layoutIfNeeded];
	}
	
	[UIView commitAnimations];
}

- (void)adjustForKeyboardWillHide:(NSNotification *)notification withReferenceView:(UIView *)refView constraint:(NSLayoutConstraint *)constraint {
	UIScrollView *scroller = ([refView isKindOfClass:[UIScrollView class]] ? (UIScrollView *)refView : nil);
	if ( scroller == nil && !(constraint.constant < 0) ) {
		// keyboard does not overlap, so nothing more to do
		return;
	}
	
	NSDictionary *info = [notification userInfo];
	
	NSTimeInterval animationDuration;
	UIViewAnimationCurve animationCurve;
	
	[[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
	[[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:animationDuration];
	[UIView setAnimationCurve:animationCurve];
	
	if ( scroller ) {
		UIEdgeInsets insets = scroller.contentInset;
		insets.bottom = 0;
		scroller.contentInset = insets;
		scroller.scrollIndicatorInsets = UIEdgeInsetsMake(insets.top, 0, insets.bottom, 0);
	} else {
		constraint.constant = 0;
		[refView layoutIfNeeded];
	}
	
	[UIView commitAnimations];
}

@end
