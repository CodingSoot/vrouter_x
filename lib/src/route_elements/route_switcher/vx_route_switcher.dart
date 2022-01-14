import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/route_elements/common/route_info_base.dart';
import 'package:vrouter_x/src/route_elements/common/route_ref.dart';
import 'package:vrouter_x/src/route_elements/common/vx_route_base.dart';
import 'package:vrouter_x/src/route_elements/common/route_data.dart';
import 'package:vrouter_x/src/route_elements/route_switcher/matched_route_details.dart';
import 'package:vrouter_x/src/utils/errors.dart';
import 'package:vrouter_x/src/utils/logger.dart';

part 'switch_route_info.dart';
part 'vx_switch_route.dart';

/// This is a route element (a VNester) that allows to automatically navigate
/// between its [switchRoutes] based on the state of a riverpod [provider].
class VxRouteSwitcher<T> extends VRouteElementBuilder {
  VxRouteSwitcher(
    this.routeRef, {
    required this.path,
    required this.switchRoutes,
    required this.provider,
    required this.mapStateToSwitchRoute,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.buildTransition,
    this.key,
    this.name,
    this.aliases = const [],
    this.navigatorKey,
    this.fullscreenDialog = false,
  }) : assert(
            switchRoutes
                    .map((route) => route.routeInfoInstance.name)
                    .toSet()
                    .length ==
                switchRoutes.length,
            "The switchRoutes should have unique names.");

  final RouteRef routeRef;

  /// The provider you want to listen to.
  final ProviderBase<T> provider;

  /// Maps the current [state] of the [provider] to the route that should be
  /// displayed (= the matched switchRoute), wrapped inside a [MatchedRouteDetails].
  ///
  /// Example :
  ///
  /// ```dart
  /// VxRouteSwitcher<Option<String>>(
  ///   ... ,
  ///   provider : usernameOptionProvider,
  ///   mapStateToSwitchRoute: (state, previousVRouterData) => state.match(
  ///       (username) => MatchedRouteDetails(
  ///             switchRouteName: ProfileRoute.routeInfo.name,
  ///             routeData: ProfileRouteData(username: username),
  ///           ),
  ///       () => MatchedRouteDetails(
  ///             switchRouteName: LoginRoute.routeInfo.name,
  ///             routeData: LoginRouteData(),
  ///           )),
  /// )
  /// ```
  ///
  /// You can provide additionnal parameters into the [MatchedRouteDetails], such as the
  /// path parameters, query parameters... which will be passed to the
  /// [VRouterNavigator.toNamed] method during navigation.
  ///
  /// [vRouterData] is the vRouterData of the route before switching (=
  /// automatically navigating) to the matched switchRoute. It can be useful for
  /// extracting pathParameters.
  ///
  /// Example :
  ///
  /// ```dart
  /// mapStateToSwitchRoute: (state, previousVRouterData) => state.match(
  ///       (username) => MatchedRouteDetails(
  ///             switchRouteName: ProfileRoute.routeInfo.name,
  ///             routeData: ProfileRouteData(username: username),
  ///             pathParameters: VxUtils.extractPathParamsFromVRouterData(previousVRouterData, ['id'])
  ///           ),
  ///       ...
  /// ```
  ///
  final MatchedRouteDetails Function(T state, VRouterData vRouterData)
      mapStateToSwitchRoute;

  /// The list of routes you want to automatically switch between.
  final List<VxSwitchRoute> switchRoutes;

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

  /// Returns the [VxSwitchRoute] which name is [routeName].
  ///
  /// Throws a [RouteNotFoundError] if no [VxSwitchRoute] has this name.
  VxSwitchRoute<RouteData> _getSwitchRouteFromName(String routeName) {
    return switchRoutes.firstWhere(
      (route) => route.routeInfoInstance.name == routeName,
      orElse: () => throw RouteNotFoundError(customMessage: '''
          The route "$routeName" was not found among the provided switchRoutes. 
          Make sure the route is included in [switchRoutes].
          '''),
    );
  }

  /// Returns the [VxSwitchRoute] corresponding to the [vRouterData].
  ///
  /// NB: This works even when we are in a subroute of a [VxSwitchRoute].
  ///
  VxSwitchRoute<RouteData> _getSwitchRouteFromVRouterData(
      VRouterData vRouterData) {
    return switchRoutes.firstWhere(
      (route) => vRouterData.names.contains(route.routeInfoInstance.name),
      orElse: () => throw RouteNotFoundError(),
    );
  }

