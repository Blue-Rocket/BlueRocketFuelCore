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

#import <Foundation/Foundation.h>

#import "BRWebServiceResponse.h"

typedef NS_OPTIONS(NSUInteger, BRAppNetworkNotificationOptions) {
    BRAppNetworkNotificationNone              = 0,
    BRAppNetworkNotificationActivity          = 1 << 0,
    BRAppNetworkNotificationUnkownError       = 1 << 1,
    BRAppNetworkNotificationNoConnection      = 1 << 2,
    BRAppNetworkNotificationHostNotFound      = 1 << 3,
    BRAppNetworkNotificationUnsupportedURL    = 1 << 4,
    BRAppNetworkNotificationTimedOut          = 1 << 5,
    BRAppNetworkNotification404NotFound       = 1 << 6,
};

@interface BRWebServiceRequest : NSObject

@property (nonatomic) BRAppNetworkNotificationOptions appLevelNotificationOptions;
@property (nonatomic) BOOL preventUserInteraction;

@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, strong) NSData *data;

+ (id)requestForResourceAtURL:(NSURL *)url;
+ (id)requestForAPI:(NSString *)api;
+ (id)requestForAPI:(NSString *)api parameters:(NSDictionary *)parameters;

- (void)addAppLevelNotificationOptions:(BRAppNetworkNotificationOptions)appLevelNotificationOptions;

- (void)beginWithCompletion:(void (^)(BRWebServiceResponse *response))completion failure:(void (^)(NSError *error, NSInteger code))failure;
- (void)retry;
- (void)cancel;

@end
