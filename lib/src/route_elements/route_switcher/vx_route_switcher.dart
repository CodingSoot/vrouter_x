import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/_core/logger.dart';
import 'package:vrouter_x/src/route_elements/common/route_info_base.dart';
import 'package:vrouter_x/src/route_elements/common/route_ref.dart';
import 'package:vrouter_x/src/route_elements/common/vx_route_base.dart';
import 'package:vrouter_x/src/route_elements/common/route_data.dart';
import 'package:vrouter_x/src/route_elements/route_switcher/matched_route_details.dart';
import 'package:vrouter_x/src/_core/errors.dart';
import 'package:vrouter_x/src/route_elements/route_switcher/parent_route_switcher.dart';

part 'switch_route_info.dart';
part 'vx_switch_route.dart';

/// This is a route element (a VNester) that allows to automatically navigate
/// between its [switchRoutes] based on the state of a riverpod [provider].
///
/// Some terminology :
/// - Matched switchRoute : The switchRoute matching the current state of your
///   provider
/// - Switching : Automatically navigating to the matched switchRoute when the
///   state changes.
class VxRouteSwitcher<T> extends VRouteElementBuilder {
  VxRouteSwitcher(
    this.routeRef, {
    required this.path,
    required this.switchRoutes,
    required this.provider,
    required this.mapStateToSwitchRoute,
    this.parentRouteSwitchers,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.buildTransition,
    this.key,
    this.name,
    this.aliases = const [],
    this.navigatorKey,
    this.fullscreenDialog = false,
  })  : isMainRedirectionEnabled = false,
        mainSwitchRouteName = null,
        redirectToQueryParam = null,
        assert(
            switchRoutes
                    .map((route) => route.routeInfoInstance.name)
                    .toSet()
                    .length ==
                switchRoutes.length,
            "The switchRoutes should have unique names.") {
    /// Initializing the late final class members
    /// [VxSwitchRoute.isMainRedirectionEnabled] and
    /// [VxSwitchRoute.isMainSwitchRoute]
    for (final switchRoute in switchRoutes) {
      switchRoute.isMainRedirectionEnabled = false;
      switchRoute.isMainSwitchRoute = null;
    }
  }

  /// Use this constructor when you want to enable "Main redirection".
  ///
  /// ### What is "main redirection" ?
  ///
  /// When you navigate to a **url** that points to a route inside your main
  /// switchRoute, but the matched switchRoute is not the main switchRoute, you
  /// are redirected to the matched switchRoute.
  ///
  /// In this situation, that **url** is stored inside the "redirectTo" query
  /// parameter, which will be persisted until the state matches your main
  /// switchRoute. When that happens, you are automatically navigated to that
  /// **url**, and the "redirectTo" query parameter is deleted.
  VxRouteSwitcher.withMainRedirection(
    this.routeRef, {
    required this.path,
    required this.switchRoutes,
    required this.provider,
    required this.mapStateToSwitchRoute,
    required this.mainSwitchRouteName,
    required this.redirectToQueryParam,
    this.parentRouteSwitchers,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.buildTransition,
    this.key,
    this.name,
    this.aliases = const [],
    this.navigatorKey,
    this.fullscreenDialog = false,
  })  : isMainRedirectionEnabled = true,
        assert(
            mainSwitchRouteName != null && redirectToQueryParam != null,
            "mainSwitchRouteName and redirectToQueryParam should not be null "
            "when using VxRouteSwitcher.withMainRedirection."),
        assert(redirectToQueryParam!.startsWith(StickyQueryParam.prefix),
            "The redirectToQueryParam must start with '${StickyQueryParam.prefix}'"),
        assert(
            switchRoutes
                .map((route) => route.routeInfoInstance.name)
                .contains(mainSwitchRouteName),
            "The mainSwitchRouteName should be the name of a switchRoute."),
        assert(
            switchRoutes
                    .map((route) => route.routeInfoInstance.name)
                    .toSet()
                    .length ==
                switchRoutes.length,
            "The switchRoutes should have unique names.") {
    /// Initializing the late final class members
    /// [VxSwitchRoute.isMainRedirectionEnabled] and
    /// [VxSwitchRoute.isMainSwitchRoute]
    for (final switchRoute in switchRoutes) {
      switchRoute.isMainRedirectionEnabled = true;
      switchRoute.isMainSwitchRoute =
          switchRoute.routeInfoInstance.name == mainSwitchRouteName;
    }
  }

