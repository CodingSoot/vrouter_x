import 'package:vrouter/vrouter.dart';

import 'package:vrouter_x/src/route_elements/common/route_data.dart';
import 'package:vrouter_x/src/route_elements/route_switcher/vx_route_switcher.dart';

/// See [VxRouteSwitcher.mapStateToSwitchRoute] for documentation.
class MatchedRouteDetails<P extends RouteData> {
  MatchedRouteDetails({
    required this.switchRouteName,
    required this.routeData,
    this.pathParameters = const {},
    this.queryParameters = const {},
    this.historyState = const {},
    this.hash = '',
    this.isReplacement = false,
  });

  /// The name of the switchRoute
  final String switchRouteName;

  /// The routeData of the switchRoute
  final P routeData;

  /// See [VRouterNavigator.toNamed]
  final Map<String, String> queryParameters;

  /// See [VRouterNavigator.toNamed]
  final Map<String, String> pathParameters;

  /// See [VRouterNavigator.toNamed]
  final String hash;

  /// See [VRouterNavigator.toNamed]
  final Map<String, String> historyState;

  /// See [VRouterNavigator.toNamed]
  final bool isReplacement;

  @override
  String toString() {
    return 'MatchedRouteDetails(switchRouteName: $switchRouteName, routeData: $routeData, queryParameters: $queryParameters, pathParameters: $pathParameters, hash: $hash, historyState: $historyState, isReplacement: $isReplacement)';
  }

  MatchedRouteDetails<P> copyWith({
    String? switchRouteName,
    P? routeData,
    Map<String, String>? queryParameters,
    Map<String, String>? pathParameters,
    String? hash,
    Map<String, String>? historyState,
    bool? isReplacement,
  }) {
    return MatchedRouteDetails<P>(
      switchRouteName: switchRouteName ?? this.switchRouteName,
      routeData: routeData ?? this.routeData,
      queryParameters: queryParameters ?? this.queryParameters,
      pathParameters: pathParameters ?? this.pathParameters,
      hash: hash ?? this.hash,
      historyState: historyState ?? this.historyState,
      isReplacement: isReplacement ?? this.isReplacement,
    );
  }
}
