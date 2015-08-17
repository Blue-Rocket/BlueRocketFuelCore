//
//  WebApiClientActivitySupport.m
//  BlueRocketFuelCore
//
//  Created by Matt on 12/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiClientActivitySupport.h"

#import "WebApiClient.h"
#import "NSBundle+BR.h"
#import "NSDictionary+BR.h"
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
	
	UIActivityIndicatorView *fullScreenSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	fullScreenSpinner.center = CGPointMake(CGRectGetMidX(fullScreenIndicatorView.bounds), CGRectGetMidY(fullScreenIndicatorView.bounds));
	fullScreenSpinner.alpha = 0.0;
	[fullScreenSpinner startAnimating];
	[indicatorView addSubview:fullScreenSpinner];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0, s.width - 40, s.height)];
	label.textAlignment = NSTextAlignmentCenter;
	label.numberOfLines = 0;
	label.text = [[NSBundle appStrings] localizedString:@"error.network.slow" withDefault:@"This is taking a little longer than expected. Please wait..."];
	[label sizeToFit];
	CGRect r = label.frame;
	r.origin.x = rintf(s.width/2 - r.size.width/2);
	r.origin.y = fullScreenSpinner.frame.origin.y - r.size.height - 20;
	label.frame = r;
	label.textColor = [UIColor whiteColor];
	[indicatorView addSubview:label];
	
	
	UIGraphicsBeginImageContext(screenView.bounds.size);
	[screenView drawViewHierarchyInRect:screenView.bounds afterScreenUpdates:YES];
	UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	indicatorView.backgroundColor = [UIColor colorWithPatternImage:[snapshotImage applyBlurWithRadius:3
																							tintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.65]
																				saturationDeltaFactor:1
																							maskImage:nil]];
	
	[screenView addSubview:indicatorView];
	fullScreenIndicatorView = indicatorView;
	[UIView animateWithDuration:0.35
						  delay:0
						options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 fullScreenSpinner.alpha = 1.0;
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