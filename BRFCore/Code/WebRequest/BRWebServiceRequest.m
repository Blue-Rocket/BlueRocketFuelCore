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

#import <UIKit/UIKit.h>

#import <BREnvironment/BREnvironment.h>
#import <BRLocalize/Core.h>
#import "BRAppDelegate.h"
#import "BRAppUser.h"
#import "BRSimpleLogging.h"
#import "BRReachability.h"
#import "BRWebServiceRequest.h"
#import "NSBundle+BR.h"
#import "NSString+BR.h"
#import "UIImage+ImageEffects.h"

//#import "UIImage+ImageEffects.h"

static NSMutableDictionary *networkActivityIndicatorRequests;
static NSMutableDictionary *preventUserInteractionRequests;
static NSMutableDictionary *fullScreenSpinnerRequests;

static NSLock *networkActivityIndicatorRequests_lock;
static NSLock *preventUserInteractionRequests_lock;
static NSLock *fullScreenSpinnerRequests_lock;

static UIView *fullScreenSpinnerView;
static UIActivityIndicatorView *fullScreenSpinner;

@interface BRWebServiceRequest () <NSURLConnectionDelegate> {
    BOOL inProgress;
}
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic) NSInteger responseCode;
@property (nonatomic, strong) BRWebServiceResponse *response;
@property (nonatomic, strong) void (^completionCallback)(BRWebServiceResponse *);
@property (nonatomic, strong) void (^failureCallback)(NSError *, NSInteger code);
@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *method;
@end

@implementation BRWebServiceRequest

+ (id)requestForAPI:(NSString *)api {
    return [self requestForAPI:api recordId:nil params:nil];
}

