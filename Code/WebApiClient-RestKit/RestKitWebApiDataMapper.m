//
//  RestKitWebApiDataMapper.m
//  BlueRocketFuelCore
//
//  Created by Matt on 13/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "RestKitWebApiDataMapper.h"

#import <RestKit/ObjectMapping.h>
#import <RestKit/ObjectMapping/RKObjectMappingOperationDataSource.h>
#import "WebApiRoute.h"

NSString * const RestKitWebApiRoutePropertyRootKeyPath = @"dataMapperRootKeyPath";

@implementation RestKitWebApiDataMapper {
	NSMutableDictionary *requestRouteMappers;
	NSMutableDictionary *responseRouteMappers;
}

+ (instancetype)sharedDataMapper {
	static RestKitWebApiDataMapper *shared;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[RestKitWebApiDataMapper alloc] init];
	});
	return shared;
}

- (id)init {
	if ( (self = [super init]) ) {
		requestRouteMappers = [[NSMutableDictionary alloc] initWithCapacity:8];
		responseRouteMappers = [[NSMutableDictionary alloc] initWithCapacity:8];
	}
	return self;
}

- (void)registerRequestObjectMapping:(RKObjectMapping *)objectMapping forRoutePath:(NSString *)path {
	requestRouteMappers[path] = objectMapping;
}

- (void)registerResponseObjectMapping:(RKObjectMapping *)objectMapping forRoutePath:(NSString *)path {
	responseRouteMappers[path] = objectMapping;
}

- (id<RKMappingOperationDataSource>)dataSourceForMappingOperation:(RKMappingOperation *)mappingOperation {
	// for now we assume non-Core Data objects! that will have to change if ever Core Data is supported
	static RKObjectMappingOperationDataSource *dataSource;
	if ( !dataSource ) {
		dataSource = [RKObjectMappingOperationDataSource new];
	}
	return dataSource;
}

- (RKObjectMapping *)requestObjectMappingForRoute:(id<WebApiRoute>)route object:(id)domainObject {
	RKObjectMapping *objectMapper = requestRouteMappers[route.path];
	if ( !objectMapper ) {
		// TODO: automatic, convention based lookup? Could base off of domainObject.class, for example.
	}
	return objectMapper;
}

- (RKObjectMapping *)responseObjectMappingForRoute:(id<WebApiRoute>)route data:(id)response {
	RKObjectMapping *objectMapper = responseRouteMappers[route.path];
	if ( !objectMapper ) {
		// TODO: automatic, convention based lookup? Could base off of response data, for example.
	}
	return objectMapper;
}

#pragma mark - WebApiDataMapper

- (NSMutableDictionary *)wrapEncoding:(NSMutableDictionary *)encoded withKeyPath:(NSString *)rootKeyPath {
	if ( !rootKeyPath ) {
		return encoded;
	}
	NSMutableDictionary *wrapper = [[NSMutableDictionary alloc] initWithCapacity:1];
	NSMutableDictionary *curr = wrapper;
	NSArray *components = [rootKeyPath componentsSeparatedByString:@"."];
	for ( NSInteger i = 0, len = [components count] - 1; i < len; i += 1 ) {
		NSMutableDictionary *next = [[NSMutableDictionary alloc] initWithCapacity:1];
		curr[components[i]] = next;
		curr = next;
	}
	curr[[components lastObject]] = encoded;
	return wrapper;
}

- (id)performEncodingWithObject:(id)domainObject route:(id<WebApiRoute>)route error:(NSError *__autoreleasing *)error {
	RKObjectMapping *objectMapping = [self requestObjectMappingForRoute:route object:domainObject];
	RKMappingOperation *mappingOperation = [[RKMappingOperation alloc] initWithSourceObject:domainObject
																		  destinationObject:[NSMutableDictionary new]
																					mapping:objectMapping];
	id<RKMappingOperationDataSource> dataSource = [self dataSourceForMappingOperation:mappingOperation];
	mappingOperation.dataSource = dataSource;
	[mappingOperation start];
	if ( mappingOperation.error ) {
		if ( error ) {
			*error = mappingOperation.error;
		}
	}
	NSMutableDictionary *encoded = mappingOperation.destinationObject;
	encoded = [self wrapEncoding:encoded withKeyPath:route[RestKitWebApiRoutePropertyRootKeyPath]];
	return encoded;
}

- (id)performMappingWithSourceObject:(id)sourceObject route:(id<WebApiRoute>)route error:(NSError *__autoreleasing *)error {
	return nil;
}

@end
