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

static id<WebApiClient> SharedGlobalClient;

@implementation PINCacheWebApiClient {
	PINCache *entryCache;
	PINCache *dataCache;
}

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
	}
	return self;
}

- (NSString *)MD5Hash:(NSString *)str {
	const char *cstr = [str UTF8String];
	unsigned char result[16];
	CC_MD5(cstr, (CC_LONG)strlen(cstr), result);
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];
}

- (nullable NSString *)cacheKeyForRoute:(id<WebApiRoute>)route pathVariables:(nullable id)pathVariables parameters:(nullable id)parameters {
	NSURL *url = [self.client URLForRoute:route pathVariables:pathVariables parameters:parameters error:nil];
	if ( !url ) {
		return nil;
	}
	NSMutableString *key = [[NSMutableString alloc] initWithCapacity:64];
	[key appendString:route.method];
	[key appendString:[url host]];
	[key appendString:[[url port] stringValue]];
	[key appendString:[url path]];
	
	if ( [[url query] length] > 0 ) {
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
	
	return [self MD5Hash:key];
}

- (void)requestAPI:(NSString * __nonnull)name withPathVariables:(nullable id)pathVariables parameters:(nullable id)parameters
			  data:(nullable id<WebApiResource>)data finished:(void (^ __nonnull)(id<WebApiResponse> __nonnull, NSError * __nullable))callback {
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
	void (^delegateRequest)(void) = ^{
		__weak PINCache *weakDataCache = dataCache;
		__weak PINCache *weakEntryCache = entryCache;
		[self.client requestAPI:name withPathVariables:pathVariables parameters:parameters data:data finished:^(id<WebApiResponse> __nonnull response, NSError * __nullable error) {
			if ( cacheKey && response && error == nil && response.statusCode >= 200 && response.statusCode < 300 && [response conformsToProtocol:@protocol(NSCoding)]) {
				// valid response; cache the data
				WebApiClientCacheEntry *entry = [[WebApiClientCacheEntry alloc] initWithCreationTime:[NSDate timeIntervalSinceReferenceDate]
																						  expireTime:[[NSDate dateWithTimeIntervalSinceNow:cacheTTL] timeIntervalSinceReferenceDate]];
				[weakDataCache setObject:(id<NSCoding>)response forKey:cacheKey block:^(PINCache *cache, NSString *key, id __nullable object) {
					[weakEntryCache setObject:entry forKey:cacheKey block:nil];
				}];
			}
			callback(response, error);
		}];
	};
	if ( cacheKey ) {
		[entryCache objectForKey:cacheKey block:^(PINCache *cache, NSString *key, id __nullable object) {
			WebApiClientCacheEntry *entry = object;
			if ( entry ) {
				if ( [NSDate timeIntervalSinceReferenceDate] < entry.expires ) {
					// entry valid; return cached data
					[dataCache objectForKey:cacheKey block:^(PINCache *cache, NSString *key, id __nullable object) {
						id<WebApiResponse> response = object;
						if ( response ) {
							callback(response, nil);
						} else {
							// cached data missing from cache; make request
							delegateRequest();
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
			delegateRequest();
		}];
	} else {
		delegateRequest();
	}
}

@end
