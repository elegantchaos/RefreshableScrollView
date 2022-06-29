# RefreshableScrollView

Provides a SwiftUI implementation of ScrollView which supports the `.refreshable` modifier.

Currently, the only way to get pull-to-refresh behaviour in SwiftUI is to use a List. This may not always be what you want, as List has some performance issues.
  
The views in this package are intended for situations where you want pull-to-refresh, but
don't want to use `List`.

This package provides two implementations:

1. A pure SwiftUI one: `RefreshableScrollView`. This works when embedded in a navigation view, and has hint flags that you can pass to help adjust the layout of the refresh control. The downside is that the precise pull-to-refresh behaviour is very slightly different from the UIKit implementation. This is because we cannot use a `UIRefreshControl`, as that only works when attached to a `UIScrollView`, which we don't have.

2. An implementation which uses UIKit: `NativeRefreshableScrollView`. This uses a real UIScrollView, which contains a UIHostingController, which contains the SwiftUI content views. Doing this means that we can use `UIRefreshControl` for the activity/refresh indicator, and get the precise pull-to-refresh behaviour and appearance from UIKit. The downside is that it does not seem to play well if embedded inside a NavigationView; the positioning of the refresh control seems to change as soon as the refresh task begins, causing it to disappear, which looks rubbish. 

## Example

See `Extras/Example` for an example Xcode project which uses this package.

## Credits

This code builds on or takes inspiration from a few examples out there, including:
 
- [SwiftUI Lab](https://swiftui-lab.com/scrollview-pull-to-refresh/) for hints on a good SwiftUI implementation
- [Jeremy Fuellert](https://gist.github.com/jfuellert/67e91df63394d7c9b713419ed8e2beb7) for hints on a good UIKit implementation.

Thanks to these and others for showing the way.
