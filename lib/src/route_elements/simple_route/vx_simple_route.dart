import 'package:vrouter_x/src/route_elements/common/route_ref.dart';
import 'package:vrouter_x/src/route_elements/common/vx_route_base.dart';
import 'package:vrouter_x/src/route_elements/simple_route/simple_route_info.dart';

abstract class VxSimpleRoute extends VxRouteBase {
  VxSimpleRoute({
    required this.routeRef,
    required this.routeInfoInstance,
  });

  @override
  final RouteRef routeRef;

  @override
  final SimpleRouteInfo routeInfoInstance;
}
