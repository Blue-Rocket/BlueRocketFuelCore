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

#import <Foundation/Foundation.h>

@interface NSString (BR)


+ (NSString *)commaSeparatedStringFromArray:(NSArray *)array;
+ (NSString *)commaSeparatedStringFromArray:(NSArray *)array prefixSymbol:(NSString *)symbol;
- (NSMutableArray *)arrayFromCommaSeparatedList;

/**
 Localize the receiver by replacing template strings in the form of @c {keyPath} with a localized 
 mapping of @c keyPath from the standard application JSON strings resource.
 
 @return Localized copy of the receiver, or the reciever if a localization is not available.
 */
- (NSString *)localizedString;

/**
 Localize the receiver by replacing template strings in the form of @c {keyPath} with a localized
 mapping of @c keyPath from a specific application JSON strings resource.
 
 @param strings The application strings.
 @return Localized copy of the receiver, or the reciever if a localization is not available.
 */
- (NSString *)localizedStringWithAppStrings:(NSDictionary *)strings;

- (BOOL)isValidEmailFormat;
- (NSString *)stringAsNumeralsOnly;
- (NSString *)stringFormatedAsPhoneNumber;
- (NSString *)MD5String;
- (NSString *)capitalizedFirstLetter;

@end
