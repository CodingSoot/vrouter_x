import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/route_elements/common/route_info_base.dart';
import 'package:vrouter_x/src/route_elements/common/route_ref.dart';

abstract class VxRouteBase extends VRouteElementBuilder {
  RouteInfoBase get routeInfoInstance;

  RouteRef get routeRef;

  /// Wraps the widgets of all the routes of this VxRoute (nested and stacked.)
  ///
  /// NB: If you want access to the [WidgetRef], just use a [Consumer].
  Widget Function(BuildContext context, VRouterData vRouterData, Widget child)
      get widgetBuilder;

  static Widget defaultWidgetBuilder(
          BuildContext context, VRouterData vRouterData, Widget child) =>
      child;
}
