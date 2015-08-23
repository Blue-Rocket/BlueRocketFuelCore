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

#import "BRJSON.h"

@interface BRJSON() {
}
@property (nonatomic, strong) id values;
@property (nonatomic, strong) id defaults;
@end

@implementation BRJSON

+ (BRJSON *)objectFromFilePath:(NSString *)filePath {
    NSString *string = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    BRJSON *object = [self objectFromString:string];
    object.filePath = filePath;
    return object;
}

+ (BRJSON *)objectFromResourceFile:(NSString *)fileName {
	
	NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
	if (path) {
		BRJSON *object = [self objectFromFilePath:path];
        path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.defaults",fileName] ofType:@"json"];
        if (path) {
            BRJSON *defaultsObject = [self objectFromFilePath:path];
            object.defaults = defaultsObject.values;
        }
        return object;
    }
    else {
        path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.defaults",fileName] ofType:@"json"];
        if (path) {
            BRJSON *object = [self objectFromFilePath:path];
            return object;
        }
    }
	return nil;
}


+ (BRJSON *)objectFromString:(NSString *)string {
    if (!string) string = @"{}";

    BRJSON *newInstance = [[self alloc] init];

    NSError *error;
    newInstance.values = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding]
                                                         options:(NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves) error:&error];
    if ([newInstance.values isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = (NSDictionary *)newInstance.values;
        if (!dictionary.count) newInstance.values = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    newInstance.defaults = nil;
    return newInstance;
}


+ (BRJSON *)objectFromDictionary:(NSDictionary *)aDictionary {
	BRJSON *newInstance = [[self alloc] init];
    newInstance.values = aDictionary;
    newInstance.defaults = nil;
	return newInstance;
}

+ (BRJSON *)objectFromData:(NSData *)data {
    BRJSON *newInstance = [[self alloc] init];
    NSError *error;
    newInstance.values = [NSJSONSerialization JSONObjectWithData:data
                                                         options:(NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves) error:&error];
    newInstance.defaults = nil;
    return newInstance;
}

- (BOOL)isEmpty {
    if ([self.values isKindOfClass:[NSDictionary class]]) return ([self.values count] == 0 && [self.defaults count] == 0);
    if ([self.values isKindOfClass:[NSArray class]]) return ([self.values count] == 0 && [self.defaults count] == 0);
    return true;
}

- (UIColor*)colorFromHex:(NSString *)hex {
    NSString *hexColor = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];  

    if ([hexColor length] < 6)
        return [UIColor blackColor];
    if ([hexColor hasPrefix:@"#"])
        hexColor = [hexColor substringFromIndex:1];  
    if ([hexColor length] != 6 && [hexColor length] != 8)
        return [UIColor blackColor];
    
    NSRange range;  
    range.location = 0;  
    range.length = 2; 
    
    NSString *rString = [hexColor substringWithRange:range];  
    
    range.location = 2;  
    NSString *gString = [hexColor substringWithRange:range];  
    
    range.location = 4;  
    NSString *bString = [hexColor substringWithRange:range];  
    
    range.location = 6;
    NSString *aString = @"FF";
    if ([hexColor length] == 8)
        aString = [hexColor substringWithRange:range];

    unsigned int r, g, b, a;  
    [[NSScanner scannerWithString:rString] scanHexInt:&r];  
    [[NSScanner scannerWithString:gString] scanHexInt:&g];  
    [[NSScanner scannerWithString:bString] scanHexInt:&b];  
    [[NSScanner scannerWithString:aString] scanHexInt:&a];  
    
    return [UIColor colorWithRed:((float) r / 255.0f)  
                           green:((float) g / 255.0f)  
                            blue:((float) b / 255.0f)  
                           alpha:((float) a / 255.0f)];
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
	NSArray *array = [keyPath componentsSeparatedByString:@"."];
	int i;
    if (!self.values) self.values = [NSMutableDictionary dictionaryWithCapacity:5];
	id d = self.values;
    NSMutableDictionary *current;
    NSString *key;
	for (i = 0; i < array.count; i++) {
        key = [array objectAtIndex:i];
        current = d;
		d = [d objectForKey:key];
        if (!d) {
            d = [NSMutableDictionary dictionaryWithCapacity:5];
            [current setObject:d forKey:key];
        }
    }
    [current setObject:value forKey:key];
}

- (id)get:(NSString *)identifier {

	NSArray *array = [identifier componentsSeparatedByString:@"."];
	int i;
	id d = self.values;
	for (i = 0; i < array.count; i++) {
		d = [d objectForKey:[array objectAtIndex:i]];
        if (!d) break;
    }
    
    if (!d && self.defaults) {
        array = [identifier componentsSeparatedByString:@"."];
        d = self.defaults;
        for (i = 0; i < array.count; i++) {
            d = [d objectForKey:[array objectAtIndex:i]];
            if (!d) break;
        }
    }

	if ([d isKindOfClass:[NSString class]]) {
		NSString *string = (NSString *)d;
		NSRange range = [string rangeOfString:@"#"];
		if (range.length && range.location == 0) {
			return [self colorFromHex:string];
        }
		range = [string rangeOfString:@"0x"];
		if (range.length && range.location == 0) {
			string = [NSString stringWithFormat:@"#%@",[string substringFromIndex:2]];
			return [self colorFromHex:string];
        }
		range = [string rangeOfString:@"RGBA:"];
		if (range.length && range.location == 0) {
			string = [string substringFromIndex:5];
			NSArray *c = [string componentsSeparatedByString:@","];
			if (c.count < 3) return d;
			float r = [[c objectAtIndex:0] floatValue];
			float g = [[c objectAtIndex:1] floatValue];
			float b = [[c objectAtIndex:2] floatValue];
			float a = 255;
			if (c.count == 4) a = [[c objectAtIndex:3] floatValue];
			return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0];
        }
    }
	return d;
}

- (id)object {
    return _values;
}

- (BOOL)intValueFor:(NSString *)identifier {
    return [[self get:identifier] intValue];
}

- (BOOL)booleanValueFor:(NSString *)identifier {
    return [[self get:identifier] boolValue];
}

- (NSString *)asString {
    NSError *error;
    //NSData *data = [NSJSONSerialization dataWithJSONObject:self.values options:NSJSONWritingPrettyPrinted error:&error];
    NSData *data = [NSJSONSerialization dataWithJSONObject:self.values options:0 error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)save {
    if (self.filePath) {
        NSString *filePath = [self.filePath stringByExpandingTildeInPath];
        NSString *dir = [filePath stringByDeletingLastPathComponent];
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&error];
        [[self asString] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (id)init {
    self = [super init];
    return self;
}



@end
