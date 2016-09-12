//
//  JSONAPIError.h
//  WebApiClient
//
//  Created by Matt on 4/25/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSONAPIError : NSObject

/** A unique ID. */
@property (nonatomic, readonly, nullable) NSString *id;

/** An application-defined error code. */
@property (nonatomic, readonly, nullable) NSString *code;

/** A localized title. */
@property (nonatomic, readonly, nullable) NSString *title;

/** A localized detail description. */
@property (nonatomic, readonly, nullable) NSString *detail;

/** The HTTP status code. */
@property (nonatomic, readonly, nullable) NSString *status;

/**
 Initialize with a dictionary response object.
 
 @param responseObject The error response object.
 
 @return The initialized instance.
 */
- (instancetype)initWithResponseObject:(NSDictionary<NSString *, id> *)responseObject;

/**
 Create an error object from a dictionary.
 
 @param responseObject The dictionary response object.
 
 @return The initialized instance.
 */
+ (instancetype)JSONAPIErrorWithResponseObject:(NSDictionary<NSString *, id> *)responseObject;

@end

NS_ASSUME_NONNULL_END
