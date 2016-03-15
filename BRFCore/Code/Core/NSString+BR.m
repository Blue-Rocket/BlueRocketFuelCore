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

#import "NSString+BR.h"

#import <BRCocoaLumberjack/BRCocoaLumberjack.h>
#import <BREnvironment/BREnvironment.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreText/CoreText.h>
#import "NSBundle+BR.h"

static NSRegularExpression *kValidEmailRegex = nil;
static NSMutableDictionary *kPhoneRegexes = nil;
static NSCharacterSet *NumbersOnlyCharacterSet = nil;

static inline NSRegularExpression * MarkdownReferenceLinkRegularExpression() {
	static NSRegularExpression *_mdLinkRegularExpression = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// regex matches links link [link][ref]
		_mdLinkRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"\\[([^\\]]+)\\]\\[([^\\]]+)\\]" options:NSRegularExpressionCaseInsensitive error:nil];
	});
	
	return _mdLinkRegularExpression;
}

@interface BRSimpleStringLink : NSObject <BRStringLink>

- (instancetype)initWithRange:(NSRange)range reference:(NSString *)reference;
- (instancetype)initWithRange:(NSRange)range URL:(NSURL *)url;

@end

@implementation NSString (BR)

- (BOOL)isValidEmailAddress {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// RegEx adapted from http://www.cocoawithlove.com/2009/06/verifying-that-string-is-email-address.html
		kValidEmailRegex = [[NSRegularExpression alloc] initWithPattern:
							@"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
							@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
							@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
							@"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
							@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
							@"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
							@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
														  options:NSRegularExpressionCaseInsensitive
																  error:nil];
	});
	NSUInteger count = [kValidEmailRegex numberOfMatchesInString:self options:NSMatchingAnchored range:NSMakeRange(0, [self length])];
	return (count > 0);
}

+ (NSRegularExpression *)phoneRegexForLocale:(NSLocale *)locale {
	NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
	if ( !countryCode ) {
		countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
	}
	if ( !countryCode ) {
		return nil;
	}
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		kPhoneRegexes = [[NSMutableDictionary alloc] initWithCapacity:2];
	});
	NSRegularExpression *result = kPhoneRegexes[countryCode];
	if ( result ) {
		return result;
	}
	
	// look up validation regex in environment config
	NSString *key = [NSString stringWithFormat:@"validation.phone.%@.regex", countryCode];
	NSString *pat = [BREnvironment sharedEnvironment][key];
	if ( !pat && [countryCode isEqualToString:@"US"] ) {
		// provide a default pattern for US locale
		pat = @"(?:\\+?\\D*1)?([2-9]\\d{2})\\D*([2-9]\\d{2})\\D*(\\d{4})";
	}
	if ( pat ) {
		NSError *error = nil;
		result = [[NSRegularExpression alloc] initWithPattern:pat options:0 error:&error];
		if ( !result ) {
			DDLogError(@"Error compiling phone validation regex for key %@: %@", key, [error localizedDescription]);
		}
	}
	return result;
}

- (BOOL)isValidPhoneNumberForLocale:(NSLocale *)locale {
	NSUInteger count = [[NSString phoneRegexForLocale:locale] numberOfMatchesInString:self options:0 range:NSMakeRange(0, [self length])];
	return (count > 0);
}

+ (NSString *)commaSeparatedStringFromArray:(NSArray *)array {
    return [self commaSeparatedStringFromArray:array prefixSymbol:nil];
}

+ (NSString *)commaSeparatedStringFromArray:(NSArray *)array prefixSymbol:(NSString *)symbol {
    NSMutableString *list = [[NSMutableString alloc] init];
    for (int i = 0; i < array.count; i++) {
        if (symbol) {
            if (i != 0) [list appendString:@" "];
            [list appendString:symbol];
        }
        [list appendString:[array objectAtIndex:i]];
        if (i+1 < array.count) [list appendString:@","];
    }
    return list;
}

