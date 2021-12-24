part of 'vx_route_switcher.dart';

abstract class VxSwitchRoute<P extends RouteData> extends VxRouteBase {
  VxSwitchRoute({
    required this.routeRef,
    required this.routeInfoInstance,
    this.redirectingScreen = _emptyRedirectingScreen,
  });

  final Widget Function(BuildContext context, WidgetRef ref) redirectingScreen;

  @override
  final RouteRef routeRef;

  @override
  final SwitchRouteInfo<P> routeInfoInstance;

  static Widget _emptyRedirectingScreen(BuildContext context, WidgetRef ref) =>
      Container();

  @override
  List<VRouteElement> buildRoutes() {
    return buildRoutesX(
      (child) => Consumer(
        builder: (context, ref, _) {
          ref.watch(routeInfoInstance._widgetDisposedProvider);

          final paramsOption =
              ref.watch(routeInfoInstance._paramsOptionProvider);

          return paramsOption.match(
            (params) => ProviderScope(
              overrides: [
                routeInfoInstance.paramsProvider.overrideWithValue(params),
              ],
              child: child,
            ),
            () {
              return redirectingScreen(context, ref);
            },
          );
        },
      ),
    );
  }

  List<VRouteElement> buildRoutesX(
    Widget Function(Widget child) widgetWrapper,
  );
}
