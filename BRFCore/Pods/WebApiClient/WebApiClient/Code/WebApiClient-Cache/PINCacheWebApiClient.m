//
//  PINCacheWebApiClient.m
//  WebApiClient-Cache
//
//  Created by Matt on 11/08/15.
//  Copyright (c) 2015 Blue Rocket. Distributable under the terms of the Apache License, Version 2.0.
//

#import "PINCacheWebApiClient.h"

#import <CommonCrypto/CommonDigest.h>
#import <BRCocoaLumberjack/BRCocoaLumberjack.h>
#import <PINCache/PINCache.h>
#import "NSDictionary+CachingWebApiClient.h"
#import "SupportingWebApiClient.h"
#import "WebApiClientCacheEntry.h"
#import "WebApiClientDigestUtils.h"

static NSString * const kKeyClassificationDelimiter = @"+";

static id<WebApiClient> SharedGlobalClient;

@implementation PINCacheWebApiClient {
	PINCache *entryCache;
	PINCache *dataCache;
	NSString *keyDiscriminator;
}

@synthesize entryCache, dataCache;
@synthesize keyDiscriminator;

+ (void)setSharedClient:(id<WebApiClient>)sharedClient {
	SharedGlobalClient = sharedClient;
}

+ (instancetype)sharedClient {
	static PINCacheWebApiClient *shared;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[self alloc] init];
	});
	return shared;
}

- (instancetype)init {
	return [self initWithEntryCache:[[PINCache alloc] initWithName:@"WebApiClient-Entry"]
						  dataCache:[[PINCache alloc] initWithName:@"WebApiClient-Data"]];
}

- (instancetype)initWithEntryCache:(PINCache *)theEntryCache dataCache:(PINCache *)theDataCache {
	NSParameterAssert(theEntryCache);
	if ( (self = [super init]) ) {
		entryCache = theEntryCache;
		dataCache = theDataCache;
		log4Debug(@"WebApiClient entry cache dir: %@", [theEntryCache.diskCache.cacheURL path]);
	}
	return self;
}

- (nullable NSString *)cacheKeyForRoute:(id<WebApiRoute>)route pathVariables:(nullable id)pathVariables parameters:(nullable id)parameters {
	NSURL *url = [self.client URLForRoute:route pathVariables:pathVariables parameters:parameters error:nil];
	if ( !url ) {
		return nil;
	}
	NSMutableString *key = [[NSMutableString alloc] initWithCapacity:64];
	[key appendString:route.method];
	if ( url.scheme ) {
		[key appendString:url.scheme];
	}
	[key appendString:@"://"];
	if ( url.host ) {
		[key appendString:url.host];
	}
	if ( url.port ) {
		[key appendString:@":"];
		[key appendString:[[url port] stringValue]];
	}
	[key appendString:[url path]];
	
	BOOL ignoreQueryParams = ([route respondsToSelector:@selector(isCacheIgnoreQueryParameters)]
							  ? ((id<CachingWebApiRoute>)route).cacheIgnoreQueryParameters : NO);
	if ( ignoreQueryParams == NO && [[url query] length] > 0 ) {
		// add to key using ordered query terms so URLs with same properties, but in different order, result in same cache key
		NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
		NSArray *queryItems = [components queryItems];
		NSArray *items = [[components queryItems] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
			NSURLQueryItem *left = obj1;
			NSURLQueryItem *right = obj2;
			NSComparisonResult result = [left.name compare:right.name];
			if ( result == NSOrderedSame ) {
				NSUInteger lIdx = [queryItems indexOfObjectIdenticalTo:obj1];
				NSUInteger rIdx = [queryItems indexOfObjectIdenticalTo:obj2];
				result = (lIdx < rIdx ? NSOrderedAscending : NSOrderedDescending);
			}
			return result;
		}];
		if ( items.count > 0 ) {
			[key appendString:@"?"];
			for ( NSURLQueryItem *item in items ) {
				[key appendString:item.name];
				[key appendString:@"="];
				[key appendString:item.value];
			}
		}
	}
	
	NSData *digest = CFBridgingRelease(WebApiClientMD5DigestCreateWithString((__bridge CFStringRef)key));
	NSString *hexDigest = CFBridgingRelease(WebApiClientHexEncodedStringCreateWithData((__bridge CFDataRef)digest));
	NSString *discriminator = self.keyDiscriminator;
	NSArray *keyComponents = (discriminator.length > 0
							  ? @[discriminator, route.name, hexDigest]
							  : @[route.name, hexDigest]);
	return [keyComponents componentsJoinedByString:kKeyClassificationDelimiter];
}

