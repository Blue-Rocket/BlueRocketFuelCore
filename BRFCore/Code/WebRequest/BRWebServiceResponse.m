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

#import "BRWebServiceResponse.h"

@implementation BRWebServiceResponse

+ (BRWebServiceResponse *)responseWithData:(NSData *)data {
    BRWebServiceResponse *response = [[BRWebServiceResponse alloc] init];
    response.data = [NSMutableData dataWithData:data];
    return response;
}

- (id)init {
    if (self = [super init]) {
        self.data = [[NSMutableData alloc] init];
    }
    return self;
}

- (NSString *)string {
    @try {
        NSString *string = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        return string;
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    return nil;
}

- (NSString *)JSONString {
    @try {
        NSError *error;
        id json = [NSJSONSerialization JSONObjectWithData:self.data options:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves) error:&error];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];
        NSString *string = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return string;
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    return nil;
}

- (NSDictionary *)JSONDictionary {
    
    @try {
        NSError *error;
        return [NSJSONSerialization JSONObjectWithData:self.data options:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves) error:&error];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    return nil;
}

- (NSArray *)JSONArray {
    @try {
        NSError *error;
        return [NSJSONSerialization JSONObjectWithData:self.data options:(NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves) error:&error];
    }
    @catch (NSException *exception) {
    }
    @finally {
    }
    return nil;
}

@end
