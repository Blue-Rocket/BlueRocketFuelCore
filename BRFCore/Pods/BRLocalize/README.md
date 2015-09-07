# BRLocalizable

**BRLocalizable** provides a way to store localized strings in a hierarchical JSON file and then have placeholder strings in NIB files automatically replaced by their localized value.

Here's an example JSON strings file, `json.strings`:

```json
{
	"login" : {
		"title" : "Sign in"
	}
}
```

Now you can localize that just like any other file (i.e. move to a `XX.lproj` directory and include the localized varients of the JSON in your application.


# Programmatic localization

You can localize stuff via code if you like. For example you might want to set a _login_ view controller's title to `login.title`, like this:

```objc
- (void)viewDidLoad {
	[super viewDidLoad];
	[self localizeWithAppStrings:[NSBundle appStrings]];
}

- (void)localizeWithAppStrings:(NSDictionary *)strings {
	self.navigationItem.title = [strings stringForKeyPath:@"login.title"];
}

```

The `appStrings` method is provided as an extension on `NSBundle`, and `stringForKeyPath:` is provided as an extension on `NSDictionary`.


# Automagical localization

**BRLocalize** provides some hooks into UI-related code to make the process of applying localized strings a bit easier for you. The hooks rely on the `BRLocalizable` protocol:

```objc
@protocol BRLocalizable <NSObject>

/**
Localize the receiver with a given dictionary of strings.

@param strings The strings data, typically loaded via the application's standard JSON strings file.
*/
- (void)localizeWithAppStrings:(NSDictionary *)strings;

@end

```

There are two main hooks provided:

 1. `awakeFromNib` - any object that conforms to `BRLocalizable` will have `localizeWithAppStrings:` called when `awakeFromNib` is invoked.
 2. `willMoveToWindow:` - any `UIView` class that conforms to `BRLocalizable` will have `localizeWithAppStrings:` called when `willMoveToWindow:` is invoked.

Building on those hooks, **BRLocalize** provides category-based implementations of the following classes so they conform to `BRLocalizable`:

 1. UIBarButtonItem
 2. UIButton
 3. UILabel
 4. UINavigationItem
 5. UISegmentedControl
 6. UITextField

All of these make use of a `localizedStringWithAppStrings:` method provided on `NSString`, which looks for strings in the form `{some.key.path}` and replaces that with a the value found at `some.key.path` in the JSON strings file.
