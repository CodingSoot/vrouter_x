part of 'vx_data_route.dart';

/// Must be static.
@immutable
class DataRouteInfo<P extends RouteData> extends RouteInfoBase {
  DataRouteInfo({
    required String path,
    required this.redirectPath,
  }) : super(path: path) {
    _widgetDisposedProvider = Provider.autoDispose<void>((ref) {
      ref.onDispose(() {
        ref.read(_paramsOptionProvider.state).state = none();
      });
    });
  }

  final paramsProvider = Provider<P>((ref) {
    throw UnimplementedError();
  });

  /// We redirect to this path if the params are not provided.
  final String redirectPath;

  late final AutoDisposeProvider<void> _widgetDisposedProvider;

  final _paramsOptionProvider = StateProvider<Option<P>>((ref) {
    return none();
  });

  void navigate(
    RouteRef routeRef,
    void Function(String path) to, {
    required P data,
  }) {
    routeRef.read(_paramsOptionProvider.state).state = some(data);
    to(path);
  }
}
