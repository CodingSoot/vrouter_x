import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/route_elements/route_elements.dart';
import 'package:vrouter_x/src/utils/vx_utils.dart';
import 'package:vrouter_x/src/widgets_route_elements/common/initial_go_to_resolver.dart';
import 'package:vrouter_x/src/widgets_route_elements/common/initial_pop_to_resolver.dart';
import 'package:vrouter_x/src/widgets_route_elements/common/vx_tab.dart';

/// A [VRouteElement] that allows you to easily setup a [TabBarView] where each
/// tab is a different router with its own stack.
///
/// It implements several features including :
/// - Preserved state for each tab (Optional, should use
///   [AutomaticKeepAliveClientMixin])
/// - Lazily loaded tabs
/// - Seamless integration with Flutter's [TabBarView]
/// - Possibility to stack routes on top of the whole [TabBarView]
///
/// NB :
///  - The widget of each tab route should mixin [AutomaticKeepAliveClientMixin]
///    if you want to keep the state.

class VxTabBar extends VRouteElementBuilder {
  VxTabBar({
    required this.path,
    required this.initialGoToResolver,
    required this.initialPopToResolver,
    required this.tabsRoutes,
    required this.initialTabIndex,
    required this.tabBarViewBuilder,
    this.stackedRoutes,
    this.stackedWidgetBuilder = VxTabBar.defaultStackedWidgetBuilder,
    this.buildWrapper,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.buildTransition,
    this.key,
    this.name,
    this.aliases = const [],
    this.navigatorKey,
    this.fullscreenDialog = false,
  });

  /// See [VNester.path].
  ///
  /// NB: Like for a [VNester], the [VxTabBar] will only display if a
  /// nestedRoute matches.
  final String path;

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

  /// When the user navigates to a tab using the swipe gesture, and that tab
  /// hasn't been opened before, we don't know what path parameters to pass-in
  /// to that freshly initialized tab.
  ///
  /// In those situations, this resolver is used to determine those path
  /// parameters (as well as other optional parameters such as the query
  /// parameters, hash...)
  final InitialGoToResolver initialGoToResolver;

  /// When popping from a stackedRoute, we are taken back to the last visited
  /// tab.
  ///
  /// But what if we navigated directly to the stackedRoute and never visited
  /// any tab before ? In this situation :
  ///
  /// 1. We pop back to the tab of index [initialTabIndex]
  /// 2. This resolver is used to determine what path parameters to pass-in to
  ///    this tab. (as well as other optional parameters such as the query
  ///    parameters, hash...)
  final InitialPopToResolver initialPopToResolver;

  /// This is the index of the initial tab. It is the tab we pop back from the
  /// stackedRoute, in the case we have never visited any tab before.
  ///
  /// NB: This doesn't control the tab that will be opened when first displaying
  /// the VxTabsScaffold. The initially opened tab only depends on the path you
  /// initially navigate to. (Same behaviour as a VNester with its
  /// nestedRoutes).
  final int initialTabIndex;

  /// The [VRouteElement]s of the tabs
  final List<VxSimpleRoute> tabsRoutes;

  /// The [VRouteElement]s of the routes that will be stacked on top of the Tabs
  /// (Optional)
  final List<VxSimpleRoute>? stackedRoutes;

  /// Builder method for the TabBarView.
  ///
  /// Example :
  ///
  /// ```dart
  /// tabBarViewBuilder: (context, vRouterData, tabController, children) =>
  ///       TabBarView(
  ///     controller: tabController,
  ///     children: children,
  ///   ),
  /// ```
  final Widget Function(BuildContext context, VRouterData vRouterData,
      TabController tabController, List<Widget> children) tabBarViewBuilder;

  /// Builder method for the widget of the [stackedRoutes].
  ///
  /// Defaults to [VxTabBar.defaultStackedWidgetBuilder]
  final Widget Function(
          BuildContext context, VRouterData vRouterData, Widget child)
      stackedWidgetBuilder;