+ (id)requestForAPI:(NSString *)api recordId:(NSString *)recordId params:(NSDictionary *)params {
    
    BRInfoLog(@"REQUEST INITIALIZED: %@",api);

    if (!networkActivityIndicatorRequests) {
        networkActivityIndicatorRequests = [[NSMutableDictionary alloc] init];
        preventUserInteractionRequests = [[NSMutableDictionary alloc] init];
        fullScreenSpinnerRequests = [[NSMutableDictionary alloc] init];
        
        networkActivityIndicatorRequests_lock = [[NSLock alloc] init];
        preventUserInteractionRequests_lock = [[NSLock alloc] init];
        fullScreenSpinnerRequests_lock = [[NSLock alloc] init];
    }
    
    Class c = nil;
    NSString *className = [NSString stringWithFormat:@"%@WebServiceRequest",[api capitalizedFirstLetter]];
    c = NSClassFromString(className);
    if (!c) {
        className = [NSString stringWithFormat:@"BR%@WebServiceRequest",[api capitalizedFirstLetter]];
        c = NSClassFromString(className);
    }
    if (!c) c = [self class];
    
    BRWebServiceRequest *request = [[c alloc] init];
    
    if ([NSString stringWithFormat:@"webservice.api.%@.path",api]) {
        
        NSString *apiURL = nil;
        NSString *apiPath = [request pathForAPI:api];
        
        NSMutableString *mutableAPIPath = [NSMutableString stringWithString:apiPath];
        [mutableAPIPath replaceOccurrencesOfString:@"{userId}" withString:[NSString stringWithFormat:@"%@",[BRAppUser currentUser].uniqueId] options:NSLiteralSearch range:NSMakeRange(0,mutableAPIPath.length)];
        if (recordId) [mutableAPIPath replaceOccurrencesOfString:@"{recordId}" withString:[NSString stringWithFormat:@"%@",recordId] options:NSLiteralSearch range:NSMakeRange(0,mutableAPIPath.length)];
        apiPath = mutableAPIPath;

        request.method = [BREnvironment sharedEnvironment][[NSString stringWithFormat:@"webservice.api.%@.method",api]];
        if (!request.method) request.method = @"GET";
        
        NSString *port = [BREnvironment sharedEnvironment][@"webservice.port"];
        
        NSMutableString *queryString = [NSMutableString stringWithString:@""];
        if ([request.method isEqualToString:@"GET"] && params.count) {
            for(NSString* key in params) {
                if (queryString.length) [queryString appendString:@"&"];
                else [queryString appendString:@"?"];
                [queryString appendFormat:@"%@=%@",key,[[params objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
            if (queryString.length) apiPath = [NSString stringWithFormat:@"%@%@",apiPath,queryString];
        }

        NSString *protocol = [BREnvironment sharedEnvironment][@"App_webservice_protocol"];
        NSString *host = [BREnvironment sharedEnvironment][@"App_webservice_host"];
        //        [BREnvironment sharedEnvironment][@"webservice.protocol"],
        //        [BREnvironment sharedEnvironment][@"webservice.host"],
        
        if (!port || [port isEqualToString:@"80"]) {
            apiURL = [NSString stringWithFormat:@"%@://%@%@",
                      protocol,
                      host,
                      apiPath
                      ];
        }
        else {
            apiURL = [NSString stringWithFormat:@"%@://%@:%@%@",
                      protocol,
                      host,
                      port,
                      apiPath
                      ];
        }
        
        request.request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:apiURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
        [request.request setValue:[request acceptHeaderValue] forHTTPHeaderField:@"Accept"];
        NSString *appToken = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"App_webservice_token"];
        [request.request setValue:appToken forHTTPHeaderField:@"AUTHORIZATION"];
        [request initializeHeaders];
        request.appLevelNotificationOptions = (BRAppNetworkNotification404NotFound | BRAppNetworkNotificationActivity | BRAppNetworkNotificationHostNotFound | BRAppNetworkNotificationUnsupportedURL | BRAppNetworkNotificationUnkownError);
        [request initializeRequestFeatures];
        [request.request setHTTPMethod:request.method];
        
        request.key = [request.request description];
        
        return request;
    }
    
    return nil;
}

+ (id)requestForResourceAtURL:(NSURL *)url {
    if (!url) return nil;
    
    BRWebServiceRequest *request = [[self alloc] init];
    request.request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];
    request.appLevelNotificationOptions = BRAppNetworkNotificationNone;
    return request;
}

+ (id)requestForAPI:(NSString *)api parameters:(NSDictionary *)parameters {
    return [self requestForAPI:api JSONData:parameters];
}

+ (id)requestForAPI:(NSString *)api JSONData:(NSDictionary *)data {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:data];
    [dictionary removeObjectForKey:@"recordId"];
    BRWebServiceRequest *request = [self requestForAPI:api recordId:[data objectForKey:@"recordId"] params:dictionary];
    if (dictionary.count) {
        BRInfoLog(@"REQUEST PARAMETERS: %@\n%@",api,dictionary);
        [request.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    [request.request setValue:[request acceptHeaderValue] forHTTPHeaderField:@"Accept"];
    
    NSError *error;
    
    if (dictionary.count) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                           options:(NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves)
                                                             error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (jsonData) {
            if (![request.method isEqualToString:@"GET"]) request.data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            else request.data = nil;
        }
        else {
            BRErrorLog(@"%@",error);
        }
    }
    return request;
}

- (NSString *)pathForAPI:(NSString *)api {
    NSString *apiPath = [BREnvironment sharedEnvironment][[NSString stringWithFormat:@"webservice.api.%@.path",api]];
    if (!apiPath) apiPath = @"";
    else apiPath = [NSString stringWithFormat:@"/%@",apiPath];
    
    NSString *subpath = [self subpath];
    if (subpath) {
        apiPath = [NSString stringWithFormat:@"%@/%@",apiPath,subpath];
    }
    
    return apiPath;
}

- (void)initializeHeaders {
}

- (void)initializeRequestFeatures {
}

- (NSString *)subpath {
    return nil;
}

- (NSString *)acceptHeaderValue {
    return @"application/json; version=1";
}

#pragma mark - Showing Netork Activity Indicator

- (void)showNetworkActivityIndicator {
    [networkActivityIndicatorRequests_lock lock];
    if (!networkActivityIndicatorRequests.count) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    };
    [networkActivityIndicatorRequests setObject:[NSNumber numberWithBool:YES] forKey:self.key];
    [networkActivityIndicatorRequests_lock unlock];
}

- (void)hideNetworkActivityIndicator {
    [networkActivityIndicatorRequests_lock lock];
    if ([networkActivityIndicatorRequests objectForKey:self.key]) {
        [networkActivityIndicatorRequests removeObjectForKey:self.key];
        if (!networkActivityIndicatorRequests.count) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        };
    }
    [networkActivityIndicatorRequests_lock unlock];
}

#pragma mark - Disabling User Interaction

- (void)beginIgnoringInteractionEvents {
    [preventUserInteractionRequests_lock lock];
    if (!preventUserInteractionRequests.count) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    };
    [preventUserInteractionRequests setObject:[NSNumber numberWithBool:YES] forKey:self.key];
    [preventUserInteractionRequests_lock unlock];
}

- (void)endIgnoringInteractionEvents {
    [preventUserInteractionRequests_lock lock];
    if ([preventUserInteractionRequests objectForKey:self.key]) {
        [preventUserInteractionRequests removeObjectForKey:self.key];
        if (!preventUserInteractionRequests.count) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        };
    }
    [preventUserInteractionRequests_lock unlock];
}

#pragma mark - Showing Full Screen Spinner

