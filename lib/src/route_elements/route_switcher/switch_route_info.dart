part of 'vx_route_switcher.dart';

/// Must be static.
@immutable
class SwitchRouteInfo<P extends RouteData> extends RouteInfoBase {
  SwitchRouteInfo({
    required String? path,
    required String name,
  }) : super(path: path, name: name);

  /// Provider for the routeData of this route. It is scoped to the
  /// [VxSwitchRoute]'s widget tree, so it should only be accessed from there.
  final routeDataProvider = Provider<P>((ref) {
    throw UnimplementedError();
  });

  /// Use this provider instead of [routeDataProvider] when you want to safely
  /// access the routeData from outside this [VxSwitchRoute]'s widget tree.
  ///
  /// This is often the case when you have some scaffolding that is outside the
  /// route and that needs to access the routeData.
  ///
  /// This provider holds `none()` if the route is not in the current stack,
  /// otherwise it holds `some(routeData)`.
  late final routeDataOptionProvider = Provider<Option<P>>((ref) {
    final routeDataOption = ref.watch(_routeDataOptionProvider);
    return routeDataOption;
  });

  /// This provider is used internally to watch whether this route's widget tree
  /// has been disposed.
  ///
  /// Whenever this route's widget tree is disposed, we reset the
  /// [_routeDataOptionProvider] to none().
  late final _widgetDisposedProvider = Provider.autoDispose<void>((ref) {
    ref.onDispose(() {
      ref.read(_routeDataOptionProvider.state).state = none();
    });
  });

  /// This stateProvider is used internally to store the routeData of thie
  /// route. It holds either `none()` if no routeData has been passed to this
  /// route, otherwise it holds `some(routeData)`.
  final _routeDataOptionProvider = StateProvider<Option<P>>((ref) {
    return none();
  });

  /// This is private because navigation between [VxSwitchRoute]s is handled
  /// automatically by the [VxRouteSwitcher]
  void _navigate(
    RouteRef routeRef,
    VRouterNavigator vRouterNavigator, {
    required P data,
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
    String hash = '',
    bool isReplacement = false,
  }) {
    routeRef.read(_routeDataOptionProvider.state).state = some(data);

    vRouterNavigator.toNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      historyState: historyState,
      hash: hash,
      isReplacement: isReplacement,
    );
  }

  void _updateRouteData(
    RouteRef routeRef, {
    required P data,
  }) {
    if (routeRef.read(_routeDataOptionProvider).isNone()) {
      throw Exception('''
        Called _updateRouteData while the routeData has not been set before.
        ''');
    }

    routeRef.read(_routeDataOptionProvider.state).state = some(data);
  }

  void _setRouteData(
    RouteRef routeRef, {
    required P data,
  }) {
    if (routeRef.read(_routeDataOptionProvider).isSome()) {
      throw Exception('''
        Called _setRouteData while the routeData has been already set.
        ''');
    }

    routeRef.read(_routeDataOptionProvider.state).state = some(data);
  }
}
