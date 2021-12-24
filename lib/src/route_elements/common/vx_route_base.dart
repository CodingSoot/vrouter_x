import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/route_elements/common/route_info_base.dart';
import 'package:vrouter_x/src/route_elements/common/route_ref.dart';

abstract class VxRouteBase extends VRouteElementBuilder {
  RouteInfoBase get routeInfoInstance;

  RouteRef get routeRef;
}
