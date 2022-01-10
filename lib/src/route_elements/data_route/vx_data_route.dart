import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/route_elements/common/route_info_base.dart';
import 'package:vrouter_x/src/route_elements/common/vx_route_base.dart';
import 'package:vrouter_x/src/route_elements/route_elements.dart';
import 'package:vrouter_x/src/utils/logger.dart';
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
///   List<VRouteElement> buildRoutesX(
///       Widget Function(Widget child) widgetWrapper) {
///     return [
///       VWidget(
///         path: routeInfo.path,
///         widget: widgetWrapper(BookPage()),
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
    this.guardBefore = true,
    this.redirectingScreen = _emptyRedirectingScreen,
    this.beforeRedirect = _voidBeforeRedirect,
    this.afterRedirect = _voidAfterRedirect,
    this.minimumRedirectingScreenDuration = const Duration(milliseconds: 500),
  });

  @override
  final RouteRef routeRef;

  @override
  final DataRouteInfo<P> routeInfoInstance;

  /// This screen is shown during redirection, if [guardBefore] is false.
  ///
  /// Defaults to [VxDataRoute._emptyRedirectingScreen]
  final Widget Function(BuildContext context, WidgetRef ref) redirectingScreen;

  /// The minimum duration the [redirectingScreen] should be shown.
  ///
  /// NB: The redirection won't happen until [beforeRedirect] has
  /// finished executing AND [minimumRedirectingScreenDuration] has elapsed.
  final Duration minimumRedirectingScreenDuration;

  /// Called before redirecting.
  ///
  /// Defaults to [VxDataRoute._voidBeforeRedirect].
  final Future<void> Function() beforeRedirect;

  /// Called after redirecting.
  ///
  /// Defaults to [VxDataRoute._voidAfterRedirect].
  final Future<void> Function() afterRedirect;

  /// Whether the route should be guarded beforeEnter and beforeUpdate.
  ///
  /// If true, the redirection happens before the route is opened, so the
  /// [redirectingScreen] is not displayed.
  ///
  /// If false, the redirection happens after the route is opened, so the
  /// [redirectingScreen] is displayed.
  final bool guardBefore;

  static Widget _emptyRedirectingScreen(BuildContext context, WidgetRef ref) =>
      Container();

  static Future<void> _voidBeforeRedirect() async {}

  static Future<void> _voidAfterRedirect() async {}

  /// [previousVRouterData] is the vRouterData of the route before redirecting.
  void _redirect(
      VRouterNavigator vRouterNavigator, VRouterData previousVRouterData) {
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

    vRouterNavigator.toNamed(
      routeInfoInstance.redirectToRouteName,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      hash: hash,
      historyState: historyState,
      isReplacement: isReplacement,
    );
  }

  /// BeforeEnter and BeforeUpdate, we verify if the routeData has been
  /// provided. If not, we redirect to [routeInfoInstance.redirectToRouteName].
  ///
  Future<void> _beforeEnterAndUpdate(VRedirector vRedirector) async {
    if (guardBefore) {
      await beforeRedirect();

      final routeDataOption =
          routeRef.read(routeInfoInstance._routeDataOptionProvider);
      routeDataOption.match(
        (some) {},
        () {
          _redirect(vRedirector, vRedirector.newVRouterData!);
        },
      );

      await afterRedirect();
    }
  }

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

              final routeDataOption =
                  ref.watch(routeInfoInstance._routeDataOptionProvider);

              return routeDataOption.match(
                (routeData) => ProviderScope(
                  overrides: [
                    routeInfoInstance.routeDataProvider
                        .overrideWithValue(routeData),
                  ],
                  child: child,
                ),
                () {
                  /// If we actually entered this route without providing any data,
                  /// we handle the redirection and show a redirectionScreen
                  /// meanwhile.
                  ///
                  /// This is only supposed to happen if [guardBefore] is false.
                  /// If [guardBefore] is true, then the navigation should have
                  /// been stopped by the VGuard.
                  ///

                  if (guardBefore) {
                    logger.w('''
                    This VxDataRoute has been displayed while no routeData has been provided.
                    This should have been prevented by the VGuard. If you can't find
                    the root cause, you can ignore this message, since the redirection will be 
                    performed anyway.
                    ''');
                  }

                  WidgetsBinding.instance!
                      .addPostFrameCallback((timeStamp) async {
                    final startTime = DateTime.now();

                    await beforeRedirect();

                    final elapsedTime = DateTime.now().difference(startTime);

                    if (elapsedTime < minimumRedirectingScreenDuration) {
                      await Future.delayed(
                          minimumRedirectingScreenDuration - elapsedTime);
                    }

                    _redirect(context.vRouter, context.vRouter);

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

  /// See [buildRoutes].
  ///
  /// ⚠️ The [widgetWrapper] should wrap all the **top-level** [VRouteElement]s'
  /// widgets. Generally, you'll only have one top-level [VRouteElement].
  ///
  /// Example :
  ///
  /// ```dart
  /// List<VRouteElement> buildRoutesX(
  ///   Widget Function(Widget child) widgetWrapper,
  /// ) {
  ///   return [
  ///     VWidget(
  ///       path: path1,
  ///       widget: widgetWrapper(widget1), // HERE
  ///       stackedRoutes: [
  ///         // These routes' widgets don't need to be wrapped
  ///         ...
  ///       ],
  ///     ),
  ///     VNester(
  ///       path: path2,
  ///       widgetBuilder: widgetWrapper, // HERE
  ///       nestedRoutes: [
  ///         // These routes' widgets don't need to be wrapped
  ///         ...
  ///       ],
  ///       stackedRoutes: [
  ///         // These routes' widgets don't need to be wrapped
  ///         ...
  ///       ]
  ///     ),
  ///   ];
  /// }
  /// ```
  ///
  List<VRouteElement> buildRoutesX(
    Widget Function(Widget child) widgetWrapper,
  );
}