  /// Navigates to the switchRoute represented by [matchedRouteDetails], using the
  /// provided [vRouterNavigator].
  void _navigate({
    required String debugSource,
    required VRouterNavigator vRouterNavigator,
    required MatchedRouteDetails<RouteData> matchedRouteDetails,
  }) {
    logger.i('''
    ↓↓↓ Navigating : $debugSource ↓↓↓
    destination : ${matchedRouteDetails.switchRouteName}

    ''');

    final matchedSwitchRoute =
        _getSwitchRouteFromName(matchedRouteDetails.switchRouteName);

    matchedSwitchRoute.routeInfoInstance._navigate(
      routeRef,
      vRouterNavigator,
      data: matchedRouteDetails.routeData,
      pathParameters: matchedRouteDetails.pathParameters,
      queryParameters: matchedRouteDetails.queryParameters,
      historyState: matchedRouteDetails.historyState,
      hash: matchedRouteDetails.hash,
      isReplacement: matchedRouteDetails.isReplacement,
    );
  }

  /// BeforeEnter and BeforeUpdate :
  ///
  /// 1. We verify if the switchRoute we want to access is the matched
  ///    switchRoute
  /// 2. If no : We redirect to the matched switchRoute.
  /// 3. If yes : We verify if routeData is missing. If so, we navigate to the
  ///    same switchRoute while passing the missing routeData (that is contained
  ///    in `matchedRouteDetails`)
  ///

  Future<void> _beforeEnterAndUpdate(VRedirector vRedirector) async {
    /// 1.
    final newSwitchRoute =
        _getSwitchRouteFromVRouterData(vRedirector.newVRouterData!);

    final state = routeRef.read(provider);
    final matchedRouteDetails =
        mapStateToSwitchRoute(state, vRedirector.newVRouterData!);

    final shouldRedirect = newSwitchRoute.routeInfoInstance.name !=
        matchedRouteDetails.switchRouteName;

    /// 2.
    if (shouldRedirect) {
      _navigate(
        debugSource: '_beforeEnterAndUpdate (1)',
        vRouterNavigator: vRedirector,
        matchedRouteDetails: matchedRouteDetails,
      );

      /// Not awaiting this on purpose.
      newSwitchRoute.afterRedirect();
    }

    // /// 3.
    else {
      final routeDataOption = routeRef
          .read(newSwitchRoute.routeInfoInstance._routeDataOptionProvider);
      if (routeDataOption.isNone()) {
        _navigate(
          debugSource: '_beforeEnterAndUpdate (2)',
          vRouterNavigator: vRedirector,
          matchedRouteDetails: matchedRouteDetails,
        );
      }
    }
  }

  /// When we are inside a route, and the state changed :
  ///
  /// 1. We verify if the matched switchRoute corresponding to the new state is
  ///    the current switchRoute.
  /// 2. If no : We switch to (=navigate to) the matched switchedRoute
  /// 3. If yes : We update the current switchRoute's routeData with the new
  ///    routeData (that is contained in `matchedRouteDetails`)
  ///
  void _onStateChanged(
      BuildContext context, WidgetRef ref, T? previousState, T newState) {
    final currentSwitchRoute = _getSwitchRouteFromVRouterData(context.vRouter);

    final matchedRouteDetails =
        mapStateToSwitchRoute(newState, context.vRouter);
    final matchedSwitchRoute =
        _getSwitchRouteFromName(matchedRouteDetails.switchRouteName);

    final shouldSwitch = currentSwitchRoute.routeInfoInstance.name !=
        matchedRouteDetails.switchRouteName;

    if (shouldSwitch) {
      _navigate(
          debugSource: '_onStateChanged (2)',
          vRouterNavigator: context.vRouter,
          matchedRouteDetails: matchedRouteDetails);

      /// Not awaiting this on purpose.
      matchedSwitchRoute.afterSwitch();
    } else {
      matchedSwitchRoute.routeInfoInstance._updateRouteData(
        routeRef,
        data: matchedRouteDetails.routeData,
      );

      logger.i('''
        *** Updated routeData of route : ${matchedRouteDetails.routeData} ***
        ''');
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
                ref.listen<T>(provider, (previous, next) async {
                  _onStateChanged(context, ref, previous, next);
                });
                return child;
              },
            ),
            nestedRoutes: switchRoutes,
          ),
        ],
      ),
    ];
  }
}
