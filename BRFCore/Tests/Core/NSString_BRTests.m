//
//  NSString_BRTests.m
//  BRFCore
//
//  Created by Matt on 24/09/15.
//  Copyright © 2015 Blue Rocket, Inc. All rights reserved.
//

#import "BaseTestingSupport.h"

#import "NSString+BR.h"

@interface NSString_BRTests : BaseTestingSupport

@end

@implementation NSString_BRTests

- (void)testMonthYearValid {
    NSString *pattern = @"##/####";
	assertThat([@"" numberStringFromTemplate:pattern], equalTo(@""));
	assertThat([@"1" numberStringFromTemplate:pattern], equalTo(@"1"));
	assertThat([@"12" numberStringFromTemplate:pattern], equalTo(@"12"));
	assertThat([@"123" numberStringFromTemplate:pattern], equalTo(@"12/3"));
	assertThat([@"1234" numberStringFromTemplate:pattern], equalTo(@"12/34"));
	assertThat([@"12345" numberStringFromTemplate:pattern], equalTo(@"12/345"));
	assertThat([@"123456" numberStringFromTemplate:pattern], equalTo(@"12/3456"));
	assertThat([@"1234567" numberStringFromTemplate:pattern], equalTo(@"12/3456"));

	assertThat([@"12/3" numberStringFromTemplate:pattern], equalTo(@"12/3"));
	assertThat([@"12/34" numberStringFromTemplate:pattern], equalTo(@"12/34"));
	assertThat([@"12/345" numberStringFromTemplate:pattern], equalTo(@"12/345"));
	assertThat([@"12/3456" numberStringFromTemplate:pattern], equalTo(@"12/3456"));
}

- (void)testDeleteMonthYearValues {
	NSString *pattern = @"##/####";
	assertThat([@"12/3456" numberStringByReplacingCharactersInRange:NSMakeRange(6, 1) withString:@"" template:pattern], equalTo(@"12/345"));
	assertThat([@"12/345" numberStringByReplacingCharactersInRange:NSMakeRange(5, 1) withString:@"" template:pattern], equalTo(@"12/34"));
	assertThat([@"12/34" numberStringByReplacingCharactersInRange:NSMakeRange(4, 1) withString:@"" template:pattern], equalTo(@"12/3"));
	assertThat([@"12/3" numberStringByReplacingCharactersInRange:NSMakeRange(3, 1) withString:@"" template:pattern], equalTo(@"12"));
	assertThat([@"12" numberStringByReplacingCharactersInRange:NSMakeRange(1, 1) withString:@"" template:pattern], equalTo(@"1"));
	assertThat([@"1" numberStringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"" template:pattern], equalTo(@""));
}

- (void)testFormatCurrencyAddingSingleCharacters {
	NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
	fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	fmt.numberStyle = NSNumberFormatterCurrencyStyle;
	fmt.maximumFractionDigits = 2;
	fmt.minimumFractionDigits = 2;

	NSString *result = @"";
	
	result = [result currencyStringByReplacingCharactersInRange:NSMakeRange(0, 0) withString:@"1" formatter:fmt input:nil];
	assertThat(result, equalTo(@"$0.01"));

	result = [result currencyStringByReplacingCharactersInRange:NSMakeRange(5, 0) withString:@"2" formatter:fmt input:nil];
	assertThat(result, equalTo(@"$0.12"));
	
	result = [result currencyStringByReplacingCharactersInRange:NSMakeRange(5, 0) withString:@"3" formatter:fmt input:nil];
	assertThat(result, equalTo(@"$1.23"));
	
	result = [result currencyStringByReplacingCharactersInRange:NSMakeRange(5, 0) withString:@"4" formatter:fmt input:nil];
	assertThat(result, equalTo(@"$12.34"));
	
	result = [result currencyStringByReplacingCharactersInRange:NSMakeRange(6, 0) withString:@"5" formatter:fmt input:nil];
	assertThat(result, equalTo(@"$123.45"));
	
	result = [result currencyStringByReplacingCharactersInRange:NSMakeRange(7, 0) withString:@"6" formatter:fmt input:nil];
	assertThat(result, equalTo(@"$1,234.56"));
}

