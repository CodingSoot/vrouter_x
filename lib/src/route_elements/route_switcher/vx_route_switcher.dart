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
import 'package:vrouter_x/src/route_elements/route_switcher/utils.dart';

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
    this.parentRouteSwitchers = const [],
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
      switchRoute.isVxRouteSwitcherNested = parentRouteSwitchers.isNotEmpty;
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
    this.parentRouteSwitchers = const [],
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
      switchRoute.isVxRouteSwitcherNested = parentRouteSwitchers.isNotEmpty;
    }
  }

  /// See [VNester.buildTransition]
  final Widget Function(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child)? buildTransition;

  /// See [VNester.aliases]
  final List<String> aliases;

  /// See [VNester.fullscreenDialog]
  final bool fullscreenDialog;

  /// Whether the "main redirection" is enabled.
  ///
  /// ⚠️ When this is true, both [mainSwitchRouteName] and
  /// [redirectToQueryParam] are not null. Otherwise, both are null.
  ///
  final bool isMainRedirectionEnabled;

  /// See [VNester.key]
  final LocalKey? key;

  /// This is the name of your main switchRoute, used for "main redirection".
  ///
  /// Not null if [isMainRedirectionEnabled] is true (null otherwise).
  final String? mainSwitchRouteName;

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

  /// See [VNester.name]
  final String? name;

  /// See [VNester.navigatorKey]
  final GlobalKey<NavigatorState>? navigatorKey;

  /// This should only be provided if this [VxRouteSwitcher] is nested inside
  /// another [VxRouteSwitcher].
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
  /// > So code duplication is to be expected (Especially for the callback
  /// > [ParentRouteSwitcher.isStateMatchingChild]).
  ///
  final List<ParentRouteSwitcher> parentRouteSwitchers;

  /// See [VNester.path]
  final String? path;

  /// The provider you want to listen to.
  final ProviderBase<T> provider;

  /// The name of the "redirectTo" query parameter, used for "main redirection".
  ///
  /// Not null if [isMainRedirectionEnabled] is true (null otherwise).
  ///
  /// NB : When having two nested `VxRouteSwitcher`s in the route-tree which
  /// both have "main redirection" enabled, they should have a different
  /// "redirecTo" query parameters.
  final String? redirectToQueryParam;

  /// See [VNester.reverseTransitionDuration]
  final Duration? reverseTransitionDuration;

  final RouteRef routeRef;

  /// The list of routes you want to automatically switch between.
  final List<VxSwitchRoute> switchRoutes;

  /// See [VNester.transitionDuration]
  final Duration? transitionDuration;

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
      _navigateToMatchedRoute(
        vRouterNavigator: context.vRouter,
        matchedRouteDetails: matchedRouteDetails,
        stickyQueryParams: stickyQueryParams,
        debugSource: '_onStateChanged',
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

  /// BeforeEnter and BeforeUpdate :
  /// 1. We check if this [VxRouteSwitcher] is currently being matched in all
  ///    its parents' [VxRouteSwitcher]s. If not, we return, so that the
  ///    _beforeEnterAndUpdate of the right parent handles things.
  /// 2. We verify if the switchRoute we want to access is the matched
  ///    switchRoute
  /// 3. If no (shouldRedirect == true) : We redirect to the matched
  ///    switchRoute.
  /// 4. If yes (shouldRedirect == false) :
  ///    - (a) We verify if routeData is missing. If so, we call
  ///      [VxSwitchRoute._setRouteData] to set the missing routeData (that is
  ///      contained in `matchedRouteDetails`)
  ///    - (b) If "main redirection" is enabled, and we are entering the main
  ///      switchRoute, we check if the redirectTo query parameter contains any
  ///      url. If yes, we consume it.
  ///
  /// > NB : There is no need to manually encode/decode query parameters, as it
  /// > is automatically done for us.

  Future<void> _beforeEnterAndUpdate(VRedirector vRedirector) async {
    /// 1.
    if (!_isVxRouteSwitcherMatched()) {
      return;
    }

    /// 2.
    final newVRouterData = vRedirector.newVRouterData!;
    final newSwitchRoute = _getSwitchRouteFromVRouterData(newVRouterData);

    final state = routeRef.read(provider);
    final matchedRouteDetails =
        mapStateToSwitchRoute(state, vRedirector.newVRouterData!);

    final shouldRedirect = newSwitchRoute.routeInfoInstance.name !=
        matchedRouteDetails.switchRouteName;

    /// 3.
    if (shouldRedirect) {
      _redirectToMatchedRoute(
        vRedirector: vRedirector,
        currentSwitchRoute: newSwitchRoute,
        matchedRouteDetails: matchedRouteDetails,
      );

      return;
    }

    /// 4.

    /// (a)
    final routeDataOption = routeRef
        .read(newSwitchRoute.routeInfoInstance._routeDataOptionProvider);

    if (routeDataOption.isNone()) {
      newSwitchRoute.routeInfoInstance._setRouteData(
        routeRef,
        data: matchedRouteDetails.routeData,
      );
    }

    /// (b)
    if (isMainRedirectionEnabled &&
        newSwitchRoute.routeInfoInstance.name == mainSwitchRouteName) {
      _consumeRedirectToQueryParam(vRedirector: vRedirector);
    }
  }

  /// Whether this [VxRouteSwitcher] is currently being matched in all its
  /// parents' [VxRouteSwitcher]s.
  ///
  /// This is always true if this [VxRouteSwitcher] has no parents.
  bool _isVxRouteSwitcherMatched() {
    final parentRouteSwitchers = this.parentRouteSwitchers;
    if (parentRouteSwitchers.isEmpty) {
      return true;
    }

    for (final parent in parentRouteSwitchers) {
      if (!parent.isStateMatchingChild(routeRef)) {
        return false;
      }
    }
    return true;
  }

  /// Redirects from [currentSwitchRoute] to the matched switchRoute represented
  /// by [matchedRouteDetails]. This should be called when the switchRoute we
  /// entered is not the matched switchRoute.
  ///
  /// After the redirection, we call the currentSwitchRoute's method
  /// [VxSwitchRoute.afterRedirect].
  ///
  /// Note that :
  /// - (A) If "main redirection" is enabled, and we are redirecting from a main
  ///    switchRoute : We store the previousUrl in the redirectTo query
  ///    parameter
  /// - (B) All sticky query parameters are persisted.
  /// - (C) We call the matched switchRoute's `afterRedirect`
  void _redirectToMatchedRoute({
    required VRedirector vRedirector,
    required VxSwitchRoute<RouteData> currentSwitchRoute,
    required MatchedRouteDetails<RouteData> matchedRouteDetails,
  }) {
    assert(
        currentSwitchRoute.routeInfoInstance.name !=
            matchedRouteDetails.switchRouteName,
        "The currentSwitchRoute is already the matched switchRoute.");

    final newVRouterData = vRedirector.newVRouterData!;

    /// (A)
    final newVRouterDataUri = Uri.parse(newVRouterData.url!);

    final redirectToUrl = (isMainRedirectionEnabled &&
            currentSwitchRoute.routeInfoInstance.name == mainSwitchRouteName)
        ? StickyQueryParam.removeStickyQueryParams(newVRouterDataUri).toString()
        : null;

    /// (B)
    final stickyQueryParams =
        StickyQueryParam.getStickyQueryParams(newVRouterData.queryParameters);

    if (redirectToUrl != null) {
      stickyQueryParams.update(
        redirectToQueryParam!,
        (_) => redirectToUrl,
        ifAbsent: () => redirectToUrl,
      );
    }

    _navigateToMatchedRoute(
      vRouterNavigator: vRedirector,
      matchedRouteDetails: matchedRouteDetails,
      stickyQueryParams: stickyQueryParams,
      debugSource: '_beforeEnterAndUpdate (1)',
    );

    /// (C)
    /// Not awaiting this on purpose (so as not to disturb the navigation cycle).
    currentSwitchRoute.afterRedirect();
  }

  /// This checks if the [redirectToQueryParam] holds any url. If so, it
  /// navigates to it, and flags the [redirectToQueryParam] for deletion.
  ///
  /// In details :
  ///
  /// 1. We first check if the [redirectToQueryParam] holds any url.
  /// 2. If yes, we check if it's a valid url. For it to be valid :
  ///   - It must be a valid url.
  ///   - It must not contain any sticky query parameter.
  /// 3. If it's invalid we call [_handleInvalidRedirectToQueryParam]
  /// 4. If it's valid, we flag the [redirectToQueryParam] for deletion, while
  ///    keeping the other sticky query parameters.
  ///
  void _consumeRedirectToQueryParam({
    required VRedirector vRedirector,
  }) {
    final newVRouterData = vRedirector.newVRouterData!;
    final redirectToUrl = newVRouterData.queryParameters[redirectToQueryParam];

    /// 1.
    if (redirectToUrl == null || redirectToUrl == StickyQueryParam.deleteFlag) {
      return;
    }

    /// 2.

    // This will be null if the url is not a valid uri.
    final redirectToUri = Uri.tryParse(redirectToUrl);

    final isValid = redirectToUri != null &&
        StickyQueryParam.getStickyQueryParams(redirectToUri.queryParameters)
            .isEmpty;

    /// 3.
    if (!isValid) {
      _handleInvalidRedirectToQueryParam(vRedirector, newVRouterData);
      return;
    }

    /// 4.
    final stickyQueryParams =
        StickyQueryParam.getStickyQueryParams(newVRouterData.queryParameters);

    stickyQueryParams.update(
      redirectToQueryParam!,
      (_) => StickyQueryParam.deleteFlag,
    );

    final uri = redirectToUri.replace(
      queryParameters: {
        ...redirectToUri.queryParameters,
        ...stickyQueryParams,
      },
    );

    vRedirector.to(uri.toString());

    logger.i('''
        Redirecting to the url inside the redirectToQueryParam "$redirectToQueryParam".
        Destination : ${uri.toString()}
        ''');
  }

  /// When the "redirectTo" query parameter is invalid, we flag it for deletion
  /// and we navigate again.
  void _handleInvalidRedirectToQueryParam(
      VRedirector vRedirector, VRouterData newVRouterData) {
    final invalidUri = Uri.parse(newVRouterData.url!);

    //We flag for deletion the invalid redirect-to query param
    final queryParams = {...invalidUri.queryParameters};
    queryParams.update(
      redirectToQueryParam!,
      (_) => StickyQueryParam.deleteFlag,
    );

    final validUri = invalidUri.replace(
      queryParameters: queryParams,
    );

    vRedirector.to(validUri.toString());

    logger.w('''
    Invalid "redirectTo" query parameter "$redirectToQueryParam".
    Value : ${newVRouterData.queryParameters[redirectToQueryParam]}
    Redirecting to url : ${validUri.toString()}
    ''');
  }

  /// Navigates to the matched switchRoute represented by [matchedRouteDetails],
  /// using the provided [vRouterNavigator].
  ///
  /// The [stickyQueryParams] are persisted during navigation.
  void _navigateToMatchedRoute({
    required VRouterNavigator vRouterNavigator,
    required MatchedRouteDetails<RouteData> matchedRouteDetails,
    required Map<String, String> stickyQueryParams,
    required String debugSource,
  }) {
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

    logger.i('''
    Navigating : $debugSource
    Destination : ${matchedRouteDetails.switchRouteName}
    ''');
  }

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
  /// In other words, it returns the [VxSwitchRoute] which is included in the
  /// [VRouteElement]s stack represented by [vRouterData].
  ///
  /// > NB: This works even when we are in a subroute of a [VxSwitchRoute].
  ///
  /// Throws a [RouteNotFoundError] if no [VxSwitchRoute] is found in the stack.
  VxSwitchRoute<RouteData> _getSwitchRouteFromVRouterData(
      VRouterData vRouterData) {
    return switchRoutes.firstWhere(
      (route) => vRouterData.names.contains(route.routeInfoInstance.name),
      orElse: () => throw RouteNotFoundError(),
    );
  }
}
