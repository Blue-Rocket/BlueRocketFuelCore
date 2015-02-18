//
//  Created by Shawn McKee on 12/9/13.
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

#import <CommonCrypto/CommonDigest.h>
#import "NSString+BR.h"
#import "BRAppDelegate.h"
#import "NSDictionary+BR.h"

@implementation NSString (BR)

- (NSString *)localizedString {
    NSString *finalString = self;
    NSString *string = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!string.length || string.length == 1) return self;
    if ([string characterAtIndex:0] == '{' && [string characterAtIndex:string.length-1] == '}') {
        NSString *key = [string substringWithRange:NSMakeRange(1, string.length-2)];
        string = [BRApp.strings localizedString:key];
        if ([string isEqualToString:key]) finalString = self;
        else if (string && [string isKindOfClass:[NSString class]]) finalString = string;
    }
    return finalString;
}

- (NSString *)stringAsNumeralsOnly {
    NSMutableString *numeralsOnly = [[NSMutableString alloc] init];
    if (self.length) {
        for (int i = 0; i < self.length; i++) {
            unichar c = [self characterAtIndex:i];
            if (c >= '0' && c <= '9') [numeralsOnly appendFormat:@"%c",c];
        }
    }
    return numeralsOnly;
}

- (NSString *)capitalizedFirstLetter {
    if (!self.length) return self;
    NSString *string = [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self substringToIndex:1] capitalizedString]];
    return string;
}

- (BOOL)isValidEmailFormat {
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (NSString *)stringFormatedAsPhoneNumber {
    
    NSArray *usFormats = [NSArray arrayWithObjects:
                          
                          @"+1 (###) ###-####",
                          
                          @"1 (###) ###-####",
                          
                          @"011 $",
                          
                          @"###-####",
                          
                          @"(###) ###-####", nil];
    if(usFormats == nil) return self;
    
    NSString *output = [self stringAsNumeralsOnly];
    
    for(NSString *phoneFormat in usFormats) {
        
        int i = 0;
        
        NSMutableString *temp = [[NSMutableString alloc] init];
        
        for(int p = 0; temp != nil && i < [output length] && p < [phoneFormat length]; p++) {
            
            char c = [phoneFormat characterAtIndex:p];
            
            BOOL required = [self canBeInputByPhonePad:c];
            
            char next = [output characterAtIndex:i];
            
            switch(c) {
                    
                case '$':
                    
                    p--;
                    
                    [temp appendFormat:@"%c", next]; i++;
                    
                    break;
                    
                case '#':
                    
                    if(next < '0' || next > '9') {
                        
                        temp = nil;
                        
                        break;
                        
                    }
                    
                    [temp appendFormat:@"%c", next]; i++;
                    
                    break;
                    
                default:
                    
                    if(required) {
                        
                        if(next != c) {
                            
                            temp = nil;
                            
                            break;
                            
                        }
                        
                        [temp appendFormat:@"%c", next]; i++;
                        
                    } else {
                        
                        [temp appendFormat:@"%c", c];
                        
                        if(next == c) i++;
                        
                    }
                    
                    break;
                    
            }
            
        }
        
        if(i == [output length]) {
            
            return temp;
            
        }
        
    }
    
    return output;
    
}



- (BOOL)canBeInputByPhonePad:(char)c {
    
    if(c == '+' || c == '*' || c == '#') return YES;
    
    if(c >= '0' && c <= '9') return YES;
    
    return NO;
    
}

- (NSString *)MD5String {
    const char *cstr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

@end