- (NSArray<NSHTTPCookie *> *)cookiesForAPI:(NSString *)name inCookieStorage:(NSHTTPCookieStorage *)cookieJar {
	return [self.client cookiesForAPI:name inCookieStorage:cookieJar];
}

- (nullable id<WebApiResponse>)blockingRequestAPI:(NSString *)name
								withPathVariables:(nullable id)pathVariables
									   parameters:(nullable id)parameters
											 data:(nullable id<WebApiResource>)data
									  maximumWait:(NSTimeInterval)maximumWait
											error:(NSError **)error {
	id<WebApiRoute> route = [self.client routeForName:name error:nil];
	NSTimeInterval cacheTTL = 0;
	NSString *cacheKey = nil;
	if ( [route respondsToSelector:@selector(cacheTTL)] ) {
		cacheTTL = ((id<CachingWebApiRoute>)route).cacheTTL;
		if ( cacheTTL > 0 ) {
			// look in cache for this data
			cacheKey = [self cacheKeyForRoute:route pathVariables:pathVariables parameters:parameters];
		}
	}
	id<WebApiResponse> (^delegateRequest)(void) = ^{
		__weak PINCache *weakDataCache = dataCache;
		__weak PINCache *weakEntryCache = entryCache;
		NSError *clientError = nil;
		id<WebApiResponse> response = [self.client blockingRequestAPI:name withPathVariables:pathVariables parameters:parameters data:data maximumWait:maximumWait error:&clientError];
		if ( cacheKey && response && clientError == nil && response.statusCode >= 200 && response.statusCode < 300 && [response conformsToProtocol:@protocol(NSCoding)]) {
			// valid response; cache the data
			WebApiClientCacheEntry *entry = [[WebApiClientCacheEntry alloc] initWithCreationTime:[NSDate timeIntervalSinceReferenceDate]
																					  expireTime:[[NSDate dateWithTimeIntervalSinceNow:cacheTTL] timeIntervalSinceReferenceDate]];
			[weakDataCache setObject:(id<NSCoding>)response forKey:cacheKey block:^(PINCache *cache, NSString *key, id __nullable object) {
				[weakEntryCache setObject:entry forKey:cacheKey block:nil];
			}];
		}
		if ( error == nil && response.statusCode >= 200 && response.statusCode < 300 ) {
			[self handleInvalidatedCachedDataForRoute:route];
		}
		if ( error && clientError ) {
			*error = clientError;
		}
		return response;
	};
	if ( cacheKey ) {
		WebApiClientCacheEntry *entry = [entryCache objectForKey:cacheKey];
		if ( [NSDate timeIntervalSinceReferenceDate] < entry.expires ) {
			// entry valid; return cached data
			id<WebApiResponse> response = [dataCache objectForKey:cacheKey];
			if ( !response ) {
				// cached data missing from cache; make request
				return delegateRequest();
			}
			return response;
		} else {
			// entry expired: clean out entry from cache
			[entryCache removeObjectForKey:cacheKey block:nil];
			[dataCache removeObjectForKey:cacheKey block:nil];
		}
		
		// not found in cache, or expired from cache
		return delegateRequest();
	} else {
		return delegateRequest();
	}
}

