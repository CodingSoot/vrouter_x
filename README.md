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
