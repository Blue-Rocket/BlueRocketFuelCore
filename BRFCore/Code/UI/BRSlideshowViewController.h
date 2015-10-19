//
//  BRSlideshowViewController.h
//  BRFCore
//
//  Created by Matt on 19/10/15.
//  Copyright © 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import <UIKit/UIKit.h>

#import <BRScroller/BRScroller.h>
#import <BRStyle/Core.h>

@protocol BRSlideshowViewControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 Present a simple slide show of images, which can be in PNG, JPG, or PDF form. 
 
 This controller is designed to be presented modally. By default, the controller will look for a set of image resources
 named @c app_slideshow_XXX where @c XXX is a number, starting at @c 001, with either a @c png, @c jpg, or @c pdf extension.
 It will start looking for image @c 001 and continue adding 1 until no more images are found, for example @c 002, @c 003, etc.
 
 To customize what images are shown, configure a @c BRSlideshowViewControllerDelegate on the @c slideshowDelegate property.
 
 This controller will keep track if it has ever been shown (via @c NSUserDefaults) and it not automatically set 
 @c showDismissButtonOnlyAtEnd to @c YES.
 */
@interface BRSlideshowViewController : UIViewController <BRScrollerDelegate, BRUIStylish>

/** The scroller view that will manage the slide content. Will be created if not configured. */
@property (nonatomic, strong) IBOutlet BRScrollerView *scrollView;

/** A button to dismiss the slideshow. */
@property (nonatomic, strong) IBOutlet UIButton *dismissButton;

/** A flag to control if the dismiss button should be hidden unless on the last slide. */
@property (nonatomic, assign, getter=isShowDismissButtonOnlyAtEnd) IBInspectable BOOL showDismissButtonOnlyAtEnd;

/** An optional delegate, which can provide the image resources to display. */
@property (nonatomic, weak) id<BRSlideshowViewControllerDelegate> slideshowDelegate;

/** Test if this view controller is being presented for the first time in the app's life. */
@property (nonatomic, readonly, getter=isViewingForFirstTime) BOOL viewingForFirstTime;

@end

#pragma mark -

/**
 A delegate protocol to control the slideshow.
 */
@protocol BRSlideshowViewControllerDelegate <NSObject>

@optional

/**
 Get the number of slides in the slideshow to show.
 
 @return The total number of slides to present.
 */
- (NSUInteger)numberOfSlides;

/**
 Get the path to a specific slide resource.
 
 @param index The index of the slide.
 
 @return The path to the @c PNG, @c JPG, or @c PDF resource to show.
 */
- (NSString *)pathForSlideAtIndex:(NSUInteger)index;

/**
 Control if a specific slide should allow zooming. If this method is not provided, by default @c PDF images will
 support zooming but other image types will not.
 
 @param index The index of the slide to test.
 
 @return @c YES if the slide should allow zooming.
 */
- (BOOL)isZoomingAllowedForSlideAtIndex:(NSUInteger)index;

/**
 Callback when different slides are shown.
 
 @param controller The controller.
 @param index      The index of the slide being shown.
 */
- (void)slideshowController:(BRSlideshowViewController *)controller didShowSlide:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