  static Widget defaultStackedWidgetBuilder(
          BuildContext context, VRouterData vRouterData, Widget child) =>
      child;

  /// This Builder method wraps both [tabBarViewBuilder] and
  /// [stackedWidgetBuilder].
  final Widget Function(
          BuildContext context, VRouterData vRouterData, Widget child)?
      buildWrapper;

  @override
  List<VRouteElement> buildRoutes() {
    final tabsRoutesNames =
        tabsRoutes.map((e) => e.routeInfoInstance.name).toList();

    final tabsRouteElements = tabsRoutes.mapIndexed((index, tabRoute) {
      return VNester.builder(
        key: key,
        path: path,
        name: name,
        aliases: aliases,
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
        buildTransition: buildTransition,
        navigatorKey: navigatorKey,
        fullscreenDialog: fullscreenDialog,
        widgetBuilder: (context, vRouterData, child) => TabBarWidget(
          vRouterData: vRouterData,
          child: child,
          currentIndex: index,
          initialTabIndex: initialTabIndex,
          initialGoToResolver: initialGoToResolver,
          initialPopToResolver: initialPopToResolver,
          tabsLength: tabsRoutes.length,
          tabsRoutesNames: tabsRoutesNames,
          tabBarViewBuilder: tabBarViewBuilder,
          stackedWidgetBuilder: stackedWidgetBuilder,
          buildWrapper: buildWrapper,
        ),
        nestedRoutes: [tabRoute],
      );
    }).toList();

    return [
      //The tabs
      ...tabsRouteElements,

      /// The stacked routes
      if (stackedRoutes != null)
        VNester.builder(
          key: key,
          path: path,
          name: name,
          aliases: aliases,
          transitionDuration: transitionDuration,
          reverseTransitionDuration: reverseTransitionDuration,
          buildTransition: buildTransition,
          navigatorKey: navigatorKey,
          fullscreenDialog: fullscreenDialog,
          widgetBuilder: (context, vRouterData, child) => TabBarWidget(
            vRouterData: vRouterData,
            child: child,
            initialGoToResolver: initialGoToResolver,
            initialPopToResolver: initialPopToResolver,
            initialTabIndex: initialTabIndex,
            currentIndex: TabBarWidget.stackedWidgetIndex,
            tabsLength: tabsRoutes.length,
            tabsRoutesNames: tabsRoutesNames,
            tabBarViewBuilder: tabBarViewBuilder,
            stackedWidgetBuilder: stackedWidgetBuilder,
            buildWrapper: buildWrapper,
          ),
          nestedRoutes: stackedRoutes!,
        ),
    ];
  }
}

class TabBarWidget extends HookWidget {
  const TabBarWidget({
    Key? key,
    required this.vRouterData,
    required this.initialGoToResolver,
    required this.initialPopToResolver,
    required this.tabsLength,
    required this.initialTabIndex,
    required this.tabsRoutesNames,
    required this.currentIndex,
    required this.child,
    required this.tabBarViewBuilder,
    required this.stackedWidgetBuilder,
    required this.buildWrapper,
  })  : assert(initialTabIndex >= 0 && initialTabIndex < tabsLength),
        assert(tabsRoutesNames.length == tabsLength),
        assert(
            (currentIndex >= 0 && currentIndex < tabsLength) ||
                currentIndex == TabBarWidget.stackedWidgetIndex,
            "The currentIndex must be the index of a tab, or equal TabBarWidget.stackedWidgetIndex"),
        super(key: key);

  static const stackedWidgetIndex = -1;

  final Widget child;

  final VRouterData vRouterData;

  /// The current index :
  ///
  /// **If it's in the range `0 → tabsLength - 1` :**
  ///
  /// It corresponds to the index of a tab, so in the build method we build the
  /// tabBarView by calling [tabBarViewBuilder] , with this index passed-in.
  ///
  /// **If it equals [TabBarWidget.stackedWidgetIndex] :**
  ///
  /// In the build method we build the stacked widget by calling
  /// [stackedWidgetBuilder], which will be stacked on top of the tabBarView.

