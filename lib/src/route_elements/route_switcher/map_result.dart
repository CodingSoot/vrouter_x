import 'package:vrouter_x/src/route_elements/data_route/route_data.dart';
import 'package:vrouter_x/src/route_elements/route_switcher/vx_route_switcher.dart';

class MapResult<P extends RouteData> {
  MapResult({
    required this.routeInfo,
    required this.routeParams,
    required this.isMainRoute,
  });

  final SwitchRouteInfo<P> routeInfo;

  final P routeParams;

  final bool isMainRoute;

  @override
  String toString() =>
      'MapResult(routeInfo: $routeInfo, routeParams: $routeParams, isMainRoute: $isMainRoute)';
}
