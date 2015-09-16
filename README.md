# Blue Rocket Fuel Core

This project provides core modules to help kick start iOS applications. It works in tandem with the [BlueRocketFuelAppp][brfa] starter project. Each module is available as a Cocoapod _subspec_ and can be imported into projects like

```ruby
pod 'BlueRocketFuelCore/Core'
```

By default all modules will be imported if your `Podfile` contains just

```ruby
pod 'BlueRocketFuelCore'
```


# Module: Core

The **Core** module provides basic support for the following areas:

 * a _user_ domain object
 * a simple [keychain service](https://github.com/Blue-Rocket/BlueRocketFuelCore/blob/msm/Code/Core/BRKeychainService.h) for saving sensitive information in the OS keychain
 * a localization framework based on a JSON strings file format
 * a configuration framework based on [BREnvironment][brenv] and a JSON configuration file format
 * various utilities, such as date formatting and validation
 
# Module: UI

The **UI** module provides UI components and support for the following areas:

 * NIB object and view localization based on the `Core` module localization framework
 * an _options tray_ view controller for application navigation
 * various utilities, such as image manipulation and effects
 
# Module: WebApiClient-RestKit

The **WebApiClient-RestKit** module provides provides mapping support for the core domain objects. The [BRRestKitDataMapping](https://github.com/Blue-Rocket/BlueRocketFuelCore/blob/msm/BRFCore/Code/WebApiClient-RestKit/BRRestKitDataMapping.m) class is a good starting point for applications to extend: it registers object mappers for the [BRAppUser](https://github.com/Blue-Rocket/BlueRocketFuelCore/blob/msm/Code/BRFCore/Core/BRAppUser.h) domain object for the standardized `login` and `register` route names.

# Module: WebRequest

The **WebRequest** module provides a HTTP client framework based on `NSURLConnection` that can be configured via the `Core` module configuration framework along with some simple conventions.

## Configuration

Web service configuration and support is managed via three areas:

### The config.json file

This JSON file is where you define all the endpoints that your web service provides. You will need to specify the path and method (GET, POST, PUT, etc.) for each end point here.

### BREnvironment settings

The URL, port and protocol of your web service are configured via [BREnvironment][brenv].

### Web service endpoint classes

For each endpoint in your web service you will want to implement a class. Name the class using a naming convention of `{EndPoint}WebServiceRequest`, where `{EndPoint}` is the name of the endpoint you defined in the **config.json** file with the first letter capitalized.

Your custom web service endpoint class should then subclass one of the following built-in BRFC classes, depending on which one best fits the endpoint:

#### BRWebServiceRequest

For public, non-restricted endpoints that do not require an authenticated user token to access.

#### BRAuthenticatedWebServiceRequest

For endpoints that require an authenticated user token (passed in the "USER-AUTHORIZATION" HTTP header) to access.

#### BRUserWebServiceRequest

For endpoints that not only require an authenticated user token to access, but also require the user's record ID appended to the path of the end point. Subclasses of this would typically be for endpoints that provide user-specific details, such as a user profile endpoint.


 [brfa]: https://github.com/Blue-Rocket/BlueRocketFuelApp
 [cocoapods]: https://cocoapods.org/
 [brenv]: https://github.com/Blue-Rocket/BREnvironment
 [afn]: https://github.com/AFNetworking/AFNetworking
 [rk]: https://github.com/RestKit/RestKit
