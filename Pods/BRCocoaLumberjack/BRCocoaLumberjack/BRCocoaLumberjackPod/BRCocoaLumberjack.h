//
//  BRCocoaLumberjack.h
//  BRCocoaLumberjack
//
//  Created by Matt on 8/16/13.
//  Copyright (c) 2013 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import <CocoaLumberjack/DDLog.h>
#import <BRCocoaLumberjack/BRLogConstants.h>
#import <BRCocoaLumberjack/BRLogging.h>

// Always log Errors
#define DDLogError(frmt, ...)    SYNC_LOG_OBJC_MAYBE(BRLogLevelForClass([self class]), LOG_FLAG_ERROR,  0, frmt, ##__VA_ARGS__)

#define DDLogCError(frmt, ...)   SYNC_LOG_C_MAYBE(BRCLogLevel, LOG_FLAG_ERROR,  0, frmt, ##__VA_ARGS__)

// log4Cocoa compatibility
#define log4Error DDLogError
#define log4CError DDLogCError

#ifdef LOGGING

#define DDLogWarn(frmt, ...)     SYNC_LOG_OBJC_MAYBE(BRLogLevelForClass([self class]), LOG_FLAG_WARN,  0, frmt, ##__VA_ARGS__)
#define DDLogInfo(frmt, ...)     SYNC_LOG_OBJC_MAYBE(BRLogLevelForClass([self class]), LOG_FLAG_INFO,  0, frmt, ##__VA_ARGS__)
#define DDLogDebug(frmt, ...)    SYNC_LOG_OBJC_MAYBE(BRLogLevelForClass([self class]), LOG_FLAG_DEBUG, 0, frmt, ##__VA_ARGS__)
#define DDLogTrace(frmt, ...)    SYNC_LOG_OBJC_MAYBE(BRLogLevelForClass([self class]), LOG_FLAG_TRACE, 0, frmt, ##__VA_ARGS__)

#define DDLogCWarn(frmt, ...)    SYNC_LOG_C_MAYBE(BRCLogLevel, LOG_FLAG_WARN,  0, frmt, ##__VA_ARGS__)
#define DDLogCInfo(frmt, ...)    SYNC_LOG_C_MAYBE(BRCLogLevel, LOG_FLAG_INFO,  0, frmt, ##__VA_ARGS__)
#define DDLogCDebug(frmt, ...)   SYNC_LOG_C_MAYBE(BRCLogLevel, LOG_FLAG_DEBUG, 0, frmt, ##__VA_ARGS__)
#define DDLogCTrace(frmt, ...)   SYNC_LOG_C_MAYBE(BRCLogLevel, LOG_FLAG_TRACE, 0, frmt, ##__VA_ARGS__)

// log4Cocoa compatibility
#define log4Warn DDLogWarn
#define log4Info DDLogInfo
#define log4Debug DDLogDebug
#define log4Trace DDLogTrace

#define log4CWarn DDLogCWarn
#define log4CInfo DDLogCInfo
#define log4CDebug DDLogCDebug
#define log4CTrace DDLogCTrace

#else

#define DDLogWarn(...)
#define DDLogInfo(...)
#define DDLogDebug(...)
#define DDLogTrace(...)

#define DDLogCWarn(...)
#define DDLogCInfo(...)
#define DDLogCDebug(...)
#define DDLogCTrace(...)

// log4Cocoa compatibility
#define log4Warn(...)
#define log4Info(...)
#define log4Debug(...)
#define log4Trace(...)

#define log4CWarn(...)
#define log4CInfo(...)
#define log4CDebug(...)
#define log4CTrace(...)

#endif
