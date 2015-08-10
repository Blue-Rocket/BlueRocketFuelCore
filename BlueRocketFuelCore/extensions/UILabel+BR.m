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

#import "UILabel+BR.h"

#import <objc/runtime.h>
#import "NSString+BR.h"
#import "UIFont+BR.h"

static IMP original_willMoveToWindow;//(id, SEL, UIWindow *);

static void brrf_willMoveToWindow(id self, SEL _cmd, UIWindow * window) {
	((void(*)(id,SEL,UIWindow *))original_willMoveToWindow)(self, _cmd, window);
	if ( ![self isKindOfClass:[UILabel class]] ) {
		// as we're swizzling a method of UIView, we may not actually be the expected object type here
		return;
	}
	NSString *orig = [self text];
	NSString *localized = [orig localizedString];
	if ( orig && ![orig isEqualToString:localized] ) {
		[self setText:localized];
	}
}

@implementation UILabel (BR)

+ (void)load {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		Class class = [self class];
		
		SEL originalSelector = @selector(willMoveToWindow:);
		
		Method originalMethod = class_getInstanceMethod(class, originalSelector);
		original_willMoveToWindow = method_setImplementation(originalMethod, (IMP)brrf_willMoveToWindow);
	});
}

- (void)setText:(NSString *)text withHTMLFormatting:(NSURL *)htmlURL {
    NSMutableAttributedString *stringWithHTMLAttributes = [[NSMutableAttributedString alloc] initWithFileURL:htmlURL
                                                                                                     options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType}
                                                                                          documentAttributes:nil
                                                                                                       error:nil];
    
    [stringWithHTMLAttributes.mutableString setString:text];
    self.attributedText = stringWithHTMLAttributes;
}

- (void)boldSubstring:(NSString *)substring {
    UIFont *regularFont = self.font;
    UIFont *boldFont = self.font.bold;
    UIColor *foregroundColor = self.textColor;
    
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           regularFont, NSFontAttributeName,
                           foregroundColor, NSForegroundColorAttributeName, nil];
    NSDictionary *subAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              boldFont, NSFontAttributeName, nil];
    const NSRange range = [self.text rangeOfString:substring];
    
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString:self.text
                                           attributes:attrs];
    [attributedText setAttributes:subAttrs range:range];
    
    [self setAttributedText:attributedText];
}

@end
