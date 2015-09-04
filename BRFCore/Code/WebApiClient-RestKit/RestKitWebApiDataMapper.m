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

NSString * const RestKitWebApiRoutePropertyRequestRootKeyPath = @"dataMapperRequestRootKeyPath";
NSString * const RestKitWebApiRoutePropertyResponseRootKeyPath = @"dataMapperResponseRootKeyPath";

@implementation RestKitWebApiDataMapper {
	NSMutableDictionary *requestRouteMappers;
	NSMutableDictionary *requestRouteBlockMappers;
	NSMutableDictionary *responseRouteMappers;
	NSMutableDictionary *responseRouteBlockMappers;
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
		requestRouteBlockMappers = [[NSMutableDictionary alloc] initWithCapacity:8];
		responseRouteMappers = [[NSMutableDictionary alloc] initWithCapacity:8];
		responseRouteBlockMappers = [[NSMutableDictionary alloc] initWithCapacity:8];
	}
	return self;
}

- (void)registerRequestObjectMapping:(RKObjectMapping *)objectMapping forRouteName:(NSString *)name {
	requestRouteMappers[name] = objectMapping;
}

- (void)registerRequestMappingBlock:(RestKitWebApiDataMapperBlock)block forRouteName:(NSString *)name {
	requestRouteBlockMappers[name] = [block copy];
}

- (void)registerResponseObjectMapping:(RKObjectMapping *)objectMapping forRouteName:(NSString *)name {
	responseRouteMappers[name] = objectMapping;
}

- (void)registerResponseMappingBlock:(RestKitWebApiDataMapperBlock)block forRouteName:(NSString *)name {
	responseRouteBlockMappers[name] = [block copy];
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
	RKObjectMapping *objectMapper = requestRouteMappers[route.name];
	if ( !objectMapper ) {
		// TODO: automatic, convention based lookup? Could base off of domainObject.class, for example.
	}
	return objectMapper;
}

- (RestKitWebApiDataMapperBlock)requestMappingBlockForRoute:(id<WebApiRoute>)route {
	return requestRouteBlockMappers[route.name];
}

- (RKObjectMapping *)responseObjectMappingForRoute:(id<WebApiRoute>)route data:(id)response {
	RKObjectMapping *objectMapper = responseRouteMappers[route.name];
	if ( !objectMapper ) {
		// TODO: automatic, convention based lookup? Could base off of response data, for example.
	}
	return objectMapper;
}

- (RestKitWebApiDataMapperBlock)responseMappingBlockForRoute:(id<WebApiRoute>)route {
	return responseRouteBlockMappers[route.name];
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
	encoded = [self wrapEncoding:encoded withKeyPath:route[RestKitWebApiRoutePropertyRequestRootKeyPath]];
	
	// check for block mapper
	RestKitWebApiDataMapperBlock blockMapper = [self requestMappingBlockForRoute:route];
	if ( blockMapper ) {
		encoded = blockMapper(encoded, route, error);
	}
	
	return encoded;
}

- (id)performMappingWithSourceObject:(id)sourceObject route:(id<WebApiRoute>)route error:(NSError *__autoreleasing *)error {
	RKObjectMapping *objectMapping = [self responseObjectMappingForRoute:route data:sourceObject];
	id decodeSource = sourceObject;
	if ( route[RestKitWebApiRoutePropertyResponseRootKeyPath] ) {
		decodeSource = [sourceObject valueForKeyPath:route[RestKitWebApiRoutePropertyResponseRootKeyPath]];
	}
	RKMappingOperation *mappingOperation = [[RKMappingOperation alloc] initWithSourceObject:decodeSource
																		  destinationObject:nil
																					mapping:objectMapping];
	id<RKMappingOperationDataSource> dataSource = [self dataSourceForMappingOperation:mappingOperation];
	mappingOperation.dataSource = dataSource;
	[mappingOperation start];
	if ( mappingOperation.error ) {
		if ( error ) {
			*error = mappingOperation.error;
		}
	}
	id result = mappingOperation.destinationObject;

	// check for block mapper
	RestKitWebApiDataMapperBlock blockMapper = [self responseMappingBlockForRoute:route];
	if ( blockMapper ) {
		result = blockMapper(result, route, error);
	}
	
	return result;
}

@end
