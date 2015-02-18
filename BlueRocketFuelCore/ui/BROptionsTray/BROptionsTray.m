//
//  Created by Shawn McKee on 1/28/15.
//
//  Copyright (c) 2015 Blue Rocket, Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "BROptionsTray.h"

typedef void (^CompletionBlock)();

@interface BROptionsTray ()
@property (nonatomic, weak) UINavigationController *parentNavigationController;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CAGradientLayer *gradient;
@property (nonatomic, strong) CompletionBlock hideCompletionBlock;
@end

@implementation BROptionsTray

#pragma mark - Show and Hide

- (void)showForViewController:(UIViewController *)viewController {
    self.parentNavigationController = viewController.navigationController;
    self.view.frame = self.parentNavigationController.view.bounds;
    
    [self viewWillAppear:YES];
    
    CGRect vr = self.view.bounds;
    CGRect rr = self.view.bounds;
    rr.size.width = rr.size.width * 2;
    
    [self.parentNavigationController.view addSubview:self.view];
    
    self.imageView = [[UIImageView alloc] initWithFrame:rr];
    self.imageView.backgroundColor = [UIColor clearColor];
    
    UIGraphicsBeginImageContextWithOptions(rr.size, NO, 0);
    [self.parentNavigationController.view drawViewHierarchyInRect:vr afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.imageView.frame = rr;
    self.imageView.image = image;
    [self.view addSubview:self.imageView];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.imageView.bounds];
    self.imageView.layer.masksToBounds = NO;
    self.imageView.layer.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1].CGColor;
    self.imageView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.imageView.layer.shadowOpacity = 0.25f;
    self.imageView.layer.shadowRadius = 8;
    self.imageView.layer.shadowPath = shadowPath.CGPath;
    
    self.gradient = [CAGradientLayer layer];
    self.gradient.frame = self.imageView.bounds;
    self.gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2] CGColor], (id)[[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0] CGColor], nil];
    self.gradient.startPoint = CGPointMake(0,0);
    self.gradient.endPoint = CGPointMake(0.4,0);
    [self.imageView.layer insertSublayer:self.gradient atIndex:0];
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    animation.fromValue = @(0);
    animation.toValue = @(0.65);//@(2 * M_PI);
    animation.repeatCount = 1;
    animation.duration = 0.35;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fillMode = kCAFillModeForwards;
    [self.imageView.layer addAnimation:animation forKey:@"rotation"];
    
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CATransform3D transform = CATransform3DIdentity;
                         transform.m34 = 1.0 / 500.0;
                         transform = CATransform3DScale(transform, 0.9, 0.9, 0.9);
                         transform = CATransform3DTranslate(transform, -12, 0, 0);
                         self.imageView.layer.transform = transform;
                     }
                     completion:^(BOOL finished) {
                     }
     ];
    
    
    CGFloat shift = vr.size.width - (vr.size.width * 0.65);
    vr.origin.x += shift;
    vr.size.width -= shift;
    UIButton *button = [[UIButton alloc] initWithFrame:vr];
    [button addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}

- (void)hide {
    [self hideWithCompletion:^{
    }];
}

- (void)hideWithCompletion:(void (^)())completion {
    
    [self viewWillDisappear:YES];
    
    self.hideCompletionBlock = completion;
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
    animation.fromValue = @(0.65);
    animation.toValue = @(0);
    animation.repeatCount = 1;
    animation.duration = .15;
    animation.removedOnCompletion = NO;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    [self.imageView.layer addAnimation:animation forKey:@"rotation"];
    
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / 500.0;
    transform = CATransform3DScale(transform, 1, 1, 1);
    transform = CATransform3DTranslate(transform, 0, 0, 0);
    self.imageView.layer.transform = transform;
    
    [self.gradient removeFromSuperlayer];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
    [self.view removeFromSuperview];
    if (self.hideCompletionBlock) self.hideCompletionBlock();
}

@end
