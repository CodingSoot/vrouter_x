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

  /// Whether the [VxRouteSwitcher] is nested inside another [VxRouteSwitcher].
  ///
  /// NB: This will be initialized by the [VxRouteSwitcher].
  late final bool isVxRouteSwitcherNested;

  /// Whether the "main redirection" is enabled in the [VxRouteSwitcher].
  ///
  /// When this is true, [isMainSwitchRoute] is not null. Otherwise, it's null.
  ///
  /// NB: This will be initialized by the [VxRouteSwitcher].
  ///
  /// TODO This variable is unused ?
  late final bool isMainRedirectionEnabled;

  /// Whether this switchRoute is the mainSwitchRoute. True if this
  /// switchRoute's name equals the [VxRouteSwitcher.mainSwitchRouteName].
  ///
  /// Non null if [isMainRedirectionEnabled] is true (and null otherwise).
  ///
  /// NB: This will be initialized by the [VxRouteSwitcher].
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

  /// We persist all the sticky query params, except those flagged for deletion
  /// (which will be deleted afterEnter/Update).
  ///
  /// For optimization, this is not executed if the [VxRouteSwitcher] is nested,
  /// so that this code only gets executed by the top-most [VxRouteSwitcher]'s
  /// switchRoute's afterEnterAndUpdate.
  ///
  /// > NB : In beforeEnter/Update, when we redirect to a url, the new
  /// > vRedirector gets the same old vRouterData. However, this doesn't cause
  /// > any problem for persisting the the sticky queryParams.
  Future<void> _beforeEnterAndUpdate(VRedirector vRedirector) async {
    if (isVxRouteSwitcherNested) {
      return;
    }

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

    if (queryParamsToPersist.isEmpty) {
      return;
    }

    final newUri = Uri.parse(newVRouterData.url!);

    final updatedUri = newUri.replace(
      queryParameters: {
        ...newUri.queryParameters,
        ...queryParamsToPersist,
      },
    );
    logger.i('''
      Persisting the queryParams "$queryParamsToPersist" in switchRoute "${routeInfoInstance.name}"
      Updated url : ${updatedUri.toString()}
      ''');
    vRedirector.to(updatedUri.toString());
  }

  /// Deleting the sticky query params that are flagged for deletion (= which
  /// value equals [StickyQueryParam.deleteFlag]).
  ///
  /// For optimization, this is not executed if the [VxRouteSwitcher] is nested,
  /// so that this code only gets executed by the top-most [VxRouteSwitcher]'s
  /// switchRoute's afterEnterAndUpdate.
  ///
  /// > NB : In beforeEnter/Update, when we redirect to a url, the new
  /// > vRedirector gets the same old vRouterData. For this reason, we can't
  /// > delete the flagged sticky query params in beforeEnter/Update. Instead,
  /// > we do this afterEnter/Update.
  Future<void> _afterEnterAndUpdate(
      BuildContext context, String? from, String to) async {
    if (isVxRouteSwitcherNested) {
      return;
    }

    final newUri = Uri.parse(to);

    final newStickyQueryParams =
        StickyQueryParam.getStickyQueryParams(newUri.queryParameters);

    final queryParamsToDelete = newStickyQueryParams
        .filter((value) => value == StickyQueryParam.deleteFlag);

    if (queryParamsToDelete.isEmpty) {
      return;
    }

    /// We remove the queryParamsToDelete
    final updatedQueryParams = newUri.queryParameters
        .filterWithKey((key, value) => !queryParamsToDelete.containsKey(key));

    final updatedUri = newUri.replace(
      queryParameters: updatedQueryParams,
    );

    logger.i('''
      Deleting the queryParams "$queryParamsToDelete" in switchRoute "${routeInfoInstance.name}"
      Updated url : ${updatedUri.toString()}
      ''');
    context.vRouter.to(updatedUri.toString());
  }

  @override
  List<VRouteElement> buildRoutes() {
    return [
      /// TODO create a VRouteElement for this VGuard named "StickyParamsScope"
      /// with a bool 'enabled' to be able to reuse it here. Or without the bool
      /// and conditionnaly include it or not.
      ///
      /// StickyParamScope can either accept an exact query parameter, or a
      /// prefix. It will persist the query param(s) in all its subroutes.
      ///
      /// I think the VxRouteSwitcher's redirectToQueryParam should behave the
      /// same way : its persistence should be scoped to its VxRouteSwitcher.
      /// The problem is should the child's redirectToQueryParam be encoded in
      /// the parent's redirectToQueryParam ? Also, the child will attempt to
      /// encode its parent's redirectToQueryParam...(though this can be
      /// prevented by adding a nullable "redirectToQueryParam" field in
      /// ParentRouteSwitcher). I think that parents can encode childs
      /// redirectToQueryParams, but the opposite shouldn't be possible. and
      /// each VxRouteSwitcher will have its StickyParamsScope that will persist
      /// their redirectToQueryParam.
      ///
      /// Also, the other sticky query params we may use in our app will be
      /// encoded in the "redirectTo" query params even though they might be
      /// persisted, which could be troublesome...
      ///
      /// We can optionally make it unscoped by using a prefix. (like we do
      /// right now).
      ///
      /// So that one can enjoy it without needing a VxRouteSwitcher. or maybe
      /// not, I don't need it.
      ///
      /// TODO Consider moving this VGuard in VxRouteSwitcher ? This may allow
      /// us to simplify the code in VxRouteSwitcher in such a way that we won't
      /// care about persisting the sticky query params in all the places, it
      /// will be done for us.
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
