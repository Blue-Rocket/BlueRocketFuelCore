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

#import "BRAppDelegate.h"

#import <BREnvironment/BREnvironment.h>
#import "BRAppConfigEnvironmentProvider.h"
#import "BRFullScreeNotificationViewDelegate.h"
#import "BRFullScreenNotificationView.h"
#import "BRSimpleLogging.h"
#import "BRWebServiceRequest.h"
#import "NSBundle+BR.h"
#import "NSDictionary+BR.h"

@interface BRAppDelegate () <BRFullScreeNotificationViewDelegate> {
    int networkActivityIndicatorUseCount;
}

@end

@implementation BRAppDelegate

+ (void)initialize {
	[BREnvironment registerEnvironmentProvider:[BRAppConfigEnvironmentProvider new]];
}

- (NSDictionary *)config {
	return [NSBundle appConfig];
}

- (NSDictionary *)strings {
	return [NSBundle appStrings];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BRTag();
    
    NSMutableString *scheme = [NSMutableString stringWithString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
    [scheme replaceOccurrencesOfString:@" " withString:@"_" options:NSCaseInsensitiveSearch range:NSMakeRange(0,scheme.length)];
    
    if ([[url scheme] isEqualToString:[scheme lowercaseString]]) {
        NSString *destination = [[url description] substringFromIndex:scheme.length+3];
        [self linkTo:destination fromApplication:sourceApplication annotation:annotation];
    }
    return YES;
}

- (void)linkTo:(NSString *)destination fromApplication:(NSString *)application annotation:(id)annotation {
    // subclasses should override and implement
}

#pragma mark - Network Handling

- (void)showNetworkActivityIndicator {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    networkActivityIndicatorUseCount++;
}

- (void)hideNetworkActivityIndicator {
    networkActivityIndicatorUseCount--;
    if (networkActivityIndicatorUseCount < 0) networkActivityIndicatorUseCount = 0;
    if (!networkActivityIndicatorUseCount) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (void)webServiceRequestForAPI:(NSString *)api {
    
}

- (void)applicationDidEncounterNetworkError:(NSError *)error forRequest:(BRWebServiceRequest *)request {
    
    UIView *appLevelNotificationView = [self fullScreenNotificationViewForError:error request:request];
    appLevelNotificationView.frame = self.window.rootViewController.view.bounds;
    BOOL showAppLevelNotificationView = NO;
    appLevelNotificationView = nil;

    switch (error.code) {
            
        case NSURLErrorNotConnectedToInternet:
            if (request.appLevelNotificationOptions & BRAppNetworkNotificationNoConnection) {
                if (appLevelNotificationView) {
                    showAppLevelNotificationView = YES;
                }
                else {
                    [self applicationDidEncounterNoInternetConnectionError:error forRequest:request];
                }
            }
            break;
            
        case NSURLErrorCannotFindHost:
            if (request.appLevelNotificationOptions & BRAppNetworkNotificationHostNotFound) {
                if (appLevelNotificationView) {
                    showAppLevelNotificationView = YES;
                }
                else {
                    [self applicationDidEncounterNetworkHostNotFoundError:error forRequest:request];
                }
            }
            break;
            
        case NSURLErrorUnsupportedURL:
            if (request.appLevelNotificationOptions & BRAppNetworkNotificationUnsupportedURL) {
                if (appLevelNotificationView) {
                    showAppLevelNotificationView = YES;
                }
                else {
                    [self applicationDidEncounterUnsupportedURLError:error forRequest:request];
                }
            }
            break;
            
        case NSURLErrorTimedOut:
            if (request.appLevelNotificationOptions & BRAppNetworkNotificationTimedOut) {
                if (appLevelNotificationView) {
                    showAppLevelNotificationView = YES;
                }
                else {
                    [self applicationDidEncounterNetworkConnectionTimedOut:error forRequest:request];
                }
            }
            break;
            
        case 404:
            if (request.appLevelNotificationOptions & BRAppNetworkNotification404NotFound) {
                if (appLevelNotificationView) {
                    showAppLevelNotificationView = YES;
                }
                else {
                    [self applicationDidEncounter404NotFoundError:error forRequest:request];
                }
            }
            break;
            
        default:
            if (request || (request.appLevelNotificationOptions & BRAppNetworkNotificationUnkownError)) {
                if (appLevelNotificationView) {
                    showAppLevelNotificationView = YES;
                }
                else {
                    [self applicationDidEncounterUnkownNetworkError:error forRequest:request];
                }
            }
            break;
    }

    if (appLevelNotificationView && showAppLevelNotificationView) {
        appLevelNotificationView.frame = self.window.rootViewController.view.bounds;
        [self.window.rootViewController.view addSubview:appLevelNotificationView];
        return;
    }
}

- (void)applicationDidEncounterUnkownNetworkError:(NSError *)error forRequest:(BRWebServiceRequest *)request {
    
    NSString *template = [BRApp.strings localizedString:@"error.network.unknown.message" withDefault:@"%d"];
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:[BRApp.strings localizedString:@"error.network.unkown.title" withDefault:@"Netowrk Error"]
                              message:[NSString stringWithFormat:template,error.code]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}


- (void)applicationDidEncounterNoInternetConnectionError:(NSError *)error forRequest:(BRWebServiceRequest *)request {
    
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:[BRApp.strings localizedString:@"error.network.connection.title" withDefault:@"No Internet Connection"]
                              message:[BRApp.strings localizedString:@"error.network.connection.message" withDefault:@"It looks like you may have lost\nInternet connection. Check your settings and try again."]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}


- (void)applicationDidEncounterNetworkHostNotFoundError:(NSError *)error forRequest:(BRWebServiceRequest *)request {
    
    NSString *template = [BRApp.strings localizedString:@"error.network.host.message" withDefault:@"The host\n\"%@\"\ncould not be found."];
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:[BRApp.strings localizedString:@"error.network.host.title" withDefault:@"Unknown Host"]
                              message:[NSString stringWithFormat:template,request.url]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}


- (void)applicationDidEncounterUnsupportedURLError:(NSError *)error forRequest:(BRWebServiceRequest *)request {
    
    NSString *template = [BRApp.strings localizedString:@"error.network.unsupported.message" withDefault:@"The URL \"%@\" is not supported."];
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:[BRApp.strings localizedString:@"error.network.unsupported.title" withDefault:@"Unsupported URL"]
                              message:[NSString stringWithFormat:template,request.url]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

- (void)applicationDidEncounterNetworkConnectionTimedOut:(NSError *)error forRequest:(BRWebServiceRequest *)request {
    NSString *template = [BRApp.strings localizedString:@"error.network.timeout.message" withDefault:@"%@"];

    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:[BRApp.strings localizedString:@"error.network.timeout.title" withDefault:@"Connection Timed Out"]
                              message:[NSString stringWithFormat:template,request.url]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

- (void)applicationDidEncounter404NotFoundError:(NSError *)error forRequest:(BRWebServiceRequest *)request {
    NSString *template = [BRApp.strings localizedString:@"error.network.404.message" withDefault:@"%@"];
    
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:[BRApp.strings localizedString:@"error.network.404.title" withDefault:@"Resource Not Found"]
                              message:[NSString stringWithFormat:template,request.url]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
    [alertView show];
}

- (UIView *)fullScreenNotificationViewForError:(NSError *)error request:(BRWebServiceRequest *)request {
    UIView *view = nil;
    
    
    @try {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"FullScreenNotificationViews" owner:self options:nil];
        for (UIView *v in views) {
            if (v.tag == error.code) {
                if ([v isKindOfClass:[BRFullScreenNotificationView class]]) {
                    BRFullScreenNotificationView *fullScreenView = (BRFullScreenNotificationView *)v;
                    fullScreenView.info = request;
                    fullScreenView.delegate = self;
                }
                view = v;
            }
        }
        
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    
    
    return view;
}

#pragma mark - Version Info

- (NSString *)fullBuildIdentifier {
    NSString *buildVersion = [self buildVersion];
    NSString *buildNumber = [self buildNumber];
    if (buildNumber.length && ![buildVersion isEqualToString:buildNumber]) return [NSString stringWithFormat:@"%@ (%@)",[self buildVersion],[self buildNumber]];
    return buildVersion;
}

- (NSString *)buildNumber {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
}

- (NSString *)buildVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
}



#pragma mark - BRFullScreeNotificationViewDelegate Implementation

- (void)fullScreenNotificationView:(BRFullScreenNotificationView *)view requestedRetryWithInfo:(id)info {
    if ([info isKindOfClass:[BRWebServiceRequest class]]) {
        [(BRWebServiceRequest *)info retry];
    }
}

@end
