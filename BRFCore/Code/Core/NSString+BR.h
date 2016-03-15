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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BRStringLink;

@interface NSString (BR)

+ (NSString *)commaSeparatedStringFromArray:(NSArray *)array;
+ (NSString *)commaSeparatedStringFromArray:(NSArray *)array prefixSymbol:(nullable NSString *)symbol;
- (NSMutableArray *)arrayFromCommaSeparatedList;

- (BOOL)isValidEmailFormat;
- (NSString *)stringAsNumeralsOnly;
- (NSString *)stringFormatedAsPhoneNumber;
- (NSString *)MD5String;
- (NSString *)capitalizedFirstLetter;

/// -----
/// @name Validation
/// -----

/**
 Test if the receiver is a valid phone number for a given locale.
 
 @param locale The locale to test, or @c nil for the current locale.
 @return @c YES if the reciever appears to be a valid phone number for the given locale.
 */
- (BOOL)isValidPhoneNumberForLocale:(nullable NSLocale *)locale;

/**
 Test if the receiver has a valid email address syntax.
 
 @return @c YES if the receiver has a valid email syntax.
 */
- (BOOL)isValidEmailAddress;

/// -----
/// @name Formatting
/// -----

/**
 Format the receiver as as string of numbers using a template pattern.
 
 This method will look for number characters to "fill in" a pattern where @c # represents a placeholder for a digit
 in the output string.
 
 @param pattern A pattern template, where the @c # character represents a number to fill in from the receiver
                and any other character is added to the output string as-is.
 
 @return The formatted string.
 */
- (NSString *)numberStringFromTemplate:(NSString *)pattern;

/**
 Replace a range of characters with a given string using a number template pattern.
 
 @param range  The range of characters in the receiver to replace.
 @param string The string to replace with.
 @param filter The pattern template, where the @c # character represents a number to fill in from the receiver, after
               updating the characters.
 
 @return The resulting formatted string.
 */
- (NSString *)numberStringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)string template:(NSString *)filter;

/**
 Generate a new string by deleting all occurrences of any character in a set.
 
 @param set The set of characters to delete from the receiver.
 
 @return The resulting string.
 */
- (NSString *)stringByDeletingCharactersFromSet:(NSCharacterSet *)set;

/**
 Replace a range of characters in the receiver and format the result as a currency string.
 
 @param range           The range of characters in the receiver to replace.
 @param string          The string to replace with.
 @param numberFormatter The number formatter, assumed to be using @c NSNumberFormatterCurrencyStyle.
 @param textField       An optional text input to adjust the selection range on.
 
 @return The resulting string.
 */
- (NSString *)currencyStringByReplacingCharactersInRange:(NSRange)range
											  withString:(NSString *)string
											   formatter:(NSNumberFormatter *)numberFormatter
												   input:(nullable id<UITextInput>)textField;

/**
 Replace Markdown style links with their link text and provide an array of @c BRStringLink objects for any discovered link.
 
 @param links The discovered links will be returned here.
 
 @return The string after replacing all discovered links with just the link text.
 */
- (NSString *)stringByExtractingMarkdownLinks:(NSArray<id<BRStringLink>> * __autoreleasing _Nullable * _Nullable)links;

/**
 Create an attributed string by replacing simple markup with attributes. Supported markup is:
 
  1. *bold*
  2. _italic_
  3. ~underline~
 
 @return An attributed version of the receiver.
 */
- (NSAttributedString *)attributedStringByReplacingMarkup;

/**
 Return a plain-text string with all markup removed. For example a string like `Make *it* so.` would result in `Make it so.`
 
 @return The string without any markup.
 */
- (NSString *)stringByRemovingMarkup;

@end

#pragma mark - BRStringLink

/**
 A discovered link within a string.
 */
@protocol BRStringLink <NSObject>

/** The range for this link. */
@property (nonatomic, readonly) NSRange range;

/** A reference style link value. Either this or @c url will be available. */
@property (nonatomic, readonly, nullable) NSString *reference;

/** A URL style link value. Either this or @c reference will be avaiable. */
@property (nonatomic, readonly, nullable) NSURL *url;

@end

NS_ASSUME_NONNULL_END
