//
//  Created by Shawn McKee on 11/22/13.
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

#import <UIKit/UIKit.h>

@class BRWebServiceRequest;

#define BRApp ((BRAppDelegate *)[UIApplication sharedApplication].delegate)

@interface BRAppDelegate : UIResponder

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) NSDictionary *config;
@property (nonatomic, strong, readonly) NSDictionary *strings;

- (NSString *)fullBuildIdentifier;
- (NSString *)buildNumber;
- (NSString *)buildVersion;


- (void)showNetworkActivityIndicator;
- (void)hideNetworkActivityIndicator;

- (void)applicationDidEncounterNetworkError:(NSError *)error forRequest:(BRWebServiceRequest *)request;
- (void)applicationDidEncounterUnkownNetworkError:(NSError *)error forRequest:(BRWebServiceRequest *)request;
- (void)applicationDidEncounterNoInternetConnectionError:(NSError *)error forRequest:(BRWebServiceRequest *)request;
- (void)applicationDidEncounterNetworkHostNotFoundError:(NSError *)error forRequest:(BRWebServiceRequest *)request;
- (void)applicationDidEncounterUnsupportedURLError:(NSError *)error forRequest:(BRWebServiceRequest *)request;
- (void)applicationDidEncounterNetworkConnectionTimedOut:(NSError *)error forRequest:(BRWebServiceRequest *)request;
- (void)applicationDidEncounter404NotFoundError:(NSError *)error forRequest:(BRWebServiceRequest *)request;


@end
