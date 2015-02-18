#Blue Rocket Fuel
========================
(NOTE: This is an early draft of this read-me. It is a work in progress. Please let us know any feedback or edits that will make it clearer or more useful.)


What Is it?
------
**Blue Rocket Fuel** is an Open Source app starter kit, provided by Blue Rocket Inc. ([Blue Rocket Inc.](http://bluerocket.us)), for building typical client applications that require user login, registration and data interaction with a back-end Web Service. It includes robust Web Service request and response classes for interacting with the Web Service, and integrated app level network error handing for elegantly dealing with network connectivity issues and other error conditions. It also provides starter UI for Registration, Login, User Profile and About, all of which are based on the latest storyboarding, adaptive and auto-layout techniques.


Getting Started
-----
Duplicate the entire "Workspace" folder to begin your new app. This folder has no .Git repository so it is ready to be dropped into a new or existing repository as needed.

Open "**Workspace.xcworkspace**" to begin editing and customizing your new app.

You will notice the workspace is divided into two projects: **App** and **BlueRocketFuel**. The **App** project is where the actual app target for your new app is located, and where you will add, build and run your own UI and functionality. It was designed this way to separate out your unique UI and functionality from the core Blue Rocket Fuel classes which is proved in the separate **BlueRocketFuel** framework project. The **BlueRocketFuel** project was designed as framework so that it could be dropped into other projects more easily if needed.


Adding Your Custom UI
-----
All UI is located in main storyboard (**Main.stoyrboard**) using adaptive layout. You will find all the starting views and view controllers for providing the core login and registration functionality here, and is intended to be easily extended for your own app. Look in these view controller classes for examples on how to use the Web Service request and response networking classes.

Localization Support
------
Blue Rocket Fuel provides a unique for localizing your UI directly in the Main.storyboard. Simply place and organize all your localizable strings in "**strings.json**" JSON file included in the App project folder. Then reference those strings in your button titles, navigation item titles, label text, and other UI elements by enclosing the string's JSON object path in curly brackets ({}).

See, for example, the view controller provided for the About view. Notice it references three strings for the navigation bar title ("{about.tile}"), the label that displays the app name ("{about.name}"), and the label that displays the app description ("{about.text}"). You will find each of these already included in the strings.json file.


Web Service Configuration
-----
Web service configuration and support is managed via three areas:

###The "config.json" File
This JSON file is where you define all the end poinds that your Web Service provides. You will need to specify the path and method (GET, POST, PUT, etc.) for each end point here.

###The Two ".xcconfig" Files
The URL, port and protocol of your Web Service are configured in these files. They are defined in .xcconfig files so that there can be two different builds you can easily configure to point to separate Staging and Production servers during development.

###The Web Service End Point Class Files
For each end point in your Web Service you will want to implement it's own class file. Name the class using a naming convention of **{EndPoint}WebServiceRequest**, where {EndPoint} is the name of the endpoint you defined in the **config.json** file with the first letter capitalized.

Your custom Web Service end point class should then subclass one of the following built-in Blue Rocket Fuel classes, depending on which one best fits the end point:

#####- BRWebServiceRequest
For public, non-restricted end points that do not require an authenticated user token to access.

#####- BRAuthenticatedWebServiceRequest
For end points that require an authenticated user token (passed in the "USER-AUTHORIZATION" HTTP header) to access.


#####- BRUserWebServiceRequest
For end points that not only require an authenticated user token to access, but also require the user's record ID appended to the path of the end point. Subclasses of this would typically be for end points that provide user-specific details. Such as the Profile endpoint.


----
See the code in both the App and BlueRocketFuel projects as examples, and to learn more. See the Ping, Register, Login, and Profile endpoint classes provided in the BlueRocketFuel framework project for examples of creating end point subclasses.
