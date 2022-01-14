part of 'vx_route_switcher.dart';

/// This is a route intended to be used with [VxRouteSwitcher].
///
/// The [routeInfoInstance] should be a reference to a static variable
/// `routeInfo`, that you'll create in your route class.
///
/// Then, instead of overriding [buildRoutes], you should override
/// [buildRoutesX] and return your list of VRouteElements there.
///
/// Example :
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

  /// Called after switching to this route.
  ///
  /// Defaults to [VxSwitchRoute._voidAfter].
  final Future<void> Function() afterSwitch;

  /// Called after redirecting out of this route.
  ///
  /// Defaults to [VxSwitchRoute._voidAfter].
  final Future<void> Function() afterRedirect;

  static Future<void> _voidAfter() async {}

  @override
  List<VRouteElement> buildRoutes() {
    return [
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
    ];
  }

  /// See [buildRoutes].
  ///
  List<VRouteElement> buildRoutesX();
}
