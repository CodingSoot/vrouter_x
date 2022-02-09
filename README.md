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

- [Intro](#intro)
- [Features](#features)
  - [_Widgets-like route elements :_](#widgets-like-route-elements-)
  - [_Route elements :_](#route-elements-)
  - [_Widgets :_](#widgets-)
- [Tour](#tour)
  - [VxTabsScaffold](#vxtabsscaffold)
  - [VxTabBar](#vxtabbar)
    - [Keeping the tabs state](#keeping-the-tabs-state)
  - [VxRouteSwitcher](#vxrouteswitcher)
    - [Nested VxRouteSwitchers](#nested-vxrouteswitchers)
    - [Main redirection](#main-redirection)
      - [How it works](#how-it-works)
      - [The "redirect" query parameter](#the-redirect-query-parameter)
      - [Nested VxRouteSwitcher & Main redirection](#nested-vxrouteswitcher--main-redirection)
  - [StickyQueryParamsScope](#stickyqueryparamsscope)
    - [Usage](#usage)
    - [Limitations](#limitations)
  - [VxSimpleRoute](#vxsimpleroute)
    - [Usage](#usage-1)
  - [VxDataRoute](#vxdataroute)
    - [Usage](#usage-2)
  - [VxSwitchRoute](#vxswitchroute)
    - [Usage](#usage-3)
  - [PathWidgetSwitcher](#pathwidgetswitcher)
    - [Features](#features-1)
    - [Basic Usage](#basic-usage)
    - [PfPathWidgetSwitcher](#pfpathwidgetswitcher)
    - [Path matching](#path-matching)
    - [Most specific match](#most-specific-match)
    - [Animate the transition](#animate-the-transition)
- [Important Remarks](#important-remarks)
- [VsCode snippets](#vscode-snippets)

# Features

## _Widgets-like route elements :_

These VRouteElements are used directly inside the "route-tree".

- **VxTabsScaffold**
- **VxTabBar** :
  - `useAutomaticKeepAlive` hook is provided for easily keeping the state of the tabs.
- **VxRouteSwitcher**
- **StickyQueryParamsScope**

## _Route elements :_

These VRouteElements are abstract classes that are supposed to be extended.

- **VxSimpleRoute**
- **VxDataRoute**
- **VxSwitchRoute**

## _Widgets :_

These are normal widgets used inside the widget-tree.

- **PathWidgetSwitcher**

# Tour

## VxTabsScaffold

Inspired by [this example.](https://github.com/lulupointu/vrouter/issues/32#issuecomment-885035432)

This is a `VRouteElement` that allows you to easily setup a `BottomNavigationBar` or your own `NavigationBar`.
It implements several features including :

- Preserved state for each tab
- Lazily loaded tabs
- Seamless integration with Flutter's BottomNavigationBar or your own custom NavigationBar
- Possibility to stack routes on top of the NavigationBar

## VxTabBar

Inspired by [this example.](https://github.com/lulupointu/vrouter/issues/32#issuecomment-885035432)

A `VRouteElement` that allows you to easily setup a `TabBarView` where each
tab is a different router with its own stack.

It implements several features including :

- Preserved state for each tab (Optional, should use `AutomaticKeepAliveClientMixin`)
- Lazily loaded tabs
- Seamless integration with Flutter's `TabBarView`
- Possibility to stack routes on top of the whole `TabBarView`

### Keeping the tabs state

In order to keep the state of the tabs, the widget of each tab route should mixin `AutomaticKeepAliveClientMixin`.

You can do this either by :

- Using the provided hook `useAutomaticKeepAlive` inside a `HookWidget`.
- Manually mixin `AutomaticKeepAliveClientMixin` :

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

## VxRouteSwitcher

This is a route element (a VNester) that allows to automatically navigate
between its `switchRoutes` based on the state of a riverpod `provider`.

**Some terminology :**

- _Matched switchRoute :_ The switchRoute matching the current state of your provider
- _Switching :_ Automatically navigating to the matched switchRoute when the state changes.

### Nested VxRouteSwitchers

When the `VxRouteSwitcher` is nested inside another `VxRouteSwitcher`, you should provide the `parentRouteSwitchers` argument. It's a list that represents the parent VxRouteSwitcher(s), from top to bottom.

For example, if you have this route-tree :

```text
.
└── Switcher 1
    ├── Route A : Switcher 2
    │   ├── Route i
    │   └── Route ii : Switcher 3
    │       ├── Route x
    │       └── Route y
    ├── Route B
    └── Route C : Switcher 4
        ├── Route α
        └── Route β
```

Then you should provide the `parentRouteSwitchers` argument for `Switcher 2`, `Switcher 3` and `Switcher 4`.

The `parentRouteSwitchers` of `Switcher 2` and `Switcher 4` will look like this :

```dart
parentRouteSwitchers: [
      /// Represents Switcher 1
      ParentRouteSwitcher(...),
    ],
```

The `parentRouteSwitchers` of Switcher3 will look like this :

```dart
parentRouteSwitchers: [
      /// Represents Switcher 1
      ParentRouteSwitcher(...),
      /// Represents Switcher 2
      ParentRouteSwitcher(...),
    ],
```

### Main redirection

Suppose you have a VxRouteSwitcher that switches between your main route and your "sign-in" route based on the authentication state. When the user navigates to a url that points to somewhere inside the main route, and he's not authenticated, he's redirected to the "sign-in" screen. Ideally, once he logs in, he would be redirected to that url. That's what "Main redirection" is about.

#### How it works

To enable "main redirection", you should use the constructor `VxRouteSwitcher.withMainRedirection`. Then you should provide two arguments :

- `mainSwitchRouteName` : The name of your main switchRoute.
- `redirectQueryParamName` : The name of the "redirect" query parameter.

When you navigate to a **url** that points to a route inside your main switchRoute, but the matched switchRoute is not the main switchRoute, you are redirected to the matched switchRoute.

In this situation, that **url** is stored inside the "redirect" query parameter, which will be persisted until the state matches your main switchRoute. When that happens, you are automatically navigated to that **url**, and the "redirect" query parameter is deleted.

> **NB :** When having multiple `VxRouteSwitcher`s in the route-tree which have "main redirection" enabled, they should each have a different "redirect" query parameter name.

#### The "redirect" query parameter

The "redirect" query parameter is a sticky query parameter, meaning that internally, a `StickyQueryParamsScope` is used to automatically persist it in all the subroutes of the `VxRouteSwitcher`. So you don't need to manually pass it around when navigating.

#### Nested VxRouteSwitcher & Main redirection

Main redirection works as expected when having multiple nested `VxRouteSwitcher`s, as long as you correctly provide the `parentRouteSwitchers` wherever needed.

Note that :

- The "redirect" query parameter of each `VxRouteSwitcher` is only scoped to that `VxRouteSwitcher`, meaning that **it will only be persisted within its VxRouteSwitcher's routes.**
  - Sometimes, it may find itself outside of its VxRouteSwitcher's routes (for example if it was previously encoded into one of its parents' "redirect" query param, or if the user manually enters it). In that case, it simply won't be persisted during subsequent navigations that occur outside of the VxRouteSwitcher's scope.
- When making the **url** that will be stored inside the "redirect" query parameter, the `VxRouteSwitcher`'s "redirect" query parameter and its parents' "redirect" query parameter are excluded from that **url** (to avoid infinite loops). However, its children's "redirect" query parameter are not excluded.

## StickyQueryParamsScope

This is a route element (a VGuard) that persists a set of query parameters in all its subroutes. These query parameters are called "Sticky query parameters".

When navigating inside the scope of `StickyQueryParamsScope`, if you omit a sticky query parameter, it will be automatically re-added. If you want to remove the sticky query parameter from the url, you should set its value to the specified `deleteFlag`.

### Usage

```dart
StickyQueryParamsScope(
  stickyConfigs: [
    StickyConfig.exact(name: 'book-id', deleteFlag: '.'),
    StickyConfig.prefix(prefix: 'book', deleteFlag: '*'),
    StickyConfig.suffix(suffix: 'id'),
    StickyConfig.regExp(regExp: RegExp(r"\d+")),
  ],
  stackedRoutes: [
    ...
  ],
);
```

In this example, the sticky query parameters that will be persisted are :

- The query parameter named 'book-id'. It can be removed from the url by setting its value to `.`.
- All the query parameters which name starts with 'book'. Each one can be removed from the url by setting its value to `*`.
- All the query parameters which name ends with 'id'. Each one can be removed from the url by setting its value to `_`, which is the default `deleteFlag`.
- All the query parameters which name consists of digits only. Each one can be removed from the url by setting its value to `_`, which is the default `deleteFlag`.

> **NB1 :** When the same query parameter is matched by multiple `StickyConfig`s, if its value equals at least one of their deleteFlags, it will be deleted from the url.
> **NB2 :** The delete flag can be set to any value, since it will be percent-encoded. However, keep in mind that the query parameters names should only use alphanumeric characters and [unreserved characters.](https://developers.google.com/maps/url-encoding#special-characters)

### Limitations

In beforeEnter/Update, when we navigate using the vRedirector, the new vRedirector gets the same old `previousVRouterData`. So if you add a sticky query parameter in the middle of the beforeEnter/Update rederections chain, it will not be automatically persisted because the persistence relies on the queryParam to be present in the `previousVRouterData`.

For this reason, if you add new sticky queryParameters using a vRedirector navigation, and you might have other subsequent vRedirector navigations you might do, make sure to **manually** persist the added sticky queryParams until the final page is **reached and accessed**.

---

## VxSimpleRoute

This is a basic route, that contains some common information needed for
navigation (namely the path and the name), as well as a convenient widgetBuilder that allows you to easily wrap all the routes returned by `buildRoutes` (nested and stacked).

### Usage

Create your route class that extends `VxSimpleRoute`.

Note that :

- The `routeInfoInstance` should be a reference to a static variable `routeInfo`.
- Instead of overriding `buildRoutes`, you should override `buildRoutesX` and return your list of VRouteElements there.

```dart
class ProfileRoute extends VxSimpleRoute {
  ProfileRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SimpleRouteInfo(
    path: '/profile',
    name: 'profile',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
          VWidget(
            path: null, // This will match the path specified in [routeInfo]
            widget: ProfilePage(),
          ),
        ];
  }
}
```

You can easily access the routeInfo using `ProfileRoute.routeInfo`.

To navigate, you can call : `ProfileRoute.routeInfo.navigate(...)`.

## VxDataRoute

This is a route that requires some `RouteData` to be able to navigate to it.

If the `RouteData` is not provided, then we are automatically redirected to another route (which you'll specify in `routeInfo`).

All the features of `VxSimpleRoute` are also included.

### Usage

1. Create a Dataclass that extends `RouteData`

   ```dart
   class BookRouteData extends RouteData with _$BookRouteData {
     const factory BookRouteData({
       required String title,
       required String author,
     }) = _BookRouteData;
   }
   ```

2. Create your route class that extends `VxDataRoute`.

   Note that :

   - The `routeInfoInstance` should be a reference to a static variable `routeInfo`.
   - Instead of overriding `buildRoutes`, you should override `buildRoutesX` and return your list of VRouteElements there.

   ```dart
   class BookRoute extends VxDataRoute<BookRouteData> {
     BookRoute(RouteRef routeRef)
         : super(
             routeInfoInstance: routeInfo,
             routeRef: routeRef,
             ...
           );
     static final routeInfo = DataRouteInfo<BookRouteData>(
       path: '/book',
       name: 'book',
       redirectToRouteName: 'all-books',
       redirectToResolver: const RedirectToResolver.noPathParameters(),
     );
     @override
     List<VRouteElement> buildRoutesX() {
       return [
         VWidget(
           path: null, // This will match the path specified in [routeInfo]
           widget: BookPage(),
         ),
       ];
     }
   }
   ```

You can easily access the routeInfo using `BookRoute.routeInfo`.

To navigate, you can call : `BookRoute.routeInfo.navigate(...)`.

You can access the routeData in two different ways :

- **If you are inside the route's tree :** Read/watch the provider `BookRoute.routeInfo.routeDataProvider`. You can do this safely from any widget of the routes returned by `buildRoutesX`. However, if you access it from outside of those, an `UnimplementedError` will be thrown.
- **If you are outside the route's tree:** Read/watch the provider `BookRoute.routeInfo.routeDataOptionProvider`. This can be safely done from anywhere. This provider holds `none()` if the route is not in the current stack, otherwise it holds `some(routeData)`.

## VxSwitchRoute

This is a route intended to be used with `VxRouteSwitcher`.

All the features of `VxSimpleRoute` are included.

### Usage

1. Create a Dataclass that extends `RouteData`

   ```dart
   class ProfileRouteData extends RouteData with _$ProfileRouteData {
     const factory ProfileRouteData({
       required String username,
     }) = _ProfileRouteData;
   }
   ```

2. Create your route class that extends `VxSwitchRoute`.

   Note that :

   - The `routeInfoInstance` should be a reference to a static variable `routeInfo`.
   - Instead of overriding `buildRoutes`, you should override `buildRoutesX` and return your list of VRouteElements there.

   ```dart
   class ProfileRoute extends VxSwitchRoute<ProfileRouteData> {
     ProfileRoute(RouteRef routeRef)
         : super(
             routeInfoInstance: routeInfo,
             routeRef: routeRef,
             ...
           );
         static final routeInfo = SwitchRouteInfo<ProfileRouteData>(
       path: '/profile',
       name: 'profile',
     );
         @override
     List<VRouteElement> buildRoutesX() {
        return [
         VWidget(
           path: null, // This will match the path specified in [routeInfo]
           widget: ProfilePage(),
         ),
        ];
     }
   }
   ```

You can easily access the routeInfo using `ProfileRoute.routeInfo`.

You can access the routeData in two different ways :

- **If you are inside the route's tree :** Read/watch the provider `ProfileRoute.routeInfo.routeDataProvider`. You can do this safely from any widget of the routes returned by `buildRoutesX`. However, if you access it from outside of those, an `UnimplementedError` will be thrown.
- **If you are outside the route's tree:** Read/watch the provider `ProfileRoute.routeInfo.routeDataOptionProvider`. This can be safely done from anywhere. This provider holds `none()` if the route is not in the current stack, otherwise it holds `some(routeData)`.

---

## PathWidgetSwitcher

Heavily inspired by the package [routed_widget_switcher.](https://pub.dev/packages/routed_widget_switcher)

### Features

Declaratively switch child widgets based on the current vRouterData (Or based on a vRouterData you provide).

This is useful in 2 primary use cases:

- When you have scaffolding around your Navigator, like a SideBar or a TitleBar and you would like it to react to location changes
- When multiple paths resolve to the same Page and you want to move subsequent routing further down the tree

Note: This package does not provide any control of the routers location, it simply reads the current location and responds accordingly.

### Basic Usage

The most basic usage :

```dart
class SideBar extends StatelessWidget {
    Widget build(_){
     return PathWidgetSwitcher(
        pathWidgets: [
          PathWidget(
            path: '/', //or MainRoute.routeInfo.path!
            builder: (path) => const MainMenu(),
          ),
          PathWidget(
            path: '/profile', //or ProfileRoute.routeInfo.path!
            builder: (path) => const ProfileMenu(),
          ),
        ]);
    }
}
```

This will automatically extract the current `vRouterData` from the context. If you want to manually pass in the `vRouterData`, you can use instead the constructor `PathWidgetSwitcher.fromVRouterData`.

### PfPathWidgetSwitcher

You may want to use a PathWidgetSwitcher to switch between different appbars. However, the `appBar` is required be a `PreferredSizeWidget`, which `PathWidgetSwitcher` is not.

For this use case, you can instead use `PfPathWidgetSwitcher`. It has all the functionnality of `PathWidgetSwitcher`, with the added ability to set the `preferredSize`.

### Path matching

Paths can be defined as simple strings like /user/new or user/:userId, or use regular expression syntax like r'/user/:id(\d+)'. See [pathToRegExp package](https://pub.dev/packages/path_to_regexp) for more details on advanced use cases.

By default, paths are considered to be case-insensitive. This can be controlled globally by setting the `caseSensitive` property of `PathWidgetSwitcher`, which can be overridden on a per path basis by setting the `caseSensitive` property of `PathWidget`.

If you want a path to be treated as a prefix, you can set the `prefix` property to `true` (false by default), or by using the `.asPrefix` extension method.

```dart
// This matches any path that starts with '/'
PathWidget(
  path: '/',
  builder: (path) => const MainMenu(),
  prefix: true,
),
// This is the same as 'prefix: true'
PathWidget(
  path: '/',
  builder: (path) => const MainMenu(),
).asPrefix,
```

All the paths of the `PathWidget`s should be absolute (which means they should start with a `'/'`).

In addition to the matching performed by pathToRegExp, you can also specify a wildcard path `'*'` to match any location and handle unknown paths : `PathWidget(path: '*', ...)`.

### Most specific match

`PathWidgetSwitcher` will attempt to use the most specific match. For example, the url `/users/new` matches all three of these PathWidgets :

```dart
PathWidget(path:'/users/:userId', ...),
PathWidget(path:'/users/new', ...),
PathWidget(path: '*', ...),
```

Since `/users/new` is the more exact match, it will be the one to render. `/users/:userId` would go next, with the wildcard `*` finally matching last. The order in which you declare the PathWidgets does not matter.

### Animate the transition

You can use the `builder` method of `PathWidgetSwitcher` to wrap the matched child with something like an `AnimatedSwitcher` or [`AnimatedSizeAndFade`](https://pub.dev/packages/animated_size_and_fade).

Note that most of these widgets require the children to specify a key in order for the transition to occur.

```dart
PathWidgetSwitcher(
  pathWidgets: [
    PathWidget(
      path: MainRoute.routeInfo.path!,
      //The path is conviniently passed into the builder for easy use as a ValueKey
      builder: (path) => MainMenu(key: ValueKey(path)),
    ),
    PathWidget(
      path: ProfileRoute.routeInfo.path!,
      builder: (path) => ProfileMenu(key: ValueKey(path)),
    ),
  ],
  builder: (context, child) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 500),
    child: child,
  ),
);
```

# Important Remarks

For `VxRouteSwitcher` and `VxDataRoute`, I tried to implement something like a redirecting screen (± a switching screen). And also have async methods such as beforeRedirect and beforeSwitch. To prevent concurrency issues, all navigations (switching/redirections) were queued.

However, it was nearly impossible to do so using vRouter. That's because every navigation triggers a new beforeEnter/beforeUpdate callback, which then is nearly impossible to track its origin. I tried many methods : Using the vRouterData, using mutable propreties / a custom queue, static providers, query parameters... All methods failed, each one for a different reason (mutable propreties were easily messed up - static providers hold the same data for the same route so queuing the same route twice broke the system - query parameters are modifiable by the user...). And this was only a part of the problem, as the whole idea of making the navigation asynchroneous was too complex for vRouter.

This is why I settled on keeping the navigation synchroneous, and only having afterSwitch / afterRedirect methods, that didn't interfere with the navigation cycle because I put them at the end without awaiting for them.

It is still possible to make something like a switchingScreen, by structuring your VxSwitchRoute this way :

```text
VGuard : after Entering the switching screen, we wait a little before redirecting to a stackedRoute.
|
| _ VWidget : The switching screen
    |
    |_ Stacked routes : ..your routes..
```

The advantages are that :

- The transitions are working proprely right off the bat.
- Even if the redirection is asynchroneous, there is no concurrency issues to fear. So if for example the state changes before the redirection happens, then the VxRouteSwitcher will switch to the new switchRoute, and when the redirection is finally executed it will be stopped.

# VsCode snippets

```json
"VxSimpleRoute": {
  "prefix": "vxsimpleroute",
  "body": [
    "class ${1}Route extends VxSimpleRoute {",
    "  ${1}Route(RouteRef routeRef)",
    "    : super(",
    "      routeInfoInstance: routeInfo,",
    "      routeRef: routeRef,",
    "     );",
    "  ",
    "  static final routeInfo = SimpleRouteInfo(",
    "    path: ${2},",
    "    name: ${3},",
    "  );",
    "",
    "  @override",
    "  List<VRouteElement> buildRoutesX() {",
    "    return [",
    "      ${4}",
    "    ];",
    "  }",
    "}",
  ],
  "description": "VxSimpleRoute"
},
"RouteData": {
  "prefix": "routedata",
  "body": [
    "@freezed",
    "class ${1}RouteData extends RouteData with _$${1}RouteData {",
    "  const factory ${1}RouteData(${2}) = _${1}RouteData;",
    "}",

  ],
  "description": "RouteData"
},
"VxDataRoute": {
  "prefix": "vxdataroute",
  "body": [
    "class ${1}Route extends VxDataRoute<${1}RouteData> {",
    "  ${1}Route(RouteRef routeRef)",
    "    : super(",
    "        routeRef: routeRef,",
    "        routeInfoInstance: routeInfo,",
    "      );",
    "",
    "  static final routeInfo = DataRouteInfo<${1}RouteData>(",
    "    path: ${2},",
    "    name: ${3},",
    "    redirectToRouteName: ${4},",
    "    redirectToResolver: ${5},",
    "  );",
    "",
    "  @override",
    "  List<VRouteElement> buildRoutesX() {",
    "    return [",
    "      ${6}",
    "    ];",
    "  }",
    "}",			  
  ],
  "description": "VxDataRoute"
},
"VxSwitchRoute": {
  "prefix": "vxswitchroute",
  "body": [
    "class ${1}Route extends VxSwitchRoute<${1}RouteData> {",
    "  ${1}Route(RouteRef routeRef)",
    "    : super(",
    "        routeInfoInstance: routeInfo,",
    "        routeRef: routeRef,",
    "      );",
    "",
    "  static final routeInfo = SwitchRouteInfo<${1}RouteData>(",
    "    path: ${2},",
    "    name: ${3},",
    "  );",
    "",
    "  @override",
    "  List<VRouteElement> buildRoutesX() {",
    "    return [",
    "      ${4}",
    "    ];",
    "  }",
    "}",
  ],
  "description": "VxSwitchRoute"
},
```
