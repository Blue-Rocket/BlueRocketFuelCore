//
//  UIViewController+BR.h
//  BRFCore
//
//  Created by Matt on 18/03/16.
//  Copyright © 2016 Blue Rocket, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BRAsynchronousUISupport.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Extensions to UIViewController for app support.
 
 This category will make all UIViewController objects support all properties defined in the global shared @c BRServiceRegistry
 available as read-write properties directly, unless the controller directly implements a similar property. This makes it very
 easy access to application services in view controllers, by simply adding a @c \@dynamic property for the desired service.
 */
@interface UIViewController (BR) <BRAsynchronousUISupport>

/** Flag the UI as disabled/enabled for an asynrhonous call to complete. The setter will invoke the @c disableForAsynchronousCall and @c enableFromAsynchronousCall methods, if available. */
@property (nonatomic, assign, getter=isDisabledForAsynchronousCall) BOOL disabledForAsynchronousCall;

#pragma mark - Keyboard support

/**
 Ajust the layout of a view in response to a keyboard showing event.
 
 Generally you call this method in one of two ways: first, with a @c UIScrollView as the @c refView, and @c nil @c intersectView and @c constraint properties.
 Second, with @c intersectView and @c constraint and some regular view for @c refView. This allows for a single view controller to handle different layouts,
 such as a scroll view on iPhone while a normal view on iPad.
 
 @param notification  The keyboard hide event.
 @param refView       The reference container view. This should generally be the view controller's @c view or a @c UIScrollView.
 @param intersectView If @c refView is @b not a @c UIScrollView, the view to use when calculating how much the keyboard overlaps with.
 @param constraint    If @c refView is @b not a @c UIScrollView, the constraint to adjust according to how much the keyboard overlaps with @c intersectView.
 */
- (void)adjustForKeyboardWillShow:(NSNotification *)notification
				withReferenceView:(UIView *)refView
					intersectView:(nullable UIView *)intersectView
					   constraint:(nullable NSLayoutConstraint *)constraint;

/**
 Adjust the layout of a view in response to a keyboard hiding event.
 
 @param notification The keyboard hide event.
 @param refView      The reference container view. This should generally be the view controller's @c view or a @c UIScrollView.
 @param constraint   If @c refView is @b not a @c UIScrollView, the constraint to adjust back to 0.
 */
- (void)adjustForKeyboardWillHide:(NSNotification *)notification
				withReferenceView:(UIView *)refView
					   constraint:(nullable NSLayoutConstraint *)constraint;

@end

NS_ASSUME_NONNULL_END
