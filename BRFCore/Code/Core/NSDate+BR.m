//
//  Created by Shawn McKee on 2/5/15.
//
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
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

#import "NSDate+BR.h"

@implementation NSDate (BR)

+ (NSDateFormatter *)JSONTimestampDateFormatter {
	static NSDateFormatter *formatter;
	if ( formatter == nil ) {
		formatter = [NSDateFormatter new];
		[formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
		[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
		[formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
		[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
	}
	return formatter;
}

+ (NSDate *)dateWithJSONString:(NSString *)string{
    return [[NSDate JSONTimestampDateFormatter] dateFromString:string];
}

- (NSString *)JSONString {
    return [[NSDate JSONTimestampDateFormatter] stringFromDate:self];
}

@end
