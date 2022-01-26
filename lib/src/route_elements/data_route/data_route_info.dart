part of 'vx_data_route.dart';

/// Must be static.
@immutable
class DataRouteInfo<P extends RouteData> extends RouteInfoBase {
  DataRouteInfo({
    required String? path,
    required String name,
    required this.redirectToRouteName,
    required this.redirectToResolver,
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
  /// [VxDataRoute]'s widget tree, so it should only be accessed from there.
  final routeDataProvider = Provider<P>((ref) {
    throw UnimplementedError();
  });

  /// The name of the route we redirect to if the routeData is not provided.
  final String redirectToRouteName;

  /// Used to determine what path parameters to pass to
  /// [VRouterNavigator.toNamed] during the redirection. (As well as other
  /// optional parameters such as the query parameters, hash...)
  final RedirectToResolver redirectToResolver;

  /// This provider is used internally to watch whether this route's widget tree
  /// has been disposed.
  late final AutoDisposeProvider<void> _widgetDisposedProvider;

  /// This provider holds either none() if no routeData has been passed to
  /// this route, or some(routeData).
  final _routeDataOptionProvider = StateProvider<Option<P>>((ref) {
    return none();
  });

  void navigate(
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
}
