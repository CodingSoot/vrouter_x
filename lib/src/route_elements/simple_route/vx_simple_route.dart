import 'package:flutter/cupertino.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/route_elements/common/route_ref.dart';
import 'package:vrouter_x/src/route_elements/common/vx_route_base.dart';
import 'package:vrouter_x/src/route_elements/simple_route/simple_route_info.dart';

/// This is a basic route, that contains some common information needed for
/// navigation.
///
/// ### Usage :
///
/// 1. Create your route class that extends [VxSimpleRoute]
/// 2. The [routeInfoInstance] should be a reference to a static variable
/// `routeInfo`, that you'll create in your route class.
/// 3. Instead of overriding [buildRoutes], you should override [buildRoutesX]
///    and return your list of VRouteElements there.
///
/// ### Example :
///
/// ```dart
/// class ProfileRoute extends VxSimpleRoute {
///   ProfileRoute(RouteRef routeRef)
///       : super(
///           routeInfoInstance: routeInfo,
///           routeRef: routeRef,
///         );
///
///   static final routeInfo = SimpleRouteInfo(
///     path: '/profile',
///     name: 'profile',
///   );
///
///   @override
///   List<VRouteElement> buildRoutesX() {
///     return [
///          VWidget(
///            path: null, // This will match the path specified in [routeInfo]
///            widget: ProfilePage(),
///          ),
///        ];
///   }
/// }
/// ```
///
/// To navigate, you can call : `ProfileRoute.routeInfo.navigate(...)`
abstract class VxSimpleRoute extends VxRouteBase {
  VxSimpleRoute({
    required this.routeRef,
    required this.routeInfoInstance,
    this.widgetBuilder = VxRouteBase.defaultWidgetBuilder,
  });

  @override
  final RouteRef routeRef;

  @override
  final SimpleRouteInfo routeInfoInstance;

  @override
  final Widget Function(
          BuildContext context, VRouterData vRouterData, Widget child)
      widgetBuilder;

  @override
  List<VRouteElement> buildRoutes() {
    return [
      VNester.builder(
        path: routeInfoInstance.path,
        name: routeInfoInstance.name,
        key: ValueKey(routeInfoInstance.name),
        widgetBuilder: widgetBuilder,
        nestedRoutes: buildRoutesX(),
      ),
    ];
  }

  /// See [buildRoutes].
  ///
  List<VRouteElement> buildRoutesX();
}