- (void)requestCachedAPI:(NSString *)name withPathVariables:(id)pathVariables parameters:(id)parameters
				   queue:(dispatch_queue_t)callbackQueue
				finished:(void (^)(id<WebApiResponse> _Nullable, NSError * _Nullable))callback {
	void (^doCallback)(id<WebApiResponse> _Nullable, NSError * _Nullable) = ^(id<WebApiResponse> _Nullable response, NSError * _Nullable error){
		dispatch_async(callbackQueue, ^{
			callback(response, error);
		});
	};
	id<WebApiRoute> route = [self.client routeForName:name error:nil];
	NSTimeInterval cacheTTL = 0;
	NSString *cacheKey = nil;
	if ( [route respondsToSelector:@selector(cacheTTL)] ) {
		cacheTTL = ((id<CachingWebApiRoute>)route).cacheTTL;
		if ( cacheTTL > 0 ) {
			// look in cache for this data
			cacheKey = [self cacheKeyForRoute:route pathVariables:pathVariables parameters:parameters];
		}
	}
	if ( cacheKey ) {
		[entryCache objectForKey:cacheKey block:^(PINCache *cache, NSString *key, id __nullable object) {
			WebApiClientCacheEntry *entry = object;
			if ( entry ) {
				if ( [NSDate timeIntervalSinceReferenceDate] < entry.expires ) {
					// entry valid; return cached data
					[dataCache objectForKey:cacheKey block:^(PINCache *cache, NSString *key, id __nullable object) {
						id<WebApiResponse> response = object;
						if ( response ) {
							doCallback(response, nil);
						} else {
							// cached data missing from cache; return nil
							doCallback(nil, nil);
						}
					}];
					return;
				} else {
					// entry expired: clean out entry from cache
					[entryCache removeObjectForKey:cacheKey block:nil];
					[dataCache removeObjectForKey:cacheKey block:nil];
				}
			}
			
			// not found in cache, or expired from cache
			doCallback(nil, nil);
		}];
	} else {
		doCallback(nil, nil);
	}
}

- (void)requestAPI:(NSString * __nonnull)name withPathVariables:(nullable id)pathVariables parameters:(nullable id)parameters
			  data:(nullable id<WebApiResource>)data finished:(void (^ __nonnull)(id<WebApiResponse> __nonnull, NSError * __nullable))callback {
	return [self requestAPI:name withPathVariables:pathVariables parameters:parameters data:data queue:dispatch_get_main_queue() progress:nil finished:callback];
}

- (void)requestAPI:(NSString *)name withPathVariables:(id)pathVariables parameters:(id)parameters
			  data:(id<WebApiResource>)data queue:(dispatch_queue_t)callbackQueue
		  progress:(nullable WebApiClientRequestProgressBlock)progressCallback
		  finished:(nonnull void (^)(id<WebApiResponse> _Nonnull, NSError * _Nullable))callback {
	void (^doCallback)(id<WebApiResponse> __nonnull, NSError * __nullable) = ^(id<WebApiResponse> __nonnull response, NSError * __nullable error){
		dispatch_async(callbackQueue, ^{
			callback(response, error);
		});
	};
	id<WebApiRoute> route = [self.client routeForName:name error:nil];
	NSTimeInterval cacheTTL = 0;
	NSString *cacheKey = nil;
	if ( [route respondsToSelector:@selector(cacheTTL)] ) {
		cacheTTL = ((id<CachingWebApiRoute>)route).cacheTTL;
		if ( cacheTTL > 0 ) {
			// look in cache for this data
			cacheKey = [self cacheKeyForRoute:route pathVariables:pathVariables parameters:parameters];
		}
	}

	[self requestCachedAPI:name withPathVariables:pathVariables parameters:parameters queue:callbackQueue finished:^(id<WebApiResponse>  _Nullable response, NSError * _Nullable error) {
		if ( response != nil ) {
			// found in cache: return immediately
			if ( progressCallback ) {
				int64_t totalUnits = [response.responseHeaders[@"Content-Length"] longLongValue];
				if ( totalUnits < 1 ) {
					totalUnits = 1;
				}
				NSProgress *downloadProgress = [NSProgress discreteProgressWithTotalUnitCount:totalUnits];
				downloadProgress.completedUnitCount = totalUnits;
				progressCallback(name, nil, downloadProgress);
			}
			doCallback(response, error);
			return;
		}
		// not found in cache, or cache not supported
		__weak PINCache *weakDataCache = dataCache;
		__weak PINCache *weakEntryCache = entryCache;
		[self.client requestAPI:name withPathVariables:pathVariables parameters:parameters data:data queue:callbackQueue progress:progressCallback finished:^(id<WebApiResponse> __nonnull response, NSError * __nullable error) {
			if ( cacheKey && response && error == nil && response.statusCode >= 200 && response.statusCode < 300 && [response conformsToProtocol:@protocol(NSCoding)]) {
				// valid response; cache the data
				WebApiClientCacheEntry *entry = [[WebApiClientCacheEntry alloc] initWithCreationTime:[NSDate timeIntervalSinceReferenceDate]
																						  expireTime:[[NSDate dateWithTimeIntervalSinceNow:cacheTTL] timeIntervalSinceReferenceDate]];
				[weakDataCache setObject:(id<NSCoding>)response forKey:cacheKey block:^(PINCache *cache, NSString *key, id __nullable object) {
					[weakEntryCache setObject:entry forKey:cacheKey block:nil];
				}];
			}
			if ( error == nil && response.statusCode >= 200 && response.statusCode < 300 ) {
				[self handleInvalidatedCachedDataForRoute:route];
			}
			doCallback(response, error);
		}];
	}];
}

