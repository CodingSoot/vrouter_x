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
import 'package:vrouter_x/src/widgets_route_elements/sticky_query_params/sticky_query_param.dart';
import 'package:vrouter_x/src/widgets_route_elements/sticky_query_params/sticky_query_params_scope.dart';

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
        redirectQueryParamName = null,
        assert(
            switchRoutes
                    .map((route) => route.routeInfoInstance.name)
                    .toSet()
                    .length ==
                switchRoutes.length,
            "The switchRoutes should have unique names.");

  /// Use this constructor when you want to enable "Main redirection".
  ///
  /// ### What is "main redirection" ?
  ///
  /// When you navigate to a **url** that points to a route inside your main
  /// switchRoute, but the matched switchRoute is not the main switchRoute, you
  /// are redirected to the matched switchRoute.
  ///
  /// In this situation, that **url** is stored inside the "redirect" query
  /// parameter, which will be persisted until the state matches your main
  /// switchRoute. When that happens, you are automatically navigated to that
  /// **url**, and the "redirect" query parameter is deleted.
  ///
  /// > NB : The "redirect" query parameter is a sticky query parameter, meaning
  /// > that internally, a [StickyQueryParamsScope] is used to automatically
  /// > persist it in all the subroutes of this [VxRouteSwitcher]. So you don't
  /// > need to manually pass it around when navigating.
  VxRouteSwitcher.withMainRedirection(
    this.routeRef, {
    required this.path,
    required this.switchRoutes,
    required this.provider,
    required this.mapStateToSwitchRoute,
    required this.mainSwitchRouteName,
    required this.redirectQueryParamName,
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
            mainSwitchRouteName != null && redirectQueryParamName != null,
            "mainSwitchRouteName and redirectQueryParamName should not be null "
            "when using VxRouteSwitcher.withMainRedirection."),
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
            "The switchRoutes should have unique names.");

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
  /// [redirectQueryParamName] are not null. Otherwise, both are null.
  final bool isMainRedirectionEnabled;

  /// See [VNester.key]
  final LocalKey? key;

  /// This is the name of your main switchRoute, used for "main redirection".
  ///
  /// Not null if [isMainRedirectionEnabled] is true (null otherwise).
  final String? mainSwitchRouteName;

  /// The name of the "redirect" query parameter, used for "main redirection".
  ///
  /// Not null if [isMainRedirectionEnabled] is true (null otherwise).
  ///
  /// NB : When having multiple `VxRouteSwitcher`s in the route-tree which have
  /// "main redirection" enabled, they should each have a different
  /// [redirectQueryParamName].
  final String? redirectQueryParamName;

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
  ///
  /// This serves three purposes :
  /// - The child's provider won't be accessed unless the state of the parent
  ///   [VxRouteSwitcher]s are matching the route containing the child
  ///   [VxRouteSwitcher].
  /// - The "_beforeEnterAndUpdate" redirection logic is dealt with at the right
  ///   level (using [_isVxRouteSwitcherMatched]).
  /// - The "redirect" query params of the parent [VxRouteSwitcher]s are
  ///   preserved during redirection.
  ///
  /// > NB: This is the result of an internal limitation of vrouter. It could
  /// > have been avoided if there was a way to access the parent
  /// > VxRouteSwitchers from within the child VxRouteSwitcher. But unlike the
  /// > widget-tree, the route-tree doesn't have something like a BuildContext
  /// > to access ancestors.
  /// >
  /// > So code duplication is to be expected (Especially for the callback
  /// > [ParentRouteSwitcher.isStateMatchingChild]).
  final List<ParentRouteSwitcher> parentRouteSwitchers;

  /// See [VNester.path]
  final String? path;

  /// The provider you want to listen to.
  final ProviderBase<T> provider;

  /// See [VNester.reverseTransitionDuration]
  final Duration? reverseTransitionDuration;

  final RouteRef routeRef;

  /// The list of routes you want to automatically switch between.
  final List<VxSwitchRoute> switchRoutes;

  /// See [VNester.transitionDuration]
  final Duration? transitionDuration;

  /// Not null if [isMainRedirectionEnabled] is true (null otherwise).
  StickyConfig? get stickyConfig => redirectQueryParamName != null
      ? StickyConfig.exact(name: redirectQueryParamName!, deleteFlag: '_')
      : null;

  /// Returns the names of the query parameters of the parents
  /// [parentRouteSwitchers].
  List<String> get parentsRedirectQueryParamsNames => parentRouteSwitchers
      .map((parent) => parent.redirectQueryParamName)
      .whereNotNull()
      .toList();

  @override
  List<VRouteElement> buildRoutes() {
    final routes = [
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

    return isMainRedirectionEnabled
        ? [
            StickyQueryParamsScope(
              stickyConfigs: [
                stickyConfig!,
              ],
              stackedRoutes: routes,
            ),
          ]
        : routes;
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
  /// For the "redirect" query params : We simply pass around the "redirect"
  /// query params of this [VxSwitchRoute] and its parents
  /// [parentRouteSwitchers] (if existant). We can skip this step since they can
  /// be persisted by the [StickyQueryParamsScope], but we're doing it here for
  /// optimization.

  void _onStateChanged(
      BuildContext context, WidgetRef ref, T? previousState, T newState) {
    final currentSwitchRoute = _getSwitchRouteFromVRouterData(context.vRouter);

    final matchedRouteDetails =
        mapStateToSwitchRoute(newState, context.vRouter);
    final matchedSwitchRoute =
        _getSwitchRouteFromName(matchedRouteDetails.switchRouteName);

    final shouldSwitch = currentSwitchRoute.routeInfoInstance.name !=
        matchedRouteDetails.switchRouteName;

    final redirectQueryParams =
        _getRedirectQueryParams(context.vRouter.queryParameters);

    if (shouldSwitch) {
      _navigateToMatchedRoute(
        vRouterNavigator: context.vRouter,
        matchedRouteDetails: matchedRouteDetails,
        redirectQueryParams: redirectQueryParams,
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
  ///      switchRoute, we check if the redirect query parameter contains any
  ///      url. If yes, we consume it.
  ///
  /// > NB : There is no need to manually encode/decode query parameters, as it
  /// > is automatically done for us.
  ///
  /// ### Important remark :
  ///
  /// Due to the limitation mentioned in
  /// [StickyQueryParamsScope._beforeEnterAndUpdate], we don't rely on
  /// StickyQueryParamsScope to persist the redirectQueryParams that may be
  /// added in the middle of beforeEnter/Update's vRedirector navigations.
  /// Instead, we manually persist them (= we manually include them during
  /// navigation).
  ///
  /// However, [StickyQueryParamsScope] is effectively used to persist the
  /// redirectQueryParams in all other cases (ex : When the user navigates to a
  /// new page while omitting the redirectQueryParams)
  ///
  /// NB : We'll be manually persisting both this [VxRouteSwitcher]'s
  /// redirectQueryParam and its parents [parentRouteSwitchers]'
  /// redirectQueryParams. (After all, it's one long beforeEnter/Update's
  /// redirection chain, so a redirectQueryParam added by a parent should also
  /// be manually persisted).

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
      _consumeRedirectQueryParam(vRedirector: vRedirector);
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

  /// Redirects from [currentSwitchRoute] to the matched switchRoute
  /// [matchedRouteDetails]. This should be called when the switchRoute we
  /// entered is not the matched switchRoute.
  ///
  /// After the redirection, we call the currentSwitchRoute's method
  /// [VxSwitchRoute.afterRedirect].
  ///
  /// Note that :
  /// - (A) If "main redirection" is enabled, and we are redirecting from a main
  ///   switchRoute : We store the previousUrl in the "redirect" query parameter
  /// - (B) The "redirect" query parameters of this [VxRouteSwitcher] and its
  ///   parents are persisted.
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

    /// We remove the redirectQueryParams of this [VxRouteSwitcher] and its
    /// parents.
    final redirectToUrl = (isMainRedirectionEnabled &&
            currentSwitchRoute.routeInfoInstance.name == mainSwitchRouteName)
        ? _removeRedirectQueryParams(newVRouterDataUri).toString()
        : null;

    /// (B)
    final redirectQueryParams =
        _getRedirectQueryParams(newVRouterData.queryParameters);

    if (redirectToUrl != null) {
      redirectQueryParams.update(
        redirectQueryParamName!,
        (value) => redirectToUrl,
        ifAbsent: () => redirectToUrl,
      );
    }

    _navigateToMatchedRoute(
      vRouterNavigator: vRedirector,
      matchedRouteDetails: matchedRouteDetails,
      redirectQueryParams: redirectQueryParams,
      debugSource: '_beforeEnterAndUpdate',
    );

    /// (C)
    /// Not awaiting this on purpose (so as not to disturb the navigation cycle).
    currentSwitchRoute.afterRedirect();
  }

  /// This checks if the [redirectQueryParamName] holds any url. If so, it
  /// navigates to it, and flags the [redirectQueryParamName] for deletion.
  ///
  /// In details :
  ///
  /// 1. We first check if the [redirectQueryParamName] holds any url.
  /// 2. If yes, we check if it's a valid url. For it to be valid :
  ///    - It must be a valid url.
  ///    - It must be an absolute url.
  ///    - It must not contain a redirectQueryParam of this [VxRouteSwitcher] or
  ///      its parents.
  /// 3. Then :
  ///    - (a) If it's invalid we call [_handleInvalidRedirectQueryParam]
  ///    - (b) If it's valid, we flag the [redirectQueryParamName] for deletion,
  ///      while keeping the parents' redirectQueryParams
  ///
  void _consumeRedirectQueryParam({
    required VRedirector vRedirector,
  }) {
    assert(isMainRedirectionEnabled);

    final newVRouterData = vRedirector.newVRouterData!;
    final redirectToUrl =
        newVRouterData.queryParameters[redirectQueryParamName];

    /// 1.
    if (redirectToUrl == null || redirectToUrl == stickyConfig!.deleteFlag) {
      return;
    }

    /// 2.
    // This will be null if the url is not a valid uri.
    final redirectToUri = Uri.tryParse(redirectToUrl);

    final isValid = redirectToUri != null &&
        redirectToUri.toString().startsWith('/') &&
        _getRedirectQueryParams(redirectToUri.queryParameters).isEmpty;

    /// 3.(a)
    if (!isValid) {
      _handleInvalidRedirectQueryParam(vRedirector, newVRouterData);
      return;
    }

    /// 3.(b)
    final redirectQueryParams =
        _getRedirectQueryParams(newVRouterData.queryParameters);

    redirectQueryParams.update(
      redirectQueryParamName!,
      (value) => stickyConfig!.deleteFlag,
    );

    final uri = redirectToUri.replace(
      queryParameters: {
        ...redirectToUri.queryParameters,
        ...redirectQueryParams,
      },
    );

    vRedirector.to(uri.toString());

    logger.i('''
        Redirecting to the url inside the redirectQueryParam "$redirectQueryParamName".
        Destination : ${uri.toString()}
        ''');
  }

  /// When the "redirect" query parameter is invalid, we flag it for deletion
  /// and we navigate again.
  void _handleInvalidRedirectQueryParam(
      VRedirector vRedirector, VRouterData newVRouterData) {
    assert(isMainRedirectionEnabled);

    final invalidUri = Uri.parse(newVRouterData.url!);

    //We flag for deletion the invalid redirect query param
    final queryParams = {...invalidUri.queryParameters};
    queryParams.update(
      redirectQueryParamName!,
      (_) => stickyConfig!.deleteFlag,
    );

    final validUri = invalidUri.replace(
      queryParameters: queryParams,
    );

    vRedirector.to(validUri.toString());

    logger.w('''
    Invalid "redirect" query parameter "$redirectQueryParamName".
    Value : ${newVRouterData.queryParameters[redirectQueryParamName]}
    Redirecting to url : ${validUri.toString()}
    ''');
  }

  /// Navigates to the matched switchRoute [matchedRouteDetails],
  /// using the provided [vRouterNavigator].
  ///
  /// The [redirectQueryParams] are persisted during navigation.
  void _navigateToMatchedRoute({
    required VRouterNavigator vRouterNavigator,
    required MatchedRouteDetails<RouteData> matchedRouteDetails,
    required Map<String, String> redirectQueryParams,
    required String debugSource,
  }) {
    final matchedSwitchRoute =
        _getSwitchRouteFromName(matchedRouteDetails.switchRouteName);

    /// We ensure the matchedRouteDetails queryParameters don't contain
    /// a redirectQueryParam. (As this could lead to infinite loops.)
    final matchedRouteQueryParams = {...matchedRouteDetails.queryParameters};

    final queryParamsToRemove =
        _getRedirectQueryParams(matchedRouteQueryParams);

    matchedRouteQueryParams
        .removeWhere((key, value) => queryParamsToRemove.containsKey(key));

    final updatedQueryParams = <String, String>{
      ...matchedRouteQueryParams,
      ...redirectQueryParams,
    };

    matchedSwitchRoute.routeInfoInstance._navigate(
      routeRef,
      vRouterNavigator,
      data: matchedRouteDetails.routeData,
      pathParameters: matchedRouteDetails.pathParameters,
      queryParameters: updatedQueryParams,
      historyState: matchedRouteDetails.historyState,
      hash: matchedRouteDetails.hash,
      isReplacement: matchedRouteDetails.isReplacement,
    );

    logger.i('''
    Navigating : $debugSource
    Destination : ${matchedRouteDetails.switchRouteName}
    RedirectQueryParams : $redirectQueryParams
    ''');
  }

  /// Returns the redirectQueryParams of this [VxRouteSwitcher] and its
  /// parents [parentRouteSwitchers], among the provided [queryParameters]
  Map<String, String> _getRedirectQueryParams(
      Map<String, String> queryParameters) {
    return queryParameters.filterWithKey((key, value) =>
        key == redirectQueryParamName ||
        parentsRedirectQueryParamsNames.contains(key));
  }

  /// Returns the [uri] without the redirect query parameters of this
  /// [VxRouteSwitcher] nor its parents [parentRouteSwitchers].
  Uri _removeRedirectQueryParams(Uri uri) {
    final filteredQueryParams = uri.queryParameters.filterWithKey(
        (key, value) =>
            key != redirectQueryParamName &&
            !parentsRedirectQueryParamsNames.contains(key));

    return uri.replace(
      queryParameters: filteredQueryParams,
    );
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
