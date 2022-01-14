part of 'vx_route_switcher.dart';

/// Must be static.
@immutable
class SwitchRouteInfo<P extends RouteData> extends RouteInfoBase {
  SwitchRouteInfo({
    required String path,
    required String name,
  }) : super(path: path, name: name) {
    /// When this route's widget tree has been disposed, we reset the
    /// [_routeDataOptionProvider] to none().
    _widgetDisposedProvider = Provider.autoDispose<void>((ref) {
      ref.onDispose(() {
        ref.read(_routeDataOptionProvider.state).state = none();
      });
    });
  }

  /// Provider for the routeData of this route. It is scoped to the
  /// [VxSwitchRoute]'s widget tree, so it should only be accessed from there.
  final routeDataProvider = Provider<P>((ref) {
    throw UnimplementedError();
  });

  /// This provider is used internally to watch whether this route's widget tree
  /// has been disposed.
  late final AutoDisposeProvider<void> _widgetDisposedProvider;

  /// This provider holds either none() if no routeData has been passed to
  /// this route, or some(routeData).
  ///
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
      throw Exception(
          '_updateRouteData should only be called when the route is already in the stack');
    }

    routeRef.read(_routeDataOptionProvider.state).state = some(data);
  }
}
