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
  /// ⚠️ When this is true, both [isMainSwitchRoute] and [_redirectToQueryParam]
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

  /// Called after switching to this route.
  ///
  /// Defaults to [VxSwitchRoute._voidAfter].
  final Future<void> Function() afterSwitch;

  /// Called after redirecting out of this route.
  ///
  /// Defaults to [VxSwitchRoute._voidAfter].
  final Future<void> Function() afterRedirect;

  static Future<void> _voidAfter() async {}

  Future<void> _beforeEnterAndUpdate(VRedirector vRedirector) async {
    // We persist all sticky query params, except those which value is [StickyQueryParam.deleteFlag]

    final previousVRouterData = vRedirector.previousVRouterData;
    final newVRouterData = vRedirector.newVRouterData!;

    final previousStickyQueryParams = previousVRouterData != null
        ? StickyQueryParam.getStickyQueryParams(
            previousVRouterData.queryParameters)
        : null;

    final newStickyQueryParams =
        StickyQueryParam.getStickyQueryParams(newVRouterData.queryParameters);

    final queryParamsToPersist = previousStickyQueryParams != null
        ? previousStickyQueryParams.filterWithKey((key, value) =>
            value != StickyQueryParam.deleteFlag &&
            !newStickyQueryParams.containsKey(key))
        : {};

    print('''
    previousUrl : ${previousVRouterData?.url}
    newUrl : ${newVRouterData.url}
    queryParamsToPersist : $queryParamsToPersist
    ''');

    if (queryParamsToPersist.isEmpty) {
      return;
    }

    /// If the new url doesn't contain the "redirectTo" query parameter, while
    /// the previous url does, we add it to the query parameters of the new url
    /// and we redirect there.

    final uri = Uri.parse(newVRouterData.url!);

    final updatedUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...queryParamsToPersist,
      },
    );
    logger.i('''
      Persisting the queryParams "$queryParamsToPersist" in switchRoute "${routeInfoInstance.name}"
      Updated url : ${updatedUri.toString()}
      ''');
    vRedirector.to(updatedUri.toString());
  }

  /// Cleaning the sticky query params which values equal
  /// [StickyQueryParam.deleteFlag]
  ///
  /// This should be made afterEnter/Update so as not to conflict with the
  /// persistance mechanism.
  ///
  ///
  /// TODO try again to do the cleaning in beforeEnterAndUpdate. Just discovered
  /// that I had a mistake in the code
  Future<void> _afterEnterAndUpdate(
      BuildContext context, String? from, String to) async {
    final newUri = Uri.parse(to);

    final newStickyQueryParams =
        StickyQueryParam.getStickyQueryParams(newUri.queryParameters);

    final queryParamsToClean = newStickyQueryParams
        .filter((value) => value == StickyQueryParam.deleteFlag);

    print('''
    previousUrl : $from
    newUrl : $to
    queryParamsToClean : $queryParamsToClean
    ''');

    if (queryParamsToClean.isEmpty) {
      return;
    }

    final cleanedQueryParams = newUri.queryParameters
        .filterWithKey((key, value) => !queryParamsToClean.containsKey(key));

    final updatedUri = newUri.replace(
      queryParameters: {
        ...cleanedQueryParams,
      },
    );

    logger.i('''
      Cleaning the queryParams "$queryParamsToClean" in switchRoute "${routeInfoInstance.name}"
      Updated url : ${updatedUri.toString()}
      ''');
    context.vRouter.to(updatedUri.toString());
  }

  @override
  List<VRouteElement> buildRoutes() {
    return [
      VGuard(
        beforeEnter: _beforeEnterAndUpdate,
        beforeUpdate: _beforeEnterAndUpdate,
        afterEnter: _afterEnterAndUpdate,
        afterUpdate: _afterEnterAndUpdate,
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
