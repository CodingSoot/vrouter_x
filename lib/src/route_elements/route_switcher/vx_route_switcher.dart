import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/route_elements/common/route_info_base.dart';
import 'package:vrouter_x/src/route_elements/common/route_ref.dart';
import 'package:vrouter_x/src/route_elements/common/vx_route_base.dart';
import 'package:vrouter_x/src/route_elements/data_route/route_data.dart';
import 'package:vrouter_x/src/route_elements/route_switcher/map_result.dart';

part 'switch_route_info.dart';
part 'vx_switch_route.dart';

class VxRouteSwitcher<T> extends VRouteElementBuilder {
  VxRouteSwitcher(
    this.routeRef, {
    required this.path,
    required this.nestedRoutes,
    required this.provider,
    required this.mapStateToRoute,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.buildTransition,
    this.key,
    this.name,
    this.aliases = const [],
    this.navigatorKey,
    this.fullscreenDialog = false,
  });

  final RouteRef routeRef;

  /// A list of [VxSwitchRoute] which widget will be accessible in [widgetBuilder]
  final List<VxSwitchRoute> nestedRoutes;

  /// See [VNester.path]
  final String? path;

  /// See [VNester.name]
  final String? name;

  /// See [VNester.aliases]
  final List<String> aliases;

  /// See [VNester.key]
  final LocalKey? key;

  /// See [VNester.transitionDuration]
  final Duration? transitionDuration;

  /// See [VNester.reverseTransitionDuration]
  final Duration? reverseTransitionDuration;

  /// See [VNester.buildTransition]
  final Widget Function(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child)? buildTransition;

  /// See [VNester.navigatorKey]
  final GlobalKey<NavigatorState>? navigatorKey;

  /// See [VNester.fullscreenDialog]
  final bool fullscreenDialog;

  final ProviderBase<T> provider;

  final MapResult Function(T state) mapStateToRoute;

  List<String> get _allPaths =>
      nestedRoutes.map((route) => route.routeInfoInstance.path).toList();

  List<String> _allPathsExcept(String exceptPath) =>
      _allPaths.where((element) => element != exceptPath).toList();

  bool _shouldRedirect(String? currentPath, MapResult mapResult) {
    if (mapResult.isMainRoute) {
      return _allPathsExcept(mapResult.routeInfo.path)
          .any((p) => p == currentPath);
    }
    return currentPath != mapResult.routeInfo.path;
  }

  Future<void> _beforeEnterAndUpdate(VRedirector vRedirector) async {
    final currentPath = vRedirector.newVRouterData?.path;

    final state = routeRef.read(provider);
    final mapResult = mapStateToRoute(state);

    if (_shouldRedirect(currentPath, mapResult)) {
      mapResult.routeInfo.navigate(
        routeRef,
        (path) => vRedirector.to(path),
        params: mapResult.routeParams,
      );
    }
  }

  @override
  List<VRouteElement> buildRoutes() {
    return [
      VGuard(
        beforeEnter: _beforeEnterAndUpdate,
        beforeUpdate: _beforeEnterAndUpdate,
        stackedRoutes: [
          VNester.builder(
            path: path,
            widgetBuilder: (context, vRouterData, child) => Consumer(
              builder: (context, ref, _) {
                final currentPath = vRouterData.path;

                ref.listen<T>(provider, (previous, next) {
                  final mapResult = mapStateToRoute(next);

                  if (_shouldRedirect(currentPath, mapResult)) {
                    mapResult.routeInfo.navigate(
                      routeRef,
                      (path) => context.vRouter.to(path),
                      params: mapResult.routeParams,
                    );
                  } else {
                    mapResult.routeInfo._updateParams(
                      routeRef,
                      params: mapResult.routeParams,
                    );
                  }
                });

                return child;
              },
            ),
            nestedRoutes: nestedRoutes,
          ),
        ],
      ),
    ];
  }
}