  final int currentIndex;

  /// The number of tabs
  final int tabsLength;

  /// Thhe route names of the tabs. Used internally to navigate to the tabs,
  /// using [VRouterNavigator.toNamed]
  final List<String> tabsRoutesNames;

  /// See [VxTabBar.tabBarViewBuilder]
  final Widget Function(BuildContext context, VRouterData vRouterData,
      TabController tabController, List<Widget> children) tabBarViewBuilder;

  /// See [VxTabBar.stackedWidgetBuilder]
  final Widget Function(
          BuildContext context, VRouterData vRouterData, Widget child)
      stackedWidgetBuilder;

  /// See [VxTabBar.buildWrapper]
  final Widget Function(
          BuildContext context, VRouterData vRouterData, Widget child)?
      buildWrapper;

  /// See [VxTabBar.initialGoToResolver]
  final InitialGoToResolver initialGoToResolver;

  /// See [VxTabBar.initialPopToResolver]
  final InitialPopToResolver initialPopToResolver;

  /// See [VxTabBar.initialTabIndex]
  final int initialTabIndex;

  /// We use this as the index to easily fetch the new widget when in comes into
  /// view.
  int getTabControllerIndex(TabController tabController) {
    return tabController.index + tabController.offset.sign.toInt();
  }

  List<VxTab> _generateInitialTabs() {
    return List.generate(tabsLength, (index) {
      return VxTab(null, tabsRoutesNames[index], Container());
    });
  }

  @override
  Widget build(BuildContext context) {
    /// The different tabs
    final tabs = useState(_generateInitialTabs());

    final tabController = useTabController(
      initialLength: tabsLength,
      initialIndex: initialTabIndex,
    );

    /// The index of the last visited tab.
    ///
    /// It is initialized to equal the [initialTabIndex]
    final lastTabIndex = useState(initialTabIndex);

    // When we are in a tab

    if (currentIndex != TabBarWidget.stackedWidgetIndex) {
      lastTabIndex.value = currentIndex;

      // Sync the tabController with the url
      if (!tabController.indexIsChanging &&
          getTabControllerIndex(tabController) != currentIndex) {
        tabController.animateTo(currentIndex);
      }

      // Populate the current tab's child and last visited url
      tabs.value = tabs.value
          .mapIndexed((index, tab) => index == currentIndex
              ? tab.copyWith(
                  child: child,
                  lastVisitedUrl: context.vRouter.url,
                )
              : tab)
          .toList();
    }

    /// TODO Add animation for stackedIndex

    final widget = IndexedStack(
      index: currentIndex == TabBarWidget.stackedWidgetIndex ? 1 : 0,
      children: [
        _buildTabBarView(
          context: context,
          tabs: tabs.value,
          tabController: tabController,
          lastTabIndex: lastTabIndex.value,
        ),
        if (currentIndex == TabBarWidget.stackedWidgetIndex)
          _buildStackedWidget(
            context: context,
            tabs: tabs.value,
            lastTabIndex: lastTabIndex.value,
          )
      ],
    );

    final buildWrapper = this.buildWrapper;

    return buildWrapper == null
        ? widget
        : buildWrapper(context, vRouterData, widget);
  }

