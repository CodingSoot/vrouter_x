part of 'vx_route_switcher.dart';

/// Must be static.
@immutable
class SwitchRouteInfo<P extends RouteData> extends RouteInfoBase {
  SwitchRouteInfo({
    required String path,
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

  late final AutoDisposeProvider<void> _widgetDisposedProvider;

  final _paramsOptionProvider = StateProvider<Option<P>>((ref) {
    return none();
  });

  void navigate(
    RouteRef routeRef,
    void Function(String path) to, {
    required P params,
  }) {
    routeRef.read(_paramsOptionProvider.state).state = some(params);
    to(path);
  }

  void _updateParams(
    RouteRef routeRef, {
    required P params,
  }) {
    if (routeRef.read(_paramsOptionProvider).isNone()) {
      throw Exception(
          '_updateParams should only be called when the route is already in the stack');
    }

    routeRef.read(_paramsOptionProvider.state).state = some(params);
  }
}