- (void)beginShowingFullScreenSpinner {
    [fullScreenSpinnerRequests_lock lock];
    __block NSTimer *timer = [fullScreenSpinnerRequests objectForKey:self.key];
    if (!timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(handleShowSpinnerTimerFired:) userInfo:nil repeats:NO];
            [fullScreenSpinnerRequests setObject:timer forKey:self.key];
        });
    }
    [fullScreenSpinnerRequests_lock unlock];
}

- (void)endShowingFullScreenSpinner {
    [fullScreenSpinnerRequests_lock lock];
    NSTimer *timer = [fullScreenSpinnerRequests objectForKey:self.key];
    if (timer) {
        [timer invalidate];
        [fullScreenSpinnerRequests removeObjectForKey:self.key];
        if (!fullScreenSpinnerRequests.count) {
            [self doHideFullScreenSpinner];
        }
    }
    [fullScreenSpinnerRequests_lock unlock];
}

- (void)handleShowSpinnerTimerFired:(NSTimer *)timer {

    if (!inProgress) return;
    
    //UIViewController *vc = ((UIWindow *)[[[UIApplication sharedApplication] windows] lastObject]).rootViewController;
    UIView *screenView;// = vc.view;
    
    screenView = BRApp.window;
    
    CGSize s = screenView.bounds.size;
    
    if (fullScreenSpinnerView && fullScreenSpinnerView.superview) return;
    
    fullScreenSpinnerView = [[UIView alloc] initWithFrame:screenView.bounds];
    fullScreenSpinnerView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.65];
    
    fullScreenSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    fullScreenSpinner.center = fullScreenSpinnerView.center;
    [fullScreenSpinner startAnimating];
    [fullScreenSpinnerView addSubview:fullScreenSpinner];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,s.width - 40,s.height)];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.text = [[NSBundle appStrings] stringForKeyPath:@"error.network.slow" withDefault:@"This is taking a little longer than expected. Please wait..."];
    [label sizeToFit];
    CGRect r = label.frame;
    r.origin.x = rintf(s.width/2 - r.size.width/2);
    r.origin.y = fullScreenSpinner.frame.origin.y - r.size.height - 20;
    label.frame = r;
    label.textColor = [UIColor whiteColor];
    [fullScreenSpinnerView addSubview:label];
    
    
    UIGraphicsBeginImageContext(screenView.bounds.size);
    [screenView drawViewHierarchyInRect:screenView.bounds afterScreenUpdates:YES];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // TODO:
    fullScreenSpinnerView.backgroundColor = [UIColor colorWithPatternImage:[snapshotImage applyBlurWithRadius:3 tintColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.65] saturationDeltaFactor:1 maskImage:nil]];
    
    fullScreenSpinnerView.alpha = 0.0;
    [screenView addSubview:fullScreenSpinnerView];

    [UIView animateWithDuration:0.35
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         fullScreenSpinnerView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}

- (void)doHideFullScreenSpinner {
    if (!fullScreenSpinnerView.superview) return;
    [UIView animateWithDuration:0.35
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         fullScreenSpinnerView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [fullScreenSpinnerView removeFromSuperview];
                         fullScreenSpinnerView = nil;
                     }
     ];
}

#pragma mark - Request Lifecycle

- (void)beginWithCompletion:(void (^)(BRWebServiceResponse *response))completion cachedResource:(void (^)(NSData *cachedResourceData))cachedResource failure:(void (^)(NSError *error, NSInteger code))failure {
    
    NSString *hash = [[self.request.URL absoluteString] MD5String];
    NSString *cachePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"cache"];
    NSString *filePath = [cachePath stringByAppendingPathComponent:hash];
    [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:YES attributes:nil error:nil];
    NSData *data = [NSData dataWithContentsOfFile:filePath options:NSUncachedRead error:nil];
    if (data) {
        cachedResource(data);
    }
    
    [self beginWithCompletion:^ (BRWebServiceResponse *response) {
        NSData *data = response.data;
        [data writeToFile:filePath atomically:YES];
        completion(response);
    }
                         failure:^(NSError *error, NSInteger code) {
                             failure(error,code);
                         }];
}

- (void)beginWithCompletion:(void (^)(BRWebServiceResponse *response))completion failure:(void (^)(NSError *error, NSInteger code))failure {
    
    [self beginRequestFeatures];
    
    self.completionCallback = completion;
    self.failureCallback = failure;
    self.response = [[BRWebServiceResponse alloc] init];
    [self.request setHTTPBody:self.data];
    BRInfoLog(@"REQUEST HEADERS: %@",self.request.allHTTPHeaderFields);
    BRInfoLog(@"REQUEST STARTED: %@",self.request.URL);
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
    inProgress = YES;
    [self.connection start];
}

