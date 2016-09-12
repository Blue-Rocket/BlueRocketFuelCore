//
//  JSONAPIErrorExtractor.h
//  WebApiClient
//
//  Created by Matt on 4/25/16.
//  Copyright © 2016 Blue Rocket, Inc. Distributable under the terms of the Apache License, Version 2.0.
//

#import "WebApiErrorExtractor.h"

NS_ASSUME_NONNULL_BEGIN

/** The default error domain used for the @c errorDomain property. */
extern NSString * const JSONAPIErrorExtractorDefaultErrorDomain;

/**
 An @c WebApiClientErrorExtractor for extracting JSON API style error responses.
 
 The @c WebApiClientErrorResponseObjectKey value will be set to an @c NSArray of @c JSONAPIError objects.
 */
@interface JSONAPIErrorExtractor : NSObject <WebApiErrorExtractor>

/**
 The error domain to use for extracted errors. Defaults to @c JSONAPIErrorExtractorDefaultErrorDomain.
 */
@property (nonatomic, strong) NSString *errorDomain;

@end

NS_ASSUME_NONNULL_END
