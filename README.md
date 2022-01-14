<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# Intro

> ⚠️ This package is still in development.

This is a set of helpers for when using vRouter.

Inspired by [this example.](https://github.com/lulupointu/vrouter/issues/32#issuecomment-885035432)

# Features

## *Widgets-like route elements :*

These VRouteElements are used directly inside the "route tree".

- **VxRouteSwitcher**
- **VxTabsScaffold**
- **VxTabBar** :
  - `useAutomaticKeepAlive` hook is provided for easily keeping the state of the tabs.

  If you don't want to use the hook, you'll have to manually mixin `AutomaticKeepAliveClientMixin` for your tabs' widgets.

  ```dart
  class MyTab extends StatefulWidget {
    const MyTab({ Key? key }) : super(key: key);

    @override
    _MyTabState createState() => _MyTabState();
  }

  /// 1. Mixin [AutomaticKeepAliveClientMixin]
  class _MyTabState extends State<MyTab> with AutomaticKeepAliveClientMixin<MyTab> {
    
    @override
    Widget build(BuildContext context) {
      /// 2. Call super.build(context);
      super.build(context);

      return ...
    }

    /// 3. Override [wantKeepAlive]
    @override
    bool get wantKeepAlive => true;
  }

  ```

## *Route elements :*

These VRouteElements are abstract classes that are supposed to be extended.

- **VxSimpleRoute**
- **VxDataRoute**
- **VxSwitchRoute**

# Important Remarks

For `VxRouteSwitcher` and `VxDataRoute`, I tried to implement something like a redirecting screen (± a switching screen). And also have async methods such as beforeRedirect and beforeSwitch. To prevent concurrency issues, all navigations (switching/redirections) were queued.

However, it was nearly impossible to do so using vRouter. That's because every navigation triggers a new beforeEnter/beforeUpdate callback, which then is nearly impossible to track its origin. I tried many methods : Using the vRouterData, using mutable propreties / a custom queue, static providers, query parameters... All methods failed, each one for a different reason (mutable propreties were easily messed up - static providers hold the same data for the same route so queuing the same route twice broke the system - query parameters are modifiable by the user...). And this was only a part of the problem, as the whole idea of making the navigation asynchroneous was too complex for vRouter.

This is why I settled on keeping the navigation synchroneous, and only having afterSwitch / afterRedirect methods, that didn't interfere with the navigation cycle because I put them at the end.

It is still possible to make something like a switchingScreen, by structuring your VxSwitchRoute this way :

```json
VGuard : after Enter, we wait a little before redirecting to a stackedRoute.
|
| _ VWidget : The switching screen
    |
    |_ Stacked routes : ..your routes..
```

The advantages are that :

- The transitions are working proprely right off the bat.
- Even if the redirection is asynchroneous, there is no concurrency issues to fear. So if for example the state changes before the redirection happens, then the VxRouteSwitcher will switch to the new switchRoute, and when the redirection is finally executed it will be locked.