- (void)beginRequestFeatures {
    if (self.preventUserInteraction) {
        [self beginIgnoringInteractionEvents];
    }
    
    if (self.appLevelNotificationOptions & BRAppNetworkNotificationActivity) [self showNetworkActivityIndicator];
    
    if (self.preventUserInteraction) {
        [self beginShowingFullScreenSpinner];
    }
}

- (void)endRequestFeatures {
    if (self.appLevelNotificationOptions & BRAppNetworkNotificationActivity) [self hideNetworkActivityIndicator];
    
    if (self.preventUserInteraction) {
        [self endShowingFullScreenSpinner];
    }

    if (self.preventUserInteraction) {
        [self endIgnoringInteractionEvents];
    }
    
}

- (void)retry {
    BRInfoLog(@"REQUEST RETRY: %@",self.request.URL);
    [self beginRequestFeatures];
    self.response = [[BRWebServiceResponse alloc] init];
    self.responseCode = 0;
    self.connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
    [self.connection start];
}

- (void)cancel {
    if (!self.connection) return;
    BRInfoLog(@"REQUEST CANCELED: %@",self.request.URL);
    [self endRequestFeatures];
    [self.connection cancel];
    self.connection = nil;
}

- (void)dealloc {
    [self endRequestFeatures];
    [self.connection cancel];
}

#pragma mark - Property Access

- (void)addAppLevelNotificationOptions:(BRAppNetworkNotificationOptions)appLevelNotificationOptions {
    self.appLevelNotificationOptions = (self.appLevelNotificationOptions | appLevelNotificationOptions);
}

- (void)removeAppLevelNoficationOptions:(BRAppNetworkNotificationOptions)appLevelNotificationOptions {
    self.appLevelNotificationOptions = (self.appLevelNotificationOptions & ~appLevelNotificationOptions);
}

- (NSURL *)url {
    return self.request.URL;
}

#pragma mark - NSURLConnectionDelegate Implementation

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        self.responseCode = httpResponse.statusCode;
        BRInfoLog(@"REQUEST ACKNOWLEDGED: %d: %@",self.responseCode,self.request.URL);
    }
    else {
        BRInfoLog(@"REQUEST ACKNOWLEDGED: %@",self.request.URL);
    }
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.response.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    inProgress = NO;
    [self endRequestFeatures];
    
    NSError *error = nil;
    
    switch (self.responseCode) {
        case 400:
            BRErrorLog(@"%@",self.response.JSONDictionary);
            error = [NSError errorWithDomain:NSURLErrorDomain code:self.responseCode userInfo:self.response.JSONDictionary];
            [self connection:connection didFailWithError:error];
            break;
            
        case 401:
            BRErrorLog(@"%@",self.response.JSONDictionary);
            error = [NSError errorWithDomain:NSURLErrorDomain code:self.responseCode userInfo:self.response.JSONDictionary];
            self.failureCallback(error,error.code);
            break;

        case 404:
            BRErrorLog(@"%@",self.response.JSONDictionary);
            error = [NSError errorWithDomain:NSURLErrorDomain code:self.responseCode userInfo:self.response.JSONDictionary];
            if (self.appLevelNotificationOptions & BRAppNetworkNotification404NotFound) {
                [BRApp applicationDidEncounter404NotFoundError:error forRequest:self];
            }
            else [self connection:connection didFailWithError:error];
            break;
            
        case 422:
            BRErrorLog(@"%@",self.response.JSONDictionary);
            error = [NSError errorWithDomain:NSURLErrorDomain code:self.responseCode userInfo:self.response.JSONDictionary];
            self.failureCallback(error,error.code);
            break;
            
        case 500:
            BRErrorLog(@"%@",self.response.JSONDictionary);
            error = [NSError errorWithDomain:NSURLErrorDomain code:self.responseCode userInfo:self.response.JSONDictionary];
            [self connection:connection didFailWithError:error];
            break;
            
        case 503:
            BRErrorLog(@"%@",self.response.JSONDictionary);
            error = [NSError errorWithDomain:NSURLErrorDomain code:self.responseCode userInfo:self.response.JSONDictionary];
            [self connection:connection didFailWithError:error];
           break;
            
        default:
            BRInfoLog(@"REQUEST SUCCEEDED: %@",self.request.URL);
            self.completionCallback(self.response);
            break;
    }
    self.connection = nil;
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    inProgress = NO;
    [self endRequestFeatures];

    BRErrorLog(@"REQUEST FAILED: %d: %@ - %@",error.code,self.request.URL,error);
    
    NSString *s = [[NSString alloc] initWithData:self.response.data encoding:NSUTF8StringEncoding];
    BRErrorLog(@"FAILED RESPONSE: %@",s);

    self.failureCallback(error,error.code);
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [BRApp applicationDidEncounterNetworkError:error forRequest:self];
    
}

@end
