//
//  Created by Shawn McKee on 11/21/13.
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

#import "UIBarButtonItem+BR.h"
#import "NSString+BR.h"

@implementation UIBarButtonItem (BR)

- (void)awakeFromNib {
    self.title = [self.title localizedString];
}

- (CGRect)frameInView:(UIView *)v {
    
    UIView *theView = self.customView;
    if (!theView.superview && [self respondsToSelector:@selector(view)]) {
        theView = [self performSelector:@selector(view)];
    }
    
    UIView *parentView = theView.superview;
    NSArray *subviews = parentView.subviews;
    
    NSUInteger indexOfView = [subviews indexOfObject:theView];
    NSUInteger subviewCount = subviews.count;
    
    if (subviewCount > 0 && indexOfView != NSNotFound) {
        UIView *button = [parentView.subviews objectAtIndex:indexOfView];
        return [button convertRect:button.bounds toView:v];
    } else {
        return CGRectZero;
    }
}

- (UIView *)parentView {
    
    UIView *theView = self.customView;
    if (!theView.superview && [self respondsToSelector:@selector(view)]) {
        theView = [self performSelector:@selector(view)];
    }
    
    UIView *parentView = theView.superview;
    NSArray *subviews = parentView.subviews;
    
    NSUInteger indexOfView = [subviews indexOfObject:theView];
    NSUInteger subviewCount = subviews.count;
    
    if (subviewCount > 0 && indexOfView != NSNotFound) {
        UIView *button = [parentView.subviews objectAtIndex:indexOfView];
        return button;
    } else {
        return nil;
    }
}

@end