  /// The provider you want to listen to.
  final ProviderBase<T> provider;

  /// Maps the current [state] of the [provider] to the switchRoute that should
  /// be displayed (= the matched switchRoute), wrapped inside a
  /// [MatchedRouteDetails].
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
  /// You can provide additionnal parameters into the [MatchedRouteDetails],
  /// such as the path parameters, query parameters... which will be passed to
  /// the [VRouterNavigator.toNamed] method during navigation.
  ///
  /// The passed `vRouterData` is the vRouterData of the route before switching
  /// (= automatically navigating) to the matched switchRoute. It can be useful
  /// for extracting pathParameters.
  ///
  /// Example :
  ///
  /// ```dart
  /// mapStateToSwitchRoute: (state, vRouterData) => state.match(
  ///       (username) => MatchedRouteDetails(
  ///             switchRouteName: ProfileRoute.routeInfo.name,
  ///             routeData: ProfileRouteData(username: username),
  ///             pathParameters: VxUtils.extractPathParamsFromVRouterData(vRouterData, ['id'])
  ///           ),
  ///       ...
  /// ```
  ///
  final MatchedRouteDetails Function(T state, VRouterData vRouterData)
      mapStateToSwitchRoute;

  /// The list of routes you want to automatically switch between.
  final List<VxSwitchRoute> switchRoutes;

  /// Whether the "main redirection" is enabled.
  ///
  /// ⚠️ When this is true, both [mainSwitchRouteName] and
  /// [redirectToQueryParam] are not null. Otherwise, both are null.
  ///
  final bool isMainRedirectionEnabled;

  /// This is the name of your main switchRoute, used for "main redirection".
  ///
  /// Not null if [isMainRedirectionEnabled] is true (null otherwise).
  final String? mainSwitchRouteName;

  /// The name of the "redirectTo" query parameter, used for "main redirection".
  ///
  /// Not null if [isMainRedirectionEnabled] is true (null otherwise).
  ///
  /// NB : When having two nested `VxRouteSwitcher`s in the route-tree which
  /// both have "main redirection" enabled, they should have a different
  /// "redirecTo" query parameters.
  final String? redirectToQueryParam;

  /// This should be provided if this [VxRouteSwitcher] is nested inside another
  /// [VxRouteSwitcher].
  ///
  /// This list represents the parent VxRouteSwitcher(s), from top to bottom.
  /// Each [ParentRouteSwitcher]
  ///
  ///
  /// This serves two purposes :
  /// - The child's provider won't be accessed unless the state of the parent
  ///   [VxRouteSwitcher]s are matching the route containing the child
  ///   [VxRouteSwitcher].
  /// - The "_beforeEnterAndUpdate" redirection logic is dealt with at the right
  ///   level.
  ///
  /// > NB: This is the result of an internal limitation of vrouter. It could
  /// > have been avoided if there was a way to access the parent
  /// > VxRouteSwitchers from within the child VxRouteSwitcher. But unlike the
  /// > widget-tree, the route-tree doesn't have something like a BuildContext
  /// > to access ancestors.
  /// >
  /// > So code duplication is to be expected (Especially for
  /// > [ParentRouteSwitcher.isStateMatchingChild]).
  ///
  final List<ParentRouteSwitcher>? parentRouteSwitchers;

  final RouteRef routeRef;

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

  /// When the "redirectTo" query parameter is invalid, we flag it for deletion
  /// and we navigate again.
  void _handleInvalidRedirectToQueryParam(
      VRedirector vRedirector, VRouterData newVRouterData) {
    final invalidUri = Uri.parse(newVRouterData.url!);

    //We flag for deletion the invalid redirect-to query param
    final queryParams = Map<String, String>.from(invalidUri.queryParameters);
    queryParams.update(
        redirectToQueryParam!, (_) => StickyQueryParam.deleteFlag);

    final validUri = invalidUri.replace(
      queryParameters: queryParams,
    );

    logger.w('''
    Invalid "redirectTo" query parameter "$redirectToQueryParam".
    Value : ${newVRouterData.queryParameters[redirectToQueryParam]}
    Redirecting to url : ${validUri.toString()}
    ''');

    vRedirector.to(validUri.toString());
  }

