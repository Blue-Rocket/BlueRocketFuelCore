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

@end