- (void)testFormatCurrencyRemovingSingleCharacters {
	NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
	fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	fmt.numberStyle = NSNumberFormatterCurrencyStyle;
	fmt.maximumFractionDigits = 2;
	fmt.minimumFractionDigits = 2;
	
	NSString *result = @"$1,234.56";
	
	result = [result currencyStringByReplacingCharactersInRange:NSMakeRange(8, 1) withString:@"" formatter:fmt input:nil];
	assertThat(result, equalTo(@"$123.45"));
	
	result = [result currencyStringByReplacingCharactersInRange:NSMakeRange(6, 1) withString:@"" formatter:fmt input:nil];
	assertThat(result, equalTo(@"$12.34"));
	
	result = [result currencyStringByReplacingCharactersInRange:NSMakeRange(5, 1) withString:@"" formatter:fmt input:nil];
	assertThat(result, equalTo(@"$1.23"));
	
	result = [result currencyStringByReplacingCharactersInRange:NSMakeRange(4, 1) withString:@"" formatter:fmt input:nil];
	assertThat(result, equalTo(@"$0.12"));
	
	result = [result currencyStringByReplacingCharactersInRange:NSMakeRange(4, 1) withString:@"" formatter:fmt input:nil];
	assertThat(result, equalTo(@"$0.01"));
	
	result = [result currencyStringByReplacingCharactersInRange:NSMakeRange(4, 1) withString:@"" formatter:fmt input:nil];
	assertThat(result, equalTo(@"$0.00"));
}

- (void)testFormatCurrencyReplacingCharacters {
	NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
	fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	fmt.numberStyle = NSNumberFormatterCurrencyStyle;
	fmt.maximumFractionDigits = 2;
	fmt.minimumFractionDigits = 2;
	
	NSString *result;
	
	result = [@"$1,234.56" currencyStringByReplacingCharactersInRange:NSMakeRange(1, 1) withString:@"2" formatter:fmt input:nil];
	assertThat(result, describedAs(@"Replacing single character", equalTo(@"$2,234.56"), nil));

	result = [@"$1,234.56" currencyStringByReplacingCharactersInRange:NSMakeRange(1, 3) withString:@"" formatter:fmt input:nil];
	assertThat(result, describedAs(@"Deleting multiple characters", equalTo(@"$34.56"), nil));

	
	result = [@"$1,234.56" currencyStringByReplacingCharactersInRange:NSMakeRange(0, 9) withString:@"1,000,000" formatter:fmt input:nil];
	assertThat(result, describedAs(@"Replacing entire value", equalTo(@"$1,000,000.00"), nil));
}

- (void)testFormatCurrencyAddingNotAllowedCharacters {
	NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
	fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	fmt.numberStyle = NSNumberFormatterCurrencyStyle;
	fmt.maximumFractionDigits = 2;
	fmt.minimumFractionDigits = 2;
	
	NSString *result;
	
	result = [@"" currencyStringByReplacingCharactersInRange:NSMakeRange(0, 0) withString:@"`" formatter:fmt input:nil];
	assertThat(result, describedAs(@"Replacing empty string with single bad character", equalTo(@""), nil));
	
	result = [@"$1.00" currencyStringByReplacingCharactersInRange:NSMakeRange(4, 0) withString:@"`" formatter:fmt input:nil];
	assertThat(result, describedAs(@"Appending single bad character", equalTo(@"$1.00"), nil));
	
	result = [@"$1.00" currencyStringByReplacingCharactersInRange:NSMakeRange(1, 1) withString:@"```" formatter:fmt input:nil];
	assertThat(result, describedAs(@"Inserting multiple bad character", equalTo(@"$1.00"), nil));
}

@end