  /// The TabBarView
  Widget _buildTabBarView({
    required BuildContext context,
    required List<VxTab> tabs,
    required TabController tabController,
    required int lastTabIndex,
  }) {
    ///We listen to the swipe on the TabBarView
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        // Syncs the url with the tabController
        final fromIndex = lastTabIndex;
        final toIndex = getTabControllerIndex(tabController);

        if (toIndex != fromIndex) {
          final targetTab = tabs[toIndex];
          final targetTabLastVisitedUrl = targetTab.lastVisitedUrl;

          /// If we visited the target tab before, we navigate to its
          /// lastVisited url.
          ///
          /// Otherwise, we navigate to its root route, and we use the
          /// [initialGoToResolver] to determine what pathParameters and other
          /// args to pass-in.

          if (targetTabLastVisitedUrl != null) {
            context.vRouter.to(targetTabLastVisitedUrl);
          } else {
            final queryParameters = initialGoToResolver.queryParameters(
                fromIndex, toIndex, vRouterData);

            final historyState = initialGoToResolver.historyState(
                fromIndex, toIndex, vRouterData);

            final hash =
                initialGoToResolver.hash(fromIndex, toIndex, vRouterData);

            final isReplacement = initialGoToResolver.isReplacement(
                fromIndex, toIndex, vRouterData);

            final pathParameters = initialGoToResolver.map(
              automaticPathParameters: (automaticPathParameters) {
                /// We extract the path parameters from the current vRouterData.

                final pathParamsToExtract = automaticPathParameters
                    .extractedPathParameters(fromIndex, toIndex, vRouterData);

                return VxUtils.extractPathParamsFromVRouterData(
                    vRouterData, pathParamsToExtract);
              },
              manualPathParameters: (manualPathParameters) {
                return manualPathParameters.pathParameters(
                    fromIndex, toIndex, vRouterData);
              },
              noPathParameters: (noPathParameters) => const <String, String>{},
            );

            context.vRouter.toNamed(
              targetTab.routeName,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              historyState: historyState,
              hash: hash,
              isReplacement: isReplacement,
            );
          }
        }

        /// We allow the notification to continue to be dispatched to further
        /// ancestors.
        return false;
      },
      child: tabBarViewBuilder(context, vRouterData, tabController,
          tabs.map((tab) => tab.child).toList()),
    );
  }

  /// The stacked widget.
  Widget _buildStackedWidget({
    required BuildContext context,
    required List<VxTab> tabs,
    required int lastTabIndex,
  }) {
    return VWidgetGuard(
      onPop: (vRedirector) async {
        /// The index of the tab we want to pop to.
        ///
        /// - (A) If we visited a tab previously, then this will correspond to the
        ///   index of the last visited tab ---> We navigate to its lastVisited
        ///   url.
        ///
        /// - (B) Otherwise, it will equal [initialTabIndex] (which lastTabIndex
        ///   is initialized to.) ----> We navigate to the root route, and we
        ///   use the [initialPopToResolver] to determine what pathParameters
        ///   and other args to pass-in.

        final toIndex = lastTabIndex;

        final targetTab = tabs[toIndex];
        final targetTabLastVisitedUrl = targetTab.lastVisitedUrl;

        // (A)
        if (targetTabLastVisitedUrl != null) {
          vRedirector.to(targetTabLastVisitedUrl);
        }
        // (B)
        else {
          assert(lastTabIndex == initialTabIndex,
              '''If we never visited a tab, then lastTabIndex should be equal to 
              initialTabIndex (which is the value it is initialized to).''');

          final queryParameters =
              initialPopToResolver.queryParameters(vRouterData);

          final historyState = initialPopToResolver.historyState(vRouterData);

          final hash = initialPopToResolver.hash(vRouterData);

          final isReplacement = initialPopToResolver.isReplacement(vRouterData);

          final pathParameters = initialPopToResolver.map(
            automaticPathParameters: (automaticPathParameters) {
              //We extract the path parameters from the current vRouterData.
              final pathParamsToExtract =
                  automaticPathParameters.extractedPathParameters(vRouterData);

              return VxUtils.extractPathParamsFromVRouterData(
                  vRouterData, pathParamsToExtract);
            },
            manualPathParameters: (manualPathParameters) {
              return manualPathParameters.pathParameters(vRouterData);
            },
            noPathParameters: (noPathParameters) => const <String, String>{},
          );

          vRedirector.toNamed(
            targetTab.routeName,
            pathParameters: pathParameters,
            queryParameters: queryParameters,
            hash: hash,
            historyState: historyState,
            isReplacement: isReplacement,
          );
        }
      },
      child: stackedWidgetBuilder(
        context,
        vRouterData,
        child,
      ),
    );
  }
}
