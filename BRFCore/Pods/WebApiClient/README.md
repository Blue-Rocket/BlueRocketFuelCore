# WebApiClient

**WebApiClient** is an application framework aimed at making RESTful web service requests in a standardized way. The project is divided into modules, staring with a **Core** module and then branching off into various supporting modules.

# Module: Core

The **Core** module provides a HTTP client framework based on _routes_ with support for _object mapping_ for transforming requests and responses between native objects and serialized forms, such as JSON. This module provides just a protocol based API and some scaffolding classes to support the API, but does not provide an actual full implementation itself, so that different HTTP back-ends can be used as needed (see the **AFNetworking** module provides a full implementation).

The [WebApiClient](https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient/WebApiClient.h) protocol defines the main HTTP client entry point for applications to use. The API is purposefully simple and based on asynchronous block callbacks:

```objc
- (void)requestAPI:(NSString *)name 
 withPathVariables:(id)pathVariables 
        parameters:(id)parameters 
              data:(id)data
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

## Routing

The [WebApiRoute](https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient/WebApiRoute.h) protocol defines a single API endpoint definition, assigned a unique name. Routes are typically configured when an application starts up. Each route defines some standardized properties, such as a HTTP `method` and URL `path`. For convenience, routes support arbitrary property access via Objective-C's keyed subscript support, so the following is possible:

```objc
id<WebApiRoute> myRoute = ...;

// access the path property
NSString *path1 = myRoute.path;

// access the path property using keyed subscript notation
NSString *path2 = myRoute[@"path"];

// access some arbitrary property not defined in WebApiRoute specifically
id something = myRoute[@"extendedProperty"];
```

For even more convenience, WebApiRoute provides [extensions](https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient/NSDictionary%2BWebApiClient.h) to `NSDictionary` and `NSMutableDictionary` so that they conform to `WebApiRoute` and `MutableWebApiRoute`, respectively. That means you can use dictionaries directly as routes, like this:

```objc
// define a route
id<WebApiRoute> myRoute = @{ @"name" : "login", @"path" : @"user/login", @"method" : @"POST" };

// create a mutable copy and extend
id<MutableWebApiRoute> mutableRoute = [myRoute mutableCopy];
mutableRoute[@"extendedProperty"] = @"special";
```

## Object mapping

The [WebApiDataMapper](https://github.com/Blue-Rocket/WebApiClient/blob/master/WebApiClient/Code/WebApiClient/WebApiDataMapper.h) protocol defines an API for _encoding_ native objects into HTTP requests and _mapping_ HTTP responses into native objects. Routes can be configured with a `dataMapper` property to support this feature. The API is also pretty simple:

```objc
@protocol WebApiDataMapper <NSObject>

// Map a source data object into some domain object.
- (id)performMappingWithSourceObject:(id)sourceObject route:(id<WebApiRoute>)route error:(NSError *__autoreleasing *)error;

// Encode a domain object into an encoded form, such as @c NSDictionary or @c NSData.
- (id)performEncodingWithObject:(id)domainObject route:(id<WebApiRoute>)route error:(NSError *__autoreleasing *)error;

@end
```

# Module: AFNetworking

The **AFNetworking** module provides a full implementation of the `WebApiClient` API, based on [AFNetworking][afn] and `NSURLSession`.

## Route configuration

Routes can be configured in code via the `registerRoute:forName:` method, but more conveniently they can be configured via [BREnvironment][brenv]. The `webservice.api` key will be inspected by default, and can be a dictionary representing all the routes that should be registered for the application. For example, the following JSON would register two routes, `login` and `register`:

```json
{
	"webservice" : {
		"api" : {
			"register" : {
				"method" : "POST",
				"path" : "user/register",
			},
			"login" : {
				"method" : "POST",
				"path" : "user/login",
			}
		}
	}
}
```


# Module: Cache

The **Cache** module provides response caching support to the `WebApiClient` API by providing the `PINCacheWebApiClient` proxy  that can cache result objects using [PINCache][pcache]. Caching support is enabled by configuring a `cacheTTL` property on routes, for example:

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


# Module: RestKit

The **RestKit** module provides an _object mapping_ implementation for the `WebApiClient` API based on the [RestKit][rk]. It provides a way to transform native objects into JSON, and vice versa. This module only makes use of the `RestKit/ObjectMapping` module, so it does not conflict with AFNetworking 2. In fact, part of the motivation for WebApiClient was to be able to use AFNetworking 2 with RestKit's object mapping support because RestKit's networking layer is based on AFNetworking 1. In some respects the WebApiClient API provides some of the same scaffolding that the full RestKit project provides.

## Mapping configuration

The `RestKitWebApiDataMapper` class supports a shared singleton pattern that your application can configure when it starts up with any required `RKObjectMapping` objects. You configure it like this:

```objc
RestKitWebApiDataMapper *dataMapper = [RestKitWebApiDataMapper sharedDataMapper];

// get RestKit mapper for user objects
RKObjectMapper *userObjectMapper = ...;

// register user mapper for requests and responses
[dataMapper registerRequestObjectMapping:[userObjectMapper inverseMapping] forRouteName:@"login"];
[dataMapper registerResponseObjectMapping:userObjectMapper forRouteName:@"login"];
```

## Route configuration

To use RestKit-based object mapping with a route, you configure the `dataMapper` property of the route with `RestKitWebApiDataMapper` like this:

```JSON
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

Sometimes the request or response JSON needs to be nested in some top-level object. For example imagine that the register endpoint expects the user object to be posted as JSON like this:

```JSON
{
  "user" : { "email" : "joe@example.com", "name" : "Joe" }
}
```

This can be done by adding a `dataMapperRequestRootKeyPath` property (or `dataMapperResponseRootKeyPath` for mapping responses), like this:

```JSON
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

The **UI** module provides some UI utilities, such as the `WebApiClientActivitySupport` class that listens to route requests and for those that specify `preventUserInteraction` with a truthy value will throw up a full-screen "request taking too long" view to let the user of the app know it's waiting for a response. For example, a route can be configured like:

```JSON
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