  /// Navigates to the switchRoute represented by [matchedRouteDetails], using
  /// the provided [vRouterNavigator].
  ///
  /// The [stickyQueryParams] are kept during navigation.
  void _navigate({
    required VRouterNavigator vRouterNavigator,
    required MatchedRouteDetails<RouteData> matchedRouteDetails,
    required Map<String, String> stickyQueryParams,
    required String debugSource,
  }) {
    logger.i('''
    Navigating : $debugSource
    Destination : ${matchedRouteDetails.switchRouteName}
    ''');

    final matchedSwitchRoute =
        _getSwitchRouteFromName(matchedRouteDetails.switchRouteName);

    /// The order of these spreads ensure that the stickyQueryParams will
    /// overwrite any similar stickyQueryParam in the matchedRouteDetails.
    final queryParameters = {
      ...matchedRouteDetails.queryParameters,
      ...stickyQueryParams,
    };

    matchedSwitchRoute.routeInfoInstance._navigate(
      routeRef,
      vRouterNavigator,
      data: matchedRouteDetails.routeData,
      pathParameters: matchedRouteDetails.pathParameters,
      queryParameters: queryParameters,
      historyState: matchedRouteDetails.historyState,
      hash: matchedRouteDetails.hash,
      isReplacement: matchedRouteDetails.isReplacement,
    );
  }

  bool _canProceed() {
    final parentRouteSwitchers = this.parentRouteSwitchers;
    if (parentRouteSwitchers == null) {
      return true;
    }

    for (final parent in parentRouteSwitchers) {
      if (!parent.isStateMatchingChild(routeRef)) {
        return false;
      }
    }
    return true;
  }

  /// BeforeEnter and BeforeUpdate :
  ///
  /// 1. We verify if the switchRoute we want to access is the matched
  ///    switchRoute
  /// 2. If no (shouldRedirect == true) : We redirect to the matched
  ///    switchRoute. Note that :
  ///    - (2a) The sticky query parameters are persisted.
  ///    - (2b) If "main redirection" is enabled, and we are redirecting from a
  ///       main switchRoute to another switchRoute : We store the previousUrl
  ///       in the redirectTo query parameter
  /// 3. If yes (shouldRedirect == false) :
  ///    - (3a) We verify if routeData is missing. If so, we call
  ///      [VxSwitchRoute._setRouteData] to set the missing routeData (that is
  ///      contained in `matchedRouteDetails`)
  ///    - (3b) If "main redirection" is enabled, and we are entering the main
  ///      switchRoute, we check if the redirectTo query parameter contains any
  ///      url. If yes, we navigate to it, and we set the query parameter's
  ///      value to [StickyQueryParam.deleteFlag]. It will later be removed by TODO
  ///
  /// NB: You can encode a string multiple times with the percent encoding and
  /// get the original value by decoding it the same amount of times. So there's
  /// nothing to worry about here. (Source :
  /// https://stackoverflow.com/a/2433211/13297133)
  ///
  /// NB no need to encode/decode, it is automatically done

