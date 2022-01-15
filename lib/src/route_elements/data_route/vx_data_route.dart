import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/route_elements/common/route_info_base.dart';
import 'package:vrouter_x/src/route_elements/common/vx_route_base.dart';
import 'package:vrouter_x/src/route_elements/route_elements.dart';
import 'package:vrouter_x/src/utils/errors.dart';
import 'package:vrouter_x/src/utils/vx_utils.dart';

part 'data_route_info.dart';

/// This is a route that requires some [RouteData] to be able to navigate to it.
/// If the [RouteData] is not provided, then we are automatically redirected to
/// another route (which you'll precise in `routeInfo`).
///
/// Steps :
///
/// 1. Create a Dataclass that extends [RouteData]
/// 2. Create your route class that extends [VxDataRoute]
/// 3. The [routeInfoInstance] should be a reference to a static variable
///    `routeInfo`, that you'll create in your route class.
/// 4. Instead of overriding [buildRoutes], you should override [buildRoutesX]
///    and return your list of VRouteElements there.
///
/// Example :
///
///```dart
/// @freezed
/// class BookRouteData extends RouteData with _$BookRouteData {
///   const factory BookRouteData({
///     required String title,
///     required String author,
///   }) = _BookRouteData;
/// }
///
/// class BookRoute extends VxDataRoute<BookRouteData> {
///   BookRoute(RouteRef routeRef)
///       : super(
///           routeInfoInstance: routeInfo,
///           routeRef: routeRef,
///           ...
///         );
///
///   static final routeInfo = DataRouteInfo<BookRouteData>(
///     path: '/book',
///     name: 'book',
///     redirectToRouteName: 'all-books',
///     redirectToResolver: const RedirectToResolver.noPathParameters(),
///   );
///
///   @override
///   List<VRouteElement> buildRoutesX() {
///     return [
///       VWidget(
///         path: null,
///         widget: BookPage(),
///       ),
///     ];
///   }
/// }
///
///```
abstract class VxDataRoute<P extends RouteData> extends VxRouteBase {
  VxDataRoute({
    required this.routeRef,
    required this.routeInfoInstance,
    this.widgetBuilder = VxRouteBase.defaultWidgetBuilder,
    this.afterRedirect = _voidAfter,
  });

  @override
  final RouteRef routeRef;

  @override
  final DataRouteInfo<P> routeInfoInstance;

  @override
  final Widget Function(
          BuildContext context, VRouterData vRouterData, Widget child)
      widgetBuilder;

  /// Called after redirecting out of this route.
  ///
  /// Defaults to [VxDataRoute._voidAfter].
  final Future<void> Function() afterRedirect;

  static Future<void> _voidAfter() async {}

  /// Redirects to [DataRouteInfo.redirectToRouteName], using
  /// [DataRouteInfo.redirectToResolver] to determine what path parameters to
  /// pass to [VRouterNavigator.toNamed] during the redirection. (As well as
  /// other optional parameters such as the query parameters, hash...)
  ///
  /// [previousVRouterData] is the vRouterData of the route before redirecting.
  void _redirect(
    VRedirector vRedirector,
    VRouterData previousVRouterData,
  ) {
    final redirectToResolver = routeInfoInstance.redirectToResolver;

    final queryParameters =
        redirectToResolver.queryParameters(routeRef, previousVRouterData);

    final historyState =
        redirectToResolver.historyState(routeRef, previousVRouterData);

    final hash = redirectToResolver.hash(routeRef, previousVRouterData);

    final isReplacement =
        redirectToResolver.isReplacement(routeRef, previousVRouterData);

    final pathParameters = redirectToResolver.map(
      automaticPathParameters: (automaticPathParameters) {
        //We extract the path parameters from the current vRouterData.
        final pathParamsToExtract = automaticPathParameters
            .extractedPathParameters(routeRef, previousVRouterData);

        return VxUtils.extractPathParamsFromVRouterData(
            previousVRouterData, pathParamsToExtract);
      },
      manualPathParameters: (manualPathParameters) {
        return manualPathParameters.pathParameters(
            routeRef, previousVRouterData);
      },
      noPathParameters: (noPathParameters) => const <String, String>{},
    );

    vRedirector.toNamed(
      routeInfoInstance.redirectToRouteName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      hash: hash,
      historyState: historyState,
      isReplacement: isReplacement,
    );
  }

  /// BeforeEnter and BeforeUpdate, we verify if the routeData has been
  /// provided. If not, we redirect to [DataRouteInfo.redirectToRouteName].
  ///
  Future<void> _beforeEnterAndUpdate(VRedirector vRedirector) async {
    final routeDataOption =
        routeRef.read(routeInfoInstance._routeDataOptionProvider);

    if (routeDataOption.isNone()) {
      _redirect(vRedirector, vRedirector.newVRouterData!);

      /// Not awaiting this.
      afterRedirect();
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
              path: routeInfoInstance.path,
              name: routeInfoInstance.name,
              key: ValueKey(routeInfoInstance.name),
              widgetBuilder: (context, vRouterData, child) => Consumer(
                builder: (context, ref, _) {
                  ref.watch(routeInfoInstance._widgetDisposedProvider);

                  final routeDataOption =
                      ref.watch(routeInfoInstance._routeDataOptionProvider);

                  return routeDataOption.match(
                    (routeData) => ProviderScope(
                      overrides: [
                        routeInfoInstance.routeDataProvider
                            .overrideWithValue(routeData),
                      ],
                      child: widgetBuilder(context, vRouterData, child),
                    ),
                    () {
                      throw UnreachableError(customMessage: '''
                      The route has been accessed while its routeData is none().
                      This should have been prevented by VxDataRoute's VGuard.
                      ''');
                    },
                  );
                },
              ),
              nestedRoutes: buildRoutesX(),
            ),
          ])
    ];
  }

  /// See [buildRoutes].

  List<VRouteElement> buildRoutesX();
}
