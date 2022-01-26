import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/route_elements/common/route_info_base.dart';

class SimpleRouteInfo extends RouteInfoBase {
  SimpleRouteInfo({
    required String? path,
    required String name,
  }) : super(path: path, name: name);

  void navigate(
    VRouterNavigator vRouterNavigator, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
    String hash = '',
    bool isReplacement = false,
  }) {
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
