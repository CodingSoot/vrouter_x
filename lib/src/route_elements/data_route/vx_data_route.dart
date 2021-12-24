import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/route_elements/common/route_info_base.dart';
import 'package:vrouter_x/src/route_elements/common/route_ref.dart';
import 'package:vrouter_x/src/route_elements/common/vx_route_base.dart';
import 'package:vrouter_x/src/route_elements/data_route/route_data.dart';

part 'data_route_info.dart';

abstract class VxDataRoute<P extends RouteData> extends VxRouteBase {
  VxDataRoute({
    required this.routeRef,
    required this.routeInfoInstance,
    this.guardBefore = true,
    this.redirectingScreen = _emptyRedirectingScreen,
    this.beforeRedirect = _voidBeforeRedirect,
    this.afterRedirect = _voidAfterRedirect,
  });

  final Widget Function(BuildContext context, WidgetRef ref) redirectingScreen;
  final Future<void> Function() beforeRedirect;
  final Future<void> Function() afterRedirect;
  final bool guardBefore;
  @override
  final RouteRef routeRef;

  @override
  final DataRouteInfo<P> routeInfoInstance;

  static Widget _emptyRedirectingScreen(BuildContext context, WidgetRef ref) =>
      Container();
  static Future<void> _voidBeforeRedirect() async {}
  static Future<void> _voidAfterRedirect() async {}

  @override
  List<VRouteElement> buildRoutes() {
    return [
      VGuard(
        beforeEnter: _beforeEnterAndUpdate,
        beforeUpdate: _beforeEnterAndUpdate,
        stackedRoutes: buildRoutesX(
          (child) => Consumer(
            builder: (context, ref, _) {
              ref.watch(routeInfoInstance._widgetDisposedProvider);

              final paramsOption =
                  ref.watch(routeInfoInstance._paramsOptionProvider);

              return paramsOption.match(
                (params) => ProviderScope(
                  overrides: [
                    routeInfoInstance.paramsProvider.overrideWithValue(params),
                  ],
                  child: child,
                ),
                () {
                  ///NB : Unless guardBefore is false, or there are some weird navigation caveats, this part of the
                  ///code is never going to be reached. But if it does, just in case, we
                  ///handle the redirection and show a redirectionScreen meanwhile.
                  ///
                  ///
                  WidgetsBinding.instance
                      ?.addPostFrameCallback((timeStamp) async {
                    await beforeRedirect();

                    context.vRouter.to(routeInfoInstance.redirectPath);

                    await afterRedirect();
                  });
                  return redirectingScreen(context, ref);
                },
              );
            },
          ),
        ),
      ),
    ];
  }

  List<VRouteElement> buildRoutesX(
    Widget Function(Widget child) widgetWrapper,
  );

  Future<void> _beforeEnterAndUpdate(VRedirector vRedirector) async {
    if (guardBefore) {
      await beforeRedirect();

      final paramsOption =
          routeRef.read(routeInfoInstance._paramsOptionProvider);
      paramsOption.match(
        (some) {},
        () {
          vRedirector.to(routeInfoInstance.redirectPath);
        },
      );

      await afterRedirect();
    }
  }
}
