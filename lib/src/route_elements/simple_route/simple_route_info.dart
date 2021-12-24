import 'package:vrouter_x/src/route_elements/common/route_info_base.dart';

class SimpleRouteInfo extends RouteInfoBase {
  SimpleRouteInfo({required String path}) : super(path: path);

  void navigate(void Function(String path) to) {
    to(path);
  }
}
