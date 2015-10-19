//
//  BRSlideshowViewController.m
//  BRFCore
//
//  Created by Matt on 19/10/15.
//  Copyright © 2015 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BRSlideshowViewController.h"

#import "BRSlideshowSlideView.h"

static NSString * const BRSlideshowViewControllerViewed = @"BRSlideshowViewControllerViewed";

@interface BRSlideshowViewController ()

@end

@implementation BRSlideshowViewController {
	NSArray<NSString *> *imagePaths;
}

@dynamic uiStyle;

- (void)viewDidLoad {
    [super viewDidLoad];
	if ( self.scrollView == nil ) {
		BRScrollerView *scroller = [[BRScrollerView alloc] initWithFrame:self.view.frame];
		scroller.scrollerDelegate = self;
		scroller.pagingEnabled = YES;
		scroller.backgroundColor = [UIColor clearColor];
	}
	if ( self.viewingForFirstTime ) {
		self.showDismissButtonOnlyAtEnd = YES;
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ( !imagePaths && ![self.slideshowDelegate respondsToSelector:@selector(numberOfSlides)] ) {
		[self configureDefaultSlideshowContent];
	}
	if ( self.showDismissButtonOnlyAtEnd && [self numberOfPagesInScroller:self.scrollView] > 0 ) {
		self.dismissButton.alpha = 0;
	}
	if ( [self.dismissButton actionsForTarget:self forControlEvent:UIControlEventTouchUpInside].count < 1 ) {
		[self.dismissButton addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
	}
	if ( self.scrollView.loaded == NO ) {
		[self.scrollView reloadData];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	if ( [self isViewingForFirstTime] ) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:BRSlideshowViewControllerViewed];
	}
}

- (BOOL)isViewingForFirstTime {
	return ![[NSUserDefaults standardUserDefaults] boolForKey:BRSlideshowViewControllerViewed];
}

+ (CGSize)deviceSize {
	UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
	CGSize size = [UIScreen mainScreen].bounds.size;
	if ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending ) {
		if ( interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight ) {
			CGFloat temp = size.width;
			size.width = size.height;
			size.height = temp;
		}
	}
	return size;
}

+ (NSArray<NSString *> *)imageExtensionsForDevice {
	CGFloat scale = [UIScreen mainScreen].scale;
	CGSize size = [self deviceSize];
	
	// TODO: make this static and cached
	
	NSMutableArray<NSString *> *values = [[NSMutableArray alloc] initWithCapacity:8];
	if ( scale > 2.f ) {
		[values addObject:@"@3x"]; // iPhone 6 Plus
	}
	if ( scale > 1.f && size.height >= 667.0f) {
		[values addObject:@"-667h@2x"];    // iPhone 6
	}
	if ( scale > 1.f && size.height >= 568.0f ) {
		[values addObject:@"-568h@2x"]; // iPhone 5, 5S, 5C
	}
	if ( scale > 1.f ) {
		[values addObject:@"@2x"]; // iPhone 4, 4S
	}
	[values addObject:@""];
	
	return values;

}

+ (NSString *)pathForImage:(const NSUInteger)index {
	NSString *basePath = [NSString stringWithFormat:@"app_slideshow_%03lu", (unsigned long)index];
	NSArray<NSString *> *extensions = [self imageExtensionsForDevice];
	NSString *result = nil;
	for ( NSString *ext in extensions ) {
		NSString *imagePath = [basePath stringByAppendingString:ext];
		result = [[NSBundle mainBundle] pathForResource:imagePath ofType:@"pdf" inDirectory:@"Slideshow"];
		if ( !result ) {
			result = [[NSBundle mainBundle] pathForResource:imagePath ofType:@"png" inDirectory:@"Slideshow"];
			if ( !result ) {
				result = [[NSBundle mainBundle] pathForResource:imagePath ofType:@"jpg" inDirectory:@"Slideshow"];
			}
		}
		if ( result ) {
			break;
		}
	}
	return result;
}

- (void)configureDefaultSlideshowContent {
	NSMutableArray<NSString *> *slidePaths = [[NSMutableArray alloc] initWithCapacity:8];
	while ( true ) {
		NSString *imagePath = [[self class] pathForImage:(slidePaths.count + 1)];
		if ( imagePath != nil ) {
			[slidePaths addObject:imagePath];
		} else {
			break;
		}
	}
	imagePaths = slidePaths;
}

- (BOOL)isLastSlideIndex:(NSUInteger)index inScroller:(BRScrollerView *)scroller {
	return (index + 1 == [self numberOfPagesInScroller:scroller]);
}

- (IBAction)dismiss:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BRScrollerDelegate

- (NSUInteger)numberOfPagesInScroller:(BRScrollerView *)scroller {
	return ([self.slideshowDelegate respondsToSelector:@selector(numberOfSlides)] ? [self.slideshowDelegate numberOfSlides] : imagePaths.count);
}

- (UIView *)createReusablePageViewForScroller:(BRScrollerView *)scroller {
	BRSlideshowSlideView *slide = [[BRSlideshowSlideView alloc] initWithFrame:self.view.bounds];
	return slide;
}

- (void)scroller:(BRScrollerView *)scroller
 willDisplayPage:(NSUInteger)index
			view:(UIView *)reusablePageView {
	BRSlideshowSlideView *slide = (BRSlideshowSlideView *)reusablePageView;
	NSString *imagePath = ([self.slideshowDelegate respondsToSelector:@selector(pathForSlideAtIndex:)]
						   ? [self.slideshowDelegate pathForSlideAtIndex:index]
						   : imagePaths[index]);
	BOOL zoomable = ([self.slideshowDelegate respondsToSelector:@selector(isZoomingAllowedForSlideAtIndex:)]
					 ? [self.slideshowDelegate isZoomingAllowedForSlideAtIndex:index]
					 : [[[imagePath pathExtension] lowercaseString] isEqualToString:@"pdf"]);
	[slide showImageResource:imagePath withZoom:zoomable];
}

- (void)scroller:(BRScrollerView *)scroller didDisplayPage:(NSUInteger)index {
	if ( [self.slideshowDelegate respondsToSelector:@selector(slideshowController:didShowSlide:)] ) {
		[self.slideshowDelegate slideshowController:self didShowSlide:index];
	}
	if ( [self isLastSlideIndex:index inScroller:scroller] && self.showDismissButtonOnlyAtEnd && self.dismissButton.alpha < 1 ) {
		[UIView animateWithDuration:0.2 animations:^{
			self.dismissButton.alpha = 1;
		}];
	}
}

- (void)scroller:(BRScrollerView *)scroller willLeavePage:(NSUInteger)index {
	if ( [self isLastSlideIndex:index inScroller:scroller] && self.showDismissButtonOnlyAtEnd && self.dismissButton.alpha > 0 ) {
		[UIView animateWithDuration:0.2 animations:^{
			self.dismissButton.alpha = 0;
		}];
	}
}

@end
