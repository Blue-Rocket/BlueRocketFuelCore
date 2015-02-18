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

#define BRLogType           @"INFO"
#define BRTagLogType        @"TAG"
#define BRToDoLogType       @"TODO"
#define BRFixMeLogType      @"FIXME"
#define BRDebugLogType      @"DEBUG"
#define BRWarnLogType       @"WARNING"
#define BRErrorLogType      @"ERROR"
#define BRFatalLogType      @"FATAL"



#ifdef DEBUG
#define BRInfoLog(fmt, ...) [BRLogging logForObject:self function:__PRETTY_FUNCTION__ line:__LINE__ type:BRLogType message:(fmt),##__VA_ARGS__]
#define BRTag() [BRLogging tagForObject:self function:__PRETTY_FUNCTION__ line:__LINE__ type:BRTagLogType]
#define BRToDo(fmt, ...) [BRLogging logToDoForObject:self function:__PRETTY_FUNCTION__ line:__LINE__ type:BRToDoLogType message:(fmt),##__VA_ARGS__]
#define BRFixMe(fmt, ...) [BRLogging logFixMeForObject:self function:__PRETTY_FUNCTION__ line:__LINE__ type:BRFixMeLogType message:(fmt),##__VA_ARGS__]
#define BRDebugLog(fmt, ...) [BRLogging logForObject:self function:__PRETTY_FUNCTION__ line:__LINE__ type:BRDebugLogType message:(fmt),##__VA_ARGS__]
#define BRWarnLog(fmt, ...) [BRLogging logImportantForObject:self function:__PRETTY_FUNCTION__ line:__LINE__ type:BRWarnLogType message:(fmt),##__VA_ARGS__]
#define BRErrorLog(fmt, ...) [BRLogging logImportantForObject:self function:__PRETTY_FUNCTION__ line:__LINE__ type:BRErrorLogType message:(fmt),##__VA_ARGS__]
#define BRFatalLog(fmt, ...) if([BRLogging logImportantForObject:self function:__PRETTY_FUNCTION__ line:__LINE__ type:BRFatalLogType message:(fmt),##__VA_ARGS__]){NSLog(@"\n%@",[NSThread callStackSymbols]);[NSException raise:NSInvalidArgumentException format:@"Fatal Log"];}
#else
#define BRInfoLog(...)
#define BRTag()
#define BRToDo(...)
#define BRFixMe(...)
#define BRInfoLog(...)
#define BRDebugLog(...)
#define BRWarnLog(...)
#define BRErrorLog(...)
#define BRFatalLog(...)
#endif

#import <Foundation/Foundation.h>

@interface BRLogging : NSObject

+ (BOOL)tagForObject:(id)object function:(const char[])function line:(int)line type:(NSString *)type;
+ (BOOL)logForObject:(id)object function:(const char[])function line:(int)line type:(NSString *)type message:(NSString *)format,...;
+ (BOOL)logImportantForObject:(id)object function:(const char[])function line:(int)line type:(NSString *)type message:(NSString *)format,...;
+ (BOOL)logToDoForObject:(id)object function:(const char[])function line:(int)line type:(NSString *)type message:(NSString *)format,...;
+ (BOOL)logFixMeForObject:(id)object function:(const char[])function line:(int)line type:(NSString *)type message:(NSString *)format,...;
@end
