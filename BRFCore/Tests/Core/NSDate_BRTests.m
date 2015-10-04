//
//  NSDate_BRTests.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "BaseTestingSupport.h"

#import "NSDate+BR.h"

@interface NSDate_BRTests : BaseTestingSupport

@end

@implementation NSDate_BRTests

- (void)testEncodeDate {
	NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:0]; // 1st Jan 2001
	NSString *str = [date JSONString];
	assertThat(str, equalTo(@"2001-01-01T00:00:00.000Z"));
}

- (void)testDecodeDate {
	NSDate *date = [NSDate dateWithJSONString:@"2010-01-01T00:00:00.000Z"];
	NSDate *d = [NSDate dateWithTimeIntervalSinceReferenceDate:283996800]; // 1st Jan 2010
	assertThat(date, equalTo(d));
}

@end
