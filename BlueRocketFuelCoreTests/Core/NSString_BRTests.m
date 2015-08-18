//
//  NSString_BRTests.m
//  BlueRocketFuelCore
//
//  Created by Matt on 18/08/15.
//  Copyright (c) 2015 Blue Rocket. All rights reserved.
//

#import "BaseTestingSupport.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#import "NSString+BR.h"

@interface NSString_BRTests : BaseTestingSupport

@end

@implementation NSString_BRTests {
	NSDictionary *strings;
}

- (void)setUp {
	[super setUp];
	strings = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[self.bundle pathForResource:@"strings.json" ofType:nil]] options:0 error:nil];
}

- (void)testLocalize {
	NSString *loc = [@"{error.general}" localizedStringWithAppStrings:strings];
	assertThat(loc, equalTo(@"This is a general error: %@"));
}

- (void)testLocalizeMoreNested {
	NSString *loc = [@"{error.specific.ouch}" localizedStringWithAppStrings:strings];
	assertThat(loc, equalTo(@"Ouch, that hurt."));
}

- (void)testLocalizeMissing {
	NSString *loc = [@"{error.doesNotExist}" localizedStringWithAppStrings:strings];
	assertThat(loc, equalTo(@"{error.doesNotExist}"));
}

- (void)testLocalizeObject {
	NSString *loc = [@"{error.specific}" localizedStringWithAppStrings:strings];
	assertThat(loc, equalTo(@"{error.specific}"));
}

- (void)testLocalizeMissingEndBrace {
	NSString *loc = [@"{error.general" localizedStringWithAppStrings:strings];
	assertThat(loc, equalTo(@"{error.general"));
}

- (void)testLocalizeMissingStartBrace {
	NSString *loc = [@"error.general}" localizedStringWithAppStrings:strings];
	assertThat(loc, equalTo(@"error.general}"));
}

- (void)testLocalizeMissingBraces {
	NSString *loc = [@"error.general" localizedStringWithAppStrings:strings];
	assertThat(loc, equalTo(@"error.general"));
}

@end
