//
//  WebApiClientActivitySupport.m
//  BlueRocketFuelCore
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiClientActivitySupport.h"

#import <BRLocalize/Core.h>
#import <Masonry/Masonry.h>
#import "WebApiClient.h"
#import "UIImage+ImageEffects.h"

@implementation WebApiClientActivitySupport {
	NSLock *lock;
	NSTimer *fullScreenIndicatorTimer;
	UIView *fullScreenIndicatorView;
	NSString *fullScreenIndicatorRouteName;
	NSTimeInterval requestTooSlowDuration;
}

@synthesize requestTooSlowDuration;

- (id)init {
	if ( (self = [super init]) ) {
		lock = [[NSLock alloc] init];
		lock.name = @"WebApiClientActivitySupport";
		requestTooSlowDuration = 4;
	}
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestWillBegin:) name:WebApiClientRequestWillBeginNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestDidEnd:) name:WebApiClientRequestDidSucceedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestDidEnd:) name:WebApiClientRequestDidCancelNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestDidEnd:) name:WebApiClientRequestDidFailNotification object:nil];
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebApiClientRequestWillBeginNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebApiClientRequestDidSucceedNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebApiClientRequestDidCancelNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:WebApiClientRequestDidFailNotification object:nil];
}

#pragma mark - Notifications

- (void)requestWillBegin:(NSNotification *)notification {
	id<WebApiRoute> route = notification.object;
	if ( route.preventUserInteraction ) {
		[self setupFullScreenIndicatorForRoute:route];
	}
}

- (void)requestDidEnd:(NSNotification *)notification {
	id<WebApiRoute> route = notification.object;
	if ( route.preventUserInteraction ) {
		[self stopFullScreenIndicatorForRoute:route];
	}
}

#pragma mark - Showing Full Screen Spinner

- (void)setupFullScreenIndicatorForRoute:(id<WebApiRoute>)route {
	[lock lock];
	if ( fullScreenIndicatorTimer ) {
		[fullScreenIndicatorTimer invalidate];
	}
	NSTimer *timer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:requestTooSlowDuration]
											  interval:0
												target:self
											  selector:@selector(showFullScreenIndicatorTimerDidFire:)
											  userInfo:@{ @"route" : route }
											   repeats:NO];
	fullScreenIndicatorTimer = timer;
	fullScreenIndicatorRouteName = route.name;
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
	[lock unlock];
}

- (void)stopFullScreenIndicatorForRoute:(id<WebApiRoute>)route {
	[lock lock];
	if ( [route.name isEqualToString:fullScreenIndicatorRouteName] ) {
		if ( fullScreenIndicatorTimer.valid ) {
			[fullScreenIndicatorTimer invalidate];
		}
		[self removeFullScreenIndictor];
	}
	[lock unlock];
}

- (void)showFullScreenIndicatorTimerDidFire:(NSTimer *)timer {
	if ( fullScreenIndicatorView ) {
		return;
	}
	
	UIView *screenView = self.window;
	
	CGSize s = screenView.bounds.size;
	
	UIView *indicatorView = [[UIView alloc] initWithFrame:screenView.bounds];
	indicatorView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.65];
	
	// add blurred background image
	UIGraphicsBeginImageContext(screenView.bounds.size);
	[screenView drawViewHierarchyInRect:screenView.bounds afterScreenUpdates:YES];
	UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	UIImageView *bgImage = [[UIImageView alloc] initWithImage:[snapshotImage applyBlurWithRadius:3
																					   tintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.65]
																		   saturationDeltaFactor:1
																					   maskImage:nil]];
	bgImage.contentMode = UIViewContentModeScaleToFill;
	[indicatorView addSubview:bgImage];

	// add spinner
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.center = CGPointMake(CGRectGetMidX(indicatorView.bounds), CGRectGetMidY(indicatorView.bounds));
	spinner.alpha = 0.0;
	[spinner startAnimating];
	[indicatorView addSubview:spinner];
	
	// add message label
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
	label.preferredMaxLayoutWidth = s.width - 40;
	label.textAlignment = NSTextAlignmentCenter;
	label.numberOfLines = 0;
	label.lineBreakMode = NSLineBreakByWordWrapping;
	label.text = [[NSBundle appStrings] stringForKeyPath:@"error.network.slow" withDefault:@"This is taking a little longer than expected. Please wait..."];
	label.textColor = [UIColor whiteColor];
	[label setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
	[indicatorView addSubview:label];
	
	// setup constraints
	[screenView addSubview:indicatorView];
	[indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(screenView);
	}];
	[bgImage mas_makeConstraints:^(MASConstraintMaker *make) {
		make.edges.equalTo(indicatorView);
	}];
	[label mas_makeConstraints:^(MASConstraintMaker *make) {
		make.left.equalTo(@20);
		make.right.equalTo(@-20);
		make.bottom.equalTo(indicatorView.mas_centerY).offset(-5);
	}];
	[spinner mas_makeConstraints:^(MASConstraintMaker *make) {
		make.top.equalTo(label.mas_bottom).offset(10);
		make.centerX.equalTo(label);
	}];
	
	// fade in
	fullScreenIndicatorView = indicatorView;
	[UIView animateWithDuration:0.35
						  delay:0.1
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 spinner.alpha = 1.0;
					 }
					 completion:NULL];
}

- (void)removeFullScreenIndictor {
	if ( fullScreenIndicatorView.superview == nil ) {
		return;
	}
	[UIView animateWithDuration:0.35
						  delay:0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 fullScreenIndicatorView.alpha = 0.0;
					 }
					 completion:^(BOOL finished) {
						 [fullScreenIndicatorView removeFromSuperview];
						 fullScreenIndicatorView = nil;
					 }
	 ];
}

@end