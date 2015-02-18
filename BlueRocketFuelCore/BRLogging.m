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

#import "BRLogging.h"

@implementation BRLogging

+ (BOOL)shouldLogForObject:(id)object type:(NSString *)type {
    BOOL shouldLog = true;
    
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LoggingConfig" ofType:@"plist"]];
    if (config) {
        
        NSString *value = [config valueForKey:@"logAllClassesByDefault"];
        BOOL logAllClassesByDefault = true;
        if (value) logAllClassesByDefault = [value boolValue];
        
        int protocolOverrides = 0;
        int classOverrides = 0;
        
        NSDictionary *overrides = [config valueForKey:@"protocolOverrides"];
        NSEnumerator *enumerator = [overrides keyEnumerator];
        id key;
        while ((key = [enumerator nextObject])) {
            value = [overrides objectForKey:key];
            if (value) {
                if ([object conformsToProtocol:NSProtocolFromString(key)]) {
                    if (!logAllClassesByDefault && [value boolValue]) protocolOverrides++;
                    if (logAllClassesByDefault && ![value boolValue]) protocolOverrides++;
                }
            }
        }
        
        overrides = [config valueForKey:@"classOverrides"];
        Class parent = [object class];
        while (parent) {
            NSString *className = NSStringFromClass(parent);
            value = [overrides objectForKey:className];
            if (value) {
                if (!logAllClassesByDefault && [value boolValue]) classOverrides++;
                if (logAllClassesByDefault && ![value boolValue]) classOverrides++;
            }
            parent = [parent superclass];
        }
        
        if (logAllClassesByDefault) {
            if (classOverrides || protocolOverrides) shouldLog = false;
            else shouldLog = true;
        }
        else {
            if (classOverrides || protocolOverrides) shouldLog = true;
            else shouldLog = false;
        }
        
        if (shouldLog) {
            value = [config objectForKey:[NSString stringWithFormat:@"%@Logs",[type lowercaseString]]];
            if (value) {
                shouldLog = [value boolValue];
            }
        }
    }
    
    return shouldLog;
}

+ (BOOL)tagForObject:(id)object function:(const char[])function line:(int)line type:(NSString *)type {
    BOOL shouldLog = [self shouldLogForObject:object type:type];
    if (shouldLog) NSLog(@"====> %s[%d] <====",function,line);
    return shouldLog;
}

+ (BOOL)logToDoForObject:(id)object function:(const char[])function line:(int)line type:(NSString *)type message:(NSString *)format,...{
    va_list args;
    va_start(args, format);
    NSString *result = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    BOOL shouldLog = [self shouldLogForObject:object type:type];
    if (shouldLog) NSLog(@"%@ %s[%d] <==== TODO: %@",type,function,line,result);
    return shouldLog;
}

+ (BOOL)logFixMeForObject:(id)object function:(const char[])function line:(int)line type:(NSString *)type message:(NSString *)format,...{
    va_list args;
    va_start(args, format);
    NSString *result = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    BOOL shouldLog = [self shouldLogForObject:object type:type];
    if (shouldLog) NSLog(@"%@ %s[%d] <==== FIXME: %@",type,function,line,result);
    return shouldLog;
}

+ (BOOL)logForObject:(id)object function:(const char[])function line:(int)line type:(NSString *)type message:(NSString *)format,...{
    va_list args;
    va_start(args, format);
    NSString *result = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    BOOL shouldLog = [self shouldLogForObject:object type:type];
    if ([self shouldLogForObject:object type:type]) NSLog(@"%@ %s[%d]: %@",type,function,line,result);
    return shouldLog;
}

+ (BOOL)logImportantForObject:(id)object function:(const char[])function line:(int)line type:(NSString *)type message:(NSString *)format,...{
    va_list args;
    va_start(args, format);
    NSString *result = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    BOOL shouldLog = [self shouldLogForObject:object type:type];
    if ([self shouldLogForObject:object type:type]) NSLog(@"!!!!-> %@ <-!!!! %s[%d]: %@",type,function,line,result);
    return shouldLog;
}

@end