- (NSMutableArray *)arrayFromCommaSeparatedList {
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSString *s = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    for (NSString *item in [s componentsSeparatedByString:@","]) {
        NSString *i = [item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (i.length) [list addObject:i];
    }
    return list;
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

+ (NSCharacterSet *)numbersOnlyCharacterSet {
	NSCharacterSet *set = NumbersOnlyCharacterSet;
	if ( !set ) {
		set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
		NumbersOnlyCharacterSet = set;
	}
	return set;
}

- (NSString *)numberStringFromTemplate:(NSString *)filter {
	NSUInteger onOriginal = 0, onFilter = 0, onOutput = 0;
	const NSUInteger maxFilter = filter.length;
	const NSUInteger maxOriginal = self.length;
	unichar outputString[maxFilter];
	
	NSCharacterSet *numbersOnlySet = [NSString numbersOnlyCharacterSet];
	
	while ( onFilter < maxFilter && onOriginal < maxOriginal ) {
		unichar filterChar = [filter characterAtIndex:onFilter];
		unichar originalChar = [self characterAtIndex:onOriginal];
		if ( filterChar == '#' ) {
			if ( [numbersOnlySet characterIsMember:originalChar] ) {
				outputString[onOutput] = originalChar;
				onOriginal++;
				onFilter++;
				onOutput++;
			} else {
				onOriginal++;
			}
		} else {
			outputString[onOutput] = filterChar;
			onOutput++;
			onFilter++;
			if ( originalChar == filterChar ) {
				onOriginal++;
			}
		}
	}
	return [NSString stringWithCharacters:outputString length:onOutput];
}

- (NSString *)numberStringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)string template:(NSString *)filter {
	NSString *changedString = [[self stringByReplacingCharactersInRange:range withString:string] numberStringFromTemplate:filter];
	if ( range.length > string.length ) {
		// deleted some characters: remove any non-digit values from end of changed string to allow deleting backwards
		NSCharacterSet *numbersOnlySet = [NSString numbersOnlyCharacterSet];
		while ( changedString.length > 0 && [numbersOnlySet characterIsMember:[changedString characterAtIndex:(changedString.length - 1)]] == NO ) {
			changedString = [changedString substringToIndex:(changedString.length - 1)];
		}
	}
	return changedString;
}

- (NSString *)stringByDeletingCharactersFromSet:(NSCharacterSet *)set {
	NSString *result = [self stringByTrimmingCharactersInSet:set]; // in case of single unallowed character
	if ( result.length ) {
		// zap characters from middle of string
		result = [[self componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
	}
	return result;
}

- (NSString *)currencyStringByReplacingCharactersInRange:(NSRange)range withString:(NSString *)string formatter:(NSNumberFormatter *)numberFormatter input:(id<UITextInput>)textField {
	NSCharacterSet *allowedCharacters = [NSString numbersOnlyCharacterSet];
	NSString *replacementString = string;
	if ( string.length > 1 ) {
		NSMutableCharacterSet *allowedToBePastedSet = [allowedCharacters mutableCopy];
		[allowedToBePastedSet addCharactersInString:numberFormatter.decimalSeparator];
		replacementString = [replacementString stringByDeletingCharactersFromSet:[allowedToBePastedSet invertedSet]];
		NSDecimalNumber *numberPasted = [NSDecimalNumber decimalNumberWithString:replacementString];
		if ( !numberPasted || [numberPasted isEqualToNumber:[NSDecimalNumber notANumber]] ) {
			return self;
		}
		replacementString = [numberFormatter stringFromNumber:numberPasted];
	}
	
	UITextRange *selectedRange = [textField selectedTextRange];
	UITextPosition *start = textField.beginningOfDocument;
	NSInteger cursorOffset = [textField offsetFromPosition:start toPosition:selectedRange.start];
	
	NSUInteger textFieldTextStrLength = self.length;
	
	NSString *textFieldTextStr = [[self stringByReplacingCharactersInRange:range withString:replacementString]
								  stringByDeletingCharactersFromSet:[allowedCharacters invertedSet]];
	
	NSString *result = self;
	if ( textFieldTextStr.length > 0 && textFieldTextStr.length <= (numberFormatter.maximumIntegerDigits + numberFormatter.maximumFractionDigits) ) {
		NSDecimalNumber *textFieldTextNum = [NSDecimalNumber decimalNumberWithString:textFieldTextStr];
		if ( textFieldTextNum && ![textFieldTextNum isEqualToNumber:[NSDecimalNumber notANumber]] ) {
			NSDecimalNumber *divideByNum = [[[NSDecimalNumber alloc] initWithInt:10] decimalNumberByRaisingToPower:numberFormatter.maximumFractionDigits];
			NSDecimalNumber *textFieldTextNewNum = [textFieldTextNum decimalNumberByDividingBy:divideByNum];
			NSString *textFieldTextNewStr = [numberFormatter stringFromNumber:textFieldTextNewNum];
			
			result = textFieldTextNewStr;
			
			if ( cursorOffset != textFieldTextStrLength ) {
				NSInteger lengthDelta = textFieldTextNewStr.length - textFieldTextStrLength;
				NSInteger newCursorOffset = MAX(0, MIN(textFieldTextNewStr.length, cursorOffset + lengthDelta));
				UITextPosition* newPosition = [textField positionFromPosition:textField.beginningOfDocument offset:newCursorOffset];
				UITextRange* newRange = [textField textRangeFromPosition:newPosition toPosition:newPosition];
				[textField setSelectedTextRange:newRange];
			}
		}
	}
	
	return result;
}

#pragma mark - Markup support

- (NSString *)stringByExtractingMarkdownLinks:(NSArray<id<BRStringLink>> * _Nullable __autoreleasing * _Nullable)links {
	// first create our actual label value by replacing MD style ref links [link][action] with just "link" and capturing the range of that link, and it's action, to add as a URL attribute later
	// TODO: handle URL link style; at the moment only reference link style supported
	
	NSMutableArray<id<BRStringLink>> *linkData = [[NSMutableArray alloc] initWithCapacity:4];
	NSRegularExpression *regex = MarkdownReferenceLinkRegularExpression();
	NSMutableString *replaced = [[NSMutableString alloc] initWithCapacity:self.length];
	
	__block NSUInteger endOfPreviousMatch = 0;
	[regex enumerateMatchesInString:self options:0 range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange matchRange = [result range];
		[replaced appendString:[self substringWithRange:NSMakeRange(endOfPreviousMatch, matchRange.location - endOfPreviousMatch)]];
		NSString *linkText = [self substringWithRange:[result rangeAtIndex:1]];
		NSString *reference = [self substringWithRange:[result rangeAtIndex:2]];
		NSRange linkRange = NSMakeRange(replaced.length, linkText.length);
		[linkData addObject:[[BRSimpleStringLink alloc] initWithRange:linkRange reference:reference]];
		[replaced appendString:linkText];
		endOfPreviousMatch = matchRange.location + matchRange.length;
	}];
	if ( endOfPreviousMatch < self.length ) {
		// add last bit of string
		[replaced appendString:[self substringFromIndex:endOfPreviousMatch]];
	}
	
	if ( links ) {
		*links = linkData;
	}
	
	return replaced;
}

typedef NS_OPTIONS(int, BRMarkupType) {
	BRMarkupTypeNone		= 0,
	BRMarkupTypeBold		= (1 << 0),
	BRMarkupTypeItalic		= (1 << 1),
	BRMarkupTypeUnderline	= (1 << 2),
};

+ (NSDictionary *)attributesForMarkupType:(BRMarkupType)type {
	CTFontSymbolicTraits traits = 0;
	CTUnderlineStyle underlineStyle = kCTUnderlineStyleNone;
	NSMutableDictionary *result = [NSMutableDictionary new];
	if ( (type & BRMarkupTypeBold) == BRMarkupTypeBold ) {
		traits |= kCTFontBoldTrait;
	}
	if ( (type & BRMarkupTypeItalic) == BRMarkupTypeItalic ) {
		traits |= kCTFontItalicTrait;
	}
	if ( traits != 0 ) {
		result[(id)kCTFontSymbolicTrait] = @(traits);
	}

	if ( (type & BRMarkupTypeUnderline) == BRMarkupTypeUnderline ) {
		underlineStyle = kCTUnderlineStyleSingle;
	}
	if ( underlineStyle != kCTUnderlineStyleNone ) {
		result[(id)kCTUnderlineStyleAttributeName] = @(underlineStyle);
	}
	
	if ( [result count] < 1 ) {
		result = nil;
	}
	return result;
}

+ (BRMarkupType)markupTypeForStyleKey:(NSString *)key {
	BRMarkupType result = BRMarkupTypeNone;
	if ( [key isEqualToString:@"*"] ) {
		result = BRMarkupTypeBold;
	} else if ( [key isEqualToString:@"_"] ) {
		result = BRMarkupTypeItalic;
	} else if ( [key isEqualToString:@"~"] ) {
		result = BRMarkupTypeUnderline;
	}
	return result;
}

- (NSString *)stringByRemovingMarkup {
	return [[self attributedStringByReplacingMarkup] string];
}

static NSUInteger kMarkupMatchIndex = 1;

- (NSAttributedString *)attributedStringByReplacingMarkup {
	static NSRegularExpression *regex = nil;
	if ( regex == nil ) {
		regex = [NSRegularExpression regularExpressionWithPattern:@"([*_~])(.+?)\\1" options:0 error:nil];
	}
	NSMutableAttributedString *string = [NSMutableAttributedString new];
	__block NSUInteger endOfPreviousMatch = 0;
	[regex enumerateMatchesInString:self options:0 range:NSMakeRange(0, [self length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
		NSRange matchRange = [result range];
		NSString *text = [self substringWithRange:NSMakeRange(endOfPreviousMatch, matchRange.location - endOfPreviousMatch)];
		[string appendAttributedString:[[NSAttributedString alloc] initWithString:text]];
		NSString *style = [self substringWithRange:[result rangeAtIndex:kMarkupMatchIndex]];
		// remove the markup from the text
		text = [self substringWithRange:[result rangeAtIndex:(kMarkupMatchIndex + 1)]];
		BRMarkupType type = [NSString markupTypeForStyleKey:style];
		NSDictionary *attributes = [NSString attributesForMarkupType:type];
		[string appendAttributedString:[[NSAttributedString alloc] initWithString:text attributes:attributes]];
		endOfPreviousMatch = matchRange.location + matchRange.length;
	}];
	if ( endOfPreviousMatch < [self length] ) {
		// add last bit of string
		[string appendAttributedString:[[NSAttributedString alloc] initWithString:[self substringFromIndex:endOfPreviousMatch]]];
	}
	return string;
}


@end

@implementation BRSimpleStringLink {
	NSRange range;
	NSString *reference;
	NSURL *url;
}

@synthesize range, reference, url;

- (instancetype)initWithRange:(NSRange)theRange reference:(NSString *)theReference {
	if ( (self = [super init]) ) {
		range = theRange;
		reference = theReference;
	}
	return self;
}

- (instancetype)initWithRange:(NSRange)theRange URL:(NSURL *)theUrl {
	if ( (self = [super init]) ) {
		range = theRange;
		url = theUrl;
	}
	return self;
}

@end