- (void)handleInvalidatedCachedDataForRoute:(id<WebApiRoute>)route {
	if ( ![route respondsToSelector:@selector(invalidatesCachedRouteNames)] ) {
		return;
	}
	id<CachingWebApiRoute> cachingRoute = (id<CachingWebApiRoute>)route;
	NSArray<NSString *> *invalidatedRouteNames = cachingRoute.invalidatesCachedRouteNames;
	if ( invalidatedRouteNames.count < 1 ) {
		return;
	}
	NSMutableSet<NSString *> *invalidCacheKeyPrefixes = [[NSMutableSet alloc] initWithCapacity:invalidatedRouteNames.count];
	NSString *discriminator = self.keyDiscriminator;
	for ( NSString *routeName in invalidatedRouteNames ) {
		NSArray *keyComponents = (discriminator.length > 0 ? @[discriminator, routeName, @""] : @[routeName, @""]);
		NSString *prefix = [keyComponents componentsJoinedByString:kKeyClassificationDelimiter];
		[invalidCacheKeyPrefixes addObject:prefix];
	}
	[entryCache.memoryCache enumerateObjectsWithBlock:^(PINMemoryCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
		for ( NSString *prefix in invalidCacheKeyPrefixes ) {
			if ( [key hasPrefix:prefix] ) {
				log4Debug(@"Route %@ has invalidated memory cached data for key %@", route.name, key);
				[cache removeObjectForKey:key block:nil];
				return;
			}
		}
	}];
	[entryCache.diskCache enumerateObjectsWithBlock:^(PINDiskCache * _Nonnull cache, NSString * _Nonnull key, id<NSCoding>  _Nullable object, NSURL * _Nonnull fileURL) {
		for ( NSString *prefix in invalidCacheKeyPrefixes ) {
			if ( [key hasPrefix:prefix] ) {
				log4Debug(@"Route %@ has invalidated disk cached data for key %@", route.name, key);
				[cache removeObjectForKey:key block:nil];
				return;
			}
		}
	}];
}

#pragma mark - SupportingWebApiClient

- (nullable id<WebApiRoute>)routeForName:(NSString *)name error:(NSError * __nullable __autoreleasing *)error {
	id<WebApiRoute> route = nil;
	if ( [self.client respondsToSelector:@selector(routeForName:error:)] ) {
		route = [self.client routeForName:name error:error];
	}
	return route;
}

- (NSURL *)URLForRoute:(id<WebApiRoute>)route
		 pathVariables:(nullable id)pathVariables
			parameters:(nullable id)parameters
				 error:(NSError * __autoreleasing *)error {
	NSURL *result = nil;
	if ( [self.client respondsToSelector:@selector(URLForRoute:pathVariables:parameters:error:)] ) {
		result = [self.client URLForRoute:route pathVariables:pathVariables parameters:parameters error:error];
	}
	return result;
}


@end
