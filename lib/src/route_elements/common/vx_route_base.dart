import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/route_elements/common/route_info_base.dart';
import 'package:vrouter_x/src/route_elements/common/route_ref.dart';

abstract class VxRouteBase extends VRouteElementBuilder {
  RouteInfoBase get routeInfoInstance;

  /// A riverpod ref. It should be scoped to the main app's ProviderScope. It is
  /// used to be able to **read** providers from within the routes, outside of
  /// the widget tree.
  ///
  /// Usually, you'll be creating a routeRef from the `WidgetRef` of your main
  /// app's widget, and passing it to all your routes :
  ///
  /// ```dart
  /// class MyApp extends ConsumerWidget {
  ///   const MyApp({
  ///     Key? key,
  ///   }) : super(key: key);
  ///
  ///   @override
  ///   Widget build(BuildContext context, WidgetRef ref) {
  ///     final routeRef = RouteRef.fromWidgetRef(ref);
  ///
  ///     return VRouter(
  ///       routes: [
  ///         MainRoute(routeRef),
  ///         ProfileRoute(routeRef),
  ///         ...
  ///       ],
  ///     );
  ///   }
  /// }
  /// ```
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