  Future<void> _beforeEnterAndUpdate(VRedirector vRedirector) async {
    if (!_canProceed()) {
      return;
    }

    /// 1.
    final newVRouterData = vRedirector.newVRouterData!;
    final newSwitchRoute = _getSwitchRouteFromVRouterData(newVRouterData);

    final state = routeRef.read(provider);
    final matchedRouteDetails =
        mapStateToSwitchRoute(state, vRedirector.newVRouterData!);

    final shouldRedirect = newSwitchRoute.routeInfoInstance.name !=
        matchedRouteDetails.switchRouteName;

    /// 2.
    if (shouldRedirect) {
      /// (2b)
      final newVRouterDataUri = Uri.parse(newVRouterData.url!);

      final redirectToUrl = (isMainRedirectionEnabled &&
              newSwitchRoute.routeInfoInstance.name == mainSwitchRouteName)
          ? StickyQueryParam.removeStickyQueryParams(newVRouterDataUri)
              .toString()
          : null;

      /// (2a)
      final stickyQueryParams =
          StickyQueryParam.getStickyQueryParams(newVRouterData.queryParameters);

      if (redirectToUrl != null) {
        stickyQueryParams.update(
          redirectToQueryParam!,
          (_) => redirectToUrl,
          ifAbsent: () => redirectToUrl,
        );
      }

      print('''
      url : ${newVRouterData.url}
      newSwitchRouteName : ${newSwitchRoute.routeInfoInstance.name}
      mainSwitchRouteName : $mainSwitchRouteName
      sticky query params : $stickyQueryParams
      redirectTo : $redirectToUrl
      ''');

      _navigate(
        debugSource: '_beforeEnterAndUpdate (1)',
        vRouterNavigator: vRedirector,
        matchedRouteDetails: matchedRouteDetails,
        stickyQueryParams: stickyQueryParams,
      );

      /// Not awaiting this on purpose.
      newSwitchRoute.afterRedirect();

      return;
    }

    /// 3.

    /// (3a)
    final routeDataOption = routeRef
        .read(newSwitchRoute.routeInfoInstance._routeDataOptionProvider);

    if (routeDataOption.isNone()) {
      newSwitchRoute.routeInfoInstance._setRouteData(
        routeRef,
        data: matchedRouteDetails.routeData,
      );
    }

    /// (3b)
    if (isMainRedirectionEnabled &&
        newSwitchRoute.routeInfoInstance.name == mainSwitchRouteName) {
      final redirectToUrl =
          newVRouterData.queryParameters[redirectToQueryParam];
      if (redirectToUrl == null) {
        return;
      }

      if (redirectToUrl == StickyQueryParam.deleteFlag) {
        return;
      }

      /// We ensure that the redirectToUrl is valid.
      ///
      /// This will be null if the url is invalid.
      final redirectToUri = Uri.tryParse(redirectToUrl);

      if (redirectToUri == null) {
        _handleInvalidRedirectToQueryParam(vRedirector, newVRouterData);
        return;
      }

      /// We only keep the normal queryParameters of the redirectToUri
      final redirectToUriQueryParams =
          StickyQueryParam.getNormalQueryParams(redirectToUri.queryParameters);

      /// We flag the [redirectToQueryParam] for deletion, while keeping
      /// the other sticky query parameters.
      final stickyQueryParams =
          StickyQueryParam.getStickyQueryParams(newVRouterData.queryParameters);

      stickyQueryParams.update(
        redirectToQueryParam!,
        (_) => StickyQueryParam.deleteFlag,
      );

      final uri = redirectToUri.replace(
        queryParameters: {...redirectToUriQueryParams, ...stickyQueryParams},
      );

      vRedirector.to(uri.toString());
      logger.i('''
        Redirecting to the url inside the redirectToQueryParam "$redirectToQueryParam".
        Destination : ${uri.toString()}
        ''');
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
  /// ---
  /// For the redirect-to : We simply pass around the redirect-to query param
  /// when switching (if existant).

  void _onStateChanged(
      BuildContext context, WidgetRef ref, T? previousState, T newState) {
    final currentSwitchRoute = _getSwitchRouteFromVRouterData(context.vRouter);

    final matchedRouteDetails =
        mapStateToSwitchRoute(newState, context.vRouter);
    final matchedSwitchRoute =
        _getSwitchRouteFromName(matchedRouteDetails.switchRouteName);

    final shouldSwitch = currentSwitchRoute.routeInfoInstance.name !=
        matchedRouteDetails.switchRouteName;

    final stickyQueryParams =
        StickyQueryParam.getStickyQueryParams(context.vRouter.queryParameters);

    if (shouldSwitch) {
      _navigate(
        debugSource: '_onStateChanged (2)',
        vRouterNavigator: context.vRouter,
        matchedRouteDetails: matchedRouteDetails,
        stickyQueryParams: stickyQueryParams,
      );

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
