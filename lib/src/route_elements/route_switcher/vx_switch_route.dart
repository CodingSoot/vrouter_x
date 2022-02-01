part of 'vx_route_switcher.dart';

/// This is a route intended to be used with [VxRouteSwitcher].
///
/// ### Usage :
///
/// 1. Create your route class that extends [VxSwitchRoute]
/// 2. The [routeInfoInstance] should be a reference to a static variable
/// `routeInfo`, that you'll create in your route class.
/// 3. Instead of overriding [buildRoutes], you should override
/// [buildRoutesX] and return your list of VRouteElements there.
///
/// ### Example :
///
/// ```dart
/// class ProfileRoute extends VxSwitchRoute<ProfileRouteData> {
///   ProfileRoute(RouteRef routeRef)
///       : super(
///           routeInfoInstance: routeInfo,
///           routeRef: routeRef,
///           ...
///         );
///
///   static final routeInfo = SwitchRouteInfo<ProfileRouteData>(
///     path: '/profile',
///     name: 'profile',
///   );
///
///   @override
///   List<VRouteElement> buildRoutesX() {
///      return [
///       VWidget(
///         path: null, /// This will match the path specified in [routeInfo]
///         widget: ProfilePage(),
///       ),
///      ];
///   }
/// }
/// ```
///
/// To navigate, you can call : `ProfileRoute.routeInfo.navigate(...)`
abstract class VxSwitchRoute<P extends RouteData> extends VxRouteBase {
  VxSwitchRoute({
    required this.routeRef,
    required this.routeInfoInstance,
    this.widgetBuilder = VxRouteBase.defaultWidgetBuilder,
    this.afterRedirect = _voidAfter,
    this.afterSwitch = _voidAfter,
  });

  @override
  final RouteRef routeRef;

  @override
  final SwitchRouteInfo<P> routeInfoInstance;

  @override
  final Widget Function(
          BuildContext context, VRouterData vRouterData, Widget child)
      widgetBuilder;

  /// Whether the "main redirection" is enabled in the parent [VxRouteSwitcher].
  ///
  /// ⚠️ When this is true, both [isMainSwitchRoute] and [redirectToQueryParam]
  /// are not null. Otherwise, both are null.
  ///
  /// NB: This will be initialized by the parent [VxRouteSwitcher].
  late final bool isMainRedirectionEnabled;

  /// Whether this switchRoute is the mainSwitchRoute. True if this
  /// switchRoute's name equals the parent's
  /// [VxRouteSwitcher.mainSwitchRouteName].
  ///
  /// Non null if [isMainRedirectionEnabled] is true (and null otherwise).
  ///
  /// NB: This will be initialized by the parent [VxRouteSwitcher].
  late final bool? isMainSwitchRoute;

  /// Equals the parent's [VxRouteSwitcher.redirectToQueryParam].
  ///
  /// Non null if [isMainRedirectionEnabled] is true (and null otherwise).
  ///
  /// NB: This will be initialized by the parent [VxRouteSwitcher].
  late final String? redirectToQueryParam;

  /// Called after switching to this route.
  ///
  /// Defaults to [VxSwitchRoute._voidAfter].
  final Future<void> Function() afterSwitch;

  /// Called after redirecting out of this route.
  ///
  /// Defaults to [VxSwitchRoute._voidAfter].
  final Future<void> Function() afterRedirect;

  static Future<void> _voidAfter() async {}

  /// When the "main redirection" is enabled, this will persist the "redirectTo"
  /// query parameter when navigating between the routes of this [VxSwitchRoute]
  Future<void> _beforeUpdate(VRedirector vRedirector) async {
    /// The "main redirection" isn't enabled.
    if (!isMainRedirectionEnabled) {
      return;
    }

    /// [isMainRedirectionEnabled] is true, so both [isMainSwitchRoute]
    /// and [redirectToQueryParam] are not null.
    final isMainSwitchRoute = this.isMainSwitchRoute!;
    final redirectToQueryParam = this.redirectToQueryParam!;

    /// If this [VxSwitchRoute] is the main switchRoute, we obviously don't want
    /// to persist the "redirectTo" query parameter. (would cause an infinite
    /// redirection loop)
    if (isMainSwitchRoute) {
      return;
    }

    final previousRedirectToQueryParam =
        vRedirector.previousVRouterData?.queryParameters[redirectToQueryParam];

    final newVRouterData = vRedirector.newVRouterData!;
    final newRedirectToQueryParam =
        newVRouterData.queryParameters[redirectToQueryParam];

    /// If the new url doesn't contain the "redirectTo" query parameter, while
    /// the previous url does, we add it to the query parameters of the new url
    /// and we redirect there.
    if (newRedirectToQueryParam == null &&
        previousRedirectToQueryParam != null) {
      final uri = Uri.parse(newVRouterData.url!);
      final updatedUri = uri.replace(
        queryParameters: {
          ...uri.queryParameters,
          redirectToQueryParam: previousRedirectToQueryParam,
        },
      );
      vRedirector.to(updatedUri.toString());
    }
  }

  @override
  List<VRouteElement> buildRoutes() {
    return [
      VGuard(
        beforeUpdate: _beforeUpdate,
        stackedRoutes: [
          VNester.builder(
            path: routeInfoInstance.path,
            name: routeInfoInstance.name,
            key: ValueKey(routeInfoInstance.name),
            widgetBuilder: (context, vRouterData, child) => Consumer(
              builder: (context, ref, _) {
                ref.watch(routeInfoInstance._widgetDisposedProvider);

                final routeDataOption =
                    ref.watch(routeInfoInstance._routeDataOptionProvider);

                return routeDataOption.match(
                  (routeData) => ProviderScope(
                    overrides: [
                      routeInfoInstance.routeDataProvider
                          .overrideWithValue(routeData),
                    ],
                    child: widgetBuilder(context, vRouterData, child),
                  ),
                  () {
                    throw UnreachableError(customMessage: '''
                    The route has been accessed while its routeData is none().
                    This should have been prevented by VxRouteSwitcher's VGuard.
                    ''');
                  },
                );
              },
            ),
            nestedRoutes: buildRoutesX(),
          ),
        ],
      )
    ];
  }

  /// See [buildRoutes].
  ///
  List<VRouteElement> buildRoutesX();
}
