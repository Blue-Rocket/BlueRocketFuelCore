# WebApiClient

**WebApiClient** is an application framework aimed at making RESTful web service
requests in a standardized way. It works by configuring named routes for each web
service endpoint so your application focuses on consuming the logical web service
API, not HTTP implementation details.

The project is divided into modules, staring with a **Core** module and then
branching off into various supporting modules that add functionality like [object
mapping](#module-restkit), [caching](#module-cache), and [UI support](#module-ui).

# Module: Core

The **Core** module provides a HTTP client framework based on _routes_ with support
for _object mapping_ for transforming requests and responses between native objects
and serialized forms, such as JSON. This module provides just a protocol based API
and some scaffolding classes to support the API, but does not provide an actual full
implementation itself, so that different HTTP back-ends can be used as needed. The
[AFNetworking module](#module-afnetworking) provides a full implementation of the API.

The
[WebApiClient][WebApiClient] protocol defines the main HTTP client entry point for
applications to use. The API is purposefully simple and based on asynchronous block
callbacks:

```objc
- (void)requestAPI:(NSString *)name
 withPathVariables:(id)pathVariables
        parameters:(id)parameters
              data:(id<WebApiResource>)data
		  finished:(void (^)(id<WebApiResponse> response, NSError *error))callback;
```

An example invocation of this API might look like this:

```objc
// make a GET request to /documents/123
[client requestAPI:@"doc" withPathVariables:@{@"uniqueId" : @123 } parameters:nil data:nil
          finished:^(id<WebApiResponse> response, NSError *error) {
	if ( !error ) {
		MyDocument *doc = response.responseObject;
	} else if ( response.statusCode == 422 ) {
		// handle 422 (validation) errors here...
	}
}];
```

## Background callback support

By default the callback block is called on the main thread (queue). If you prefer to
have the callabck on a specific queue, you can use an alternate method that accepts a
dispatch queue as a parameter. In that case, the passed in queue will be used for the
callback:

```objc
- (void)requestAPI:(NSString *)name
 withPathVariables:(id)pathVariables
        parameters:(id)parameters
              data:(id<WebApiResource>)data
             queue:(dispatch_queue_t)callbackQueue
          progress:(nullable WebApiClientRequestProgressBlock)progressCallback
		  finished:(void (^)(id<WebApiResponse> response, NSError *error))callback;
```

## Progress callback support

The same method that accepts an explicit callback block shown in the previous section
also accepts an optional `WebApiClientRequestProgressBlock`, which is defined as this:

```objc
typedef void (^WebApiClientRequestProgressBlock)(NSString *routeName,
                                                 NSProgress * _Nullable uploadProgress,
                                                 NSProgress * _Nullable downloadProgress);
```

By passing in this type of block to the `progress` parameter, you can monitor both
the upload and download progress of the HTTP request. In addition the
`WebApiClientRequestDidProgressNotification` and
`WebApiClientResponseDidProgressNotification` notifications can be used to listen for
progress updates as well. The `WebApiClientProgressNotificationKey` notification user
info key will contain the relevant `NSProgress` object.

## Synchronous request support

Sometimes it can be useful to make a blocking, synchronous request to get a HTTP
resource. WebApiClient supports that as well:

```objc
- (id<WebApiResponse>)blockingRequestAPI:(NSString *)name
                       withPathVariables:(id)pathVariables
                              parameters:(id)parameters
                                    data:(id<WebApiResource>)data
                             maximumWait:(NSTimeInterval)maximumWait
                                   error:(NSError **)error;
```

Calling this method will block the calling thread until either the response is
available or `maximumWait` seconds have elapsed.

## Routing

The [WebApiRoute][WebApiRoute] protocol defines a single API endpoint definition,
assigned a unique name. Routes are typically configured when an application starts
up. Each route defines some standardized properties, such as a HTTP `method` and URL
`path`. For convenience, routes support arbitrary property access via Objective-C's
keyed subscript support, so the following is possible:

```objc
id<WebApiRoute> myRoute = ...;

// access the path property
NSString *path1 = myRoute.path;

// access the path property using keyed subscript notation
NSString *path2 = myRoute[@"path"];

// access some arbitrary property not defined in WebApiRoute specifically
id something = myRoute[@"extendedProperty"];
```

For even more convenience, WebApiRoute provides
[extensions][NSDictionary-WebApiRoute] to `NSDictionary` and `NSMutableDictionary` so
that they conform to `WebApiRoute` and `MutableWebApiRoute`, respectively. That means
you can use dictionaries directly as routes, like this:

```objc
// define a route
id<WebApiRoute> myRoute = @{ @"name" : "login", @"path" : @"user/login", @"method" : @"POST" };

// create a mutable copy and extend
id<MutableWebApiRoute> mutableRoute = [myRoute mutableCopy];
mutableRoute[@"extendedProperty"] = @"special";
```

## Object mapping

The [WebApiDataMapper][WebApiDataMapper] protocol defines an API for _encoding_
native objects into HTTP requests and _mapping_ HTTP responses into native objects.
Routes can be configured with a `dataMapper` property to support this feature. The
API is also pretty simple:

```objc
@protocol WebApiDataMapper <NSObject>

// Map a source data object into some domain object.
- (id)performMappingWithSourceObject:(id)sourceObject route:(id<WebApiRoute>)route error:(NSError *__autoreleasing *)error;

// Encode a domain object into an encoded form, such as @c NSDictionary or @c NSData.
- (id)performEncodingWithObject:(id)domainObject route:(id<WebApiRoute>)route error:(NSError *__autoreleasing *)error;

@end
```

# Module: AFNetworking

The **AFNetworking** module provides a full implementation of the `WebApiClient` API,
based on [AFNetworking][afn] and `NSURLSession`.

## Route configuration

Routes can be configured in code via the `registerRoute:forName:` method, but more
conveniently they can be configured via [BREnvironment][brenv]. The `webservice.api`
key will be inspected by default, and can be a dictionary representing all the routes
that should be registered for the application. For example, the following JSON would
register three routes, `login`, `register`, and `absolute`:

```json
{
  "App_webservice_protocol" : "https",
  "App_webservice_host" : "example.com",
  "App_webservice_port" : 443,
  "webservice" : {
    "api" : {
      "register" : {
        "method" : "POST",
        "path" : "user/register",
      },
      "login" : {
        "method" : "POST",
        "path" : "user/login",
      },
      "absolute" : {
        "method" : "GET",
        "path" : "https://example.com/something"
      }
    }
  }
}
```

You'll notice that the `register` and `login` routes have relative paths. All
webservice URLs are constructed as relative to a configurable `baseApiURL` property,
which by default is configured via the various `App_webservice_*`
[BREnvironment][brenv] keys you can see in the previous example JSON.

### GZip compression support

The `gzip` property on routes is supported. When set to `true` any _request_ data
will be compressed and a request HTTP header of `Content-Encoding: gzip` will be
added.

To support compressed _response_ data (highly recommended!) you only need to
configure an `Accept-Encoding: gzip` HTTP header, either individually on routes via
the `requestHeaders` property or via the `globalHTTPRequestHeaders` property
available on `AFNetworkingWebApiClient`.

Here's an example route that configures both request and response compression:

```json
{
  "webservice" : {
    "api" : {
      "trim" : {
        "method" : "POST",
        "path" : "upload/jumbo",
        "gzip" : true,
        "requestHeaders" : {
          "Accept-Encoding" : "gzip"
        }
      }
    }
  }
}
```

### Upload raw data

Raw data can be uploaded directly in the body of the HTTP request. This can be
useful, for example, when you need to upload images, or any other type of data, and
the URL contains sufficient information to identify the content. To perform a raw
data upload, pass a [WebApiResource][WebApiResource] instance on the `data` parameter
in the WebApiClient API. WebApiClient provides two implementations of
`WebApiResource`: `DataWebApiResource` for in-memory data and `FileWebApiResource`
for file-based data. The `WebApiResource` instance you pass in will be sent directly
in the body of the request, and appropriate `Content-Type` and `Content-MD5` HTTP
headers will be included. This means the `parameters` object is ignored. If you need
to post both parameters _and_ a file, use the `multipart/form-data` upload method
described in the next section.

### Upload data (multipart/form-data)

Instead of uploading raw data, you can also upload using a `multipart/form-data`
attachment encoding by passing a [WebApiResource][WebApiResource] instance on the
`data` parameter in the WebApiClient API and configuring the route with a
serialization type of `form`, like this:

```json
{
  "webservice" : {
    "api" : {
      "trim" : {
        "method" : "POST",
        "path" : "upload/image",
        "serializationName" : "form"
      }
    }
  }
}
```

The WebApiClient API `parameters` object, if provided, will also be included in the
request, serialized into additional parts of the request body.

### Download raw data

You can configure a route to save the response data into a file, instead of the
default of loading the response in RAM, by adding a `saveAsResource` property with a
_truthy_ value, like this:

```json
{
  "webservice" : {
    "api" : {
      "download" : {
        "method" : "GET",
        "path" : "download/image",
        "saveAsResource" : true
      }
    }
  }
}
```

Then the `responseObject` returned in the `WebApiResponse` will be a
[WebApiResource][WebApiResource] which you can then move to an appropriate location
as needed, for example:

```objc
[client requestAPI:@"download" withPathVariables:nil parameters:nil data:nil
             queue:dispatch_get_main_queue()
          progress:nil
          finished:^(id<WebApiResponse> response, NSError *error) {
    if ( !error ) {
        id<WebApiResource> resource = response.responseObject;
        NSURL *dest = [NSURL fileURLWithPath:@"/some/path"];
        [[NSFileManager defaultManager] moveItemAtURL:[resource URLValue] toURL:dest error:nil];
    }
}];
```


# Module: Cache

The **Cache** module provides response caching support to the `WebApiClient` API by
providing the [`PINCacheWebApiClient`][PINCacheWebApiClient] proxy  that can cache
result objects using [PINCache][pcache]. Caching support is enabled by configuring a
`cacheTTL` property on routes, for example:

```json
{
  "webservice" : {
    "api" : {
      "info" : {
        "method" : "GET",
        "path" : "infrequentlyupdated/info",
        "cacheTTL" : 3600
      }
    }
  }
}
```

See the [CachingWebApiRoute][CachingWebApiRoute] protocol for more route cache
details.

## Routes that invalidate cached data for other routes

You can also configure a route so that it invalidates any cached data for _other_
routes. A good example of where this is useful is when you define a _list_ route that
returns a list of objects, and another _add_ route to add to that same list of
objects. We can make the latter route invalidate the cached data of the former like
this:

```json
{
  "webservice" : {
    "api" : {
      "list" : {
        "method" : "GET",
        "path" : "stuff/list",
        "cacheTTL" : 3600
      },
      "add" : {
        "method" : "PUT",
        "path" : "stuff/:thingId",
        "invalidatesCachedRouteNames" : [ "list" ]
      }
    }
  }
}
```

The `invalidatesCachedRouteNames` is configured as an array of route names that
should be invalidated when that route is called successfully.

## Ignoring route URL query parameters

By default URL query parameters will be included when calculating the cache key for
each route. Sometimes it can be useful to ignore the query parameters, however. For
example, pre-signed Amazon S3 resource URLs contain authorization query parameters
that change each time the same resource is requested. By configuring the route with
`cacheIgnoreQueryParameters = YES` then the query parameters for that route will be
**not** be included in the request's cache key:

```json
{
  "webservice" : {
    "api" : {
      "info" : {
        "method" : "GET",
        "path" : "https://s3.amazon.com/info/foo.txt",
        "cacheTTL" : 3600,
        "cacheIgnoreQueryParameters" : true
      }
    }
  }
}
```

## Cache groups for multi-user support

[`PINCacheWebApiClient`][PINCacheWebApiClient] supports a `keyDiscriminator` property
that can be changed at runtime to support isolating all cached route data into
groups. The main use case for this is to support multi-user apps where route URLs do
not contain user-identifying parameters, so when different users are signed in they
don't see cached data from some other user. You can assign the active user's unique
identifier to the `keyDiscriminator` property and then all cached data becomes
user-specific. When a user logs out and a different user logs in, change the
`keyDiscriminator` to the new user's identifier.

## Checking for cached data

The [`CachingWebApiClient`][CachingWebApiClient] API adds a method that can be used
for testing if cached data is available:

```objc
- (void)requestCachedAPI:(NSString *)name
       withPathVariables:(nullable id)pathVariables
              parameters:(nullable id)parameters
                   queue:(dispatch_queue_t)callbackQueue
                finished:(void (^)(id<WebApiResponse> _Nullable response, NSError * _Nullable error))callback;
```

The callback will be passed a response only if the data was available in the cache.
Sometimes its handy to know if something is already downloaded!


# Module: RestKit

The **RestKit** module provides an _object mapping_ implementation for the
`WebApiClient` API based on the [RestKit][rk]. It provides a way to transform native
objects into JSON, and vice versa. This module only makes use of the
`RestKit/ObjectMapping` module, so it does not conflict with AFNetworking 2. In fact,
part of the motivation for WebApiClient was to be able to use AFNetworking 2 with
RestKit's object mapping support because RestKit's networking layer is based on
AFNetworking 1. In some respects the WebApiClient API provides some of the same
scaffolding that the full RestKit project provides.

## Mapping configuration

The [`RestKitWebApiDataMapper`][RestKitWebApiDataMapper] class supports a shared
singleton pattern that your application can configure when it starts up with any
required `RKObjectMapping` objects. You configure it like this:

```objc
RestKitWebApiDataMapper *dataMapper = [RestKitWebApiDataMapper sharedDataMapper];

// get RestKit mapper for user objects
RKObjectMapper *userObjectMapper = ...;

// register user mapper for requests and responses
[dataMapper registerRequestObjectMapping:[userObjectMapper inverseMapping] forRouteName:@"login"];
[dataMapper registerResponseObjectMapping:userObjectMapper forRouteName:@"login"];
```

## Block-based encoding & mapping

The [`RestKitWebApiDataMapper`][RestKitWebApiDataMapper] class also supports
block-based mapping hooks for both request encoding and response mapping. The blocks
are executed _after_ any configured `RKObjectMapper` has done its job on the request
or response data.

One useful example of this support is for wiring up parent-child relationship
properties that are implied by the data. Imagine a `Person` class that has an array
of child `Person` objects, and each child has a `parent` property that points to its
parent `Person` instance:

```objc
@interface Person : NSObject

@property (strong) NSString *name;
@property (strong) NSArray<Person *> *children;
@property (weak) Person *parent;

@end
```

The server returns JSON like this:

```json
{
  "name" : "John Doe",
  "children" : [
    { "name" : "Johnny Doe" },
    { "name" : "Jane Doe" }
  ]
}
```

To populate each child's `parent` property with the **John Doe** object, a response
mapping block could be configured like this:

```objc
[dataMapper registerResponseMappingBlock:^(id sourceObject, id<WebApiRoute> route, NSError * __autoreleasing *error) {
	if ( [sourceObject isKindOfClass:[Person class]] ) {
		// populate the Child -> Parent relationship
		Person *parent = sourceObject;
		for ( Person *child in parent.children ) {
			child.parent = parent;
		}
	}
	return sourceObject;
} forRouteName:@"parent-child-tree"];
```


## Route configuration

To use RestKit-based object mapping with a route, you configure the `dataMapper`
property of the route with `RestKitWebApiDataMapper` like this:

```json
{
  "webservice" : {
    "api" : {
      "login" : {
        "method" : "POST",
        "path" : "user/login",
        "dataMapper" : "RestKitWebApiDataMapper"
      }
    }
  }
}
```

Sometimes the request or response JSON needs to be nested in some top-level object.
For example imagine that the register endpoint expects the user object to be posted
as JSON like this:

```json
{
  "user" : { "email" : "joe@example.com", "name" : "Joe" }
}
```

This can be done by adding a `dataMapperRequestRootKeyPath` property (or
`dataMapperResponseRootKeyPath` for mapping responses), like this:

```json
{
  "webservice" : {
    "api" : {
      "login" : {
        "method" : "POST",
        "path" : "user/login",
        "dataMapper" : "RestKitWebApiDataMapper",
        "dataMapperRequestRootKeyPath" : "user"
      }
    }
  }
}
```


# Module: UI

The **UI** module provides some UI utilities, such as the
[`WebApiClientActivitySupport`][WebApiClientActivitySupport] class that listens to
route requests and for those that specify `preventUserInteraction` with a truthy
value will throw up a full-screen "request taking too long" view to let the user of
the app know it's waiting for a response. For example, a route can be configured like:

```json
{
  "webservice" : {
    "api" : {
      "login" : {
        "method" : "POST",
        "path" : "user/login",
        "preventUserInteraction" : true
      }
    }
  }
}
```


 [cocoapods]: https://cocoapods.org/
 [brenv]: https://github.com/Blue-Rocket/BREnvironment
 [afn]: https://github.com/AFNetworking/AFNetworking
 [rk]: https://github.com/RestKit/RestKit
 [pcache]: https://github.com/pinterest/PINCache
 [CachingWebApiClient]: https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient-Cache/CachingWebApiClient.h
 [CachingWebApiRoute]: https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient-Cache/CachingWebApiRoute.h
 [NSDictionary-WebApiRoute]: https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient/NSDictionary%2BWebApiClient.h
 [PINCacheWebApiClient]: https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient-Cache/PINCacheWebApiClient.h
 [RestKitWebApiDataMapper]: https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient-RestKit/RestKitWebApiDataMapper.h
 [WebApiClient]: https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient/WebApiClient.h
 [WebApiClientActivitySupport]: https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient-UI/WebApiClientActivitySupport.h
 [WebApiDataMapper]: https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient/WebApiDataMapper.h
 [WebApiResource]: https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient/WebApiResource.h
 [WebApiRoute]: https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient/WebApiRoute.h
