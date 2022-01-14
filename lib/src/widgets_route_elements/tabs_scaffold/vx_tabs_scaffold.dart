import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/widgets_route_elements/common/vx_tab.dart';
import 'package:vrouter_x/vrouter_x.dart';

/// A [VRouteElement] that allows you to easily setup a [BottomNavigationBar]
/// or your own [NavigationBar].
///
/// It implements several features including :
/// - Preserved state for each tab
/// - Lazily loaded tabs
/// - Seamless integration with Flutter's BottomNavigationBar or your own custom NavigationBar
/// - Possibility to stack routes on top of the NavigationBar.
///
class VxTabsScaffold extends VRouteElementBuilder {
  VxTabsScaffold({
    required this.path,
    required this.initialGoToResolver,
    required this.initialPopToResolver,
    required this.initialTabIndex,
    required this.tabsRoutes,
    required this.tabsScaffoldBuilder,
    this.stackedRoutes,
    this.stackedScaffoldBuilder = VxTabsScaffold.defaultStackedScaffoldBuilder,
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
  /// NB: Like for a [VNester], the [VxTabsScaffold] will only display if a
  /// nestedRoute matches.
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

  /// When the user navigates to a tab using the NavigationBar, and that tab hasn't
  /// been opened before, we don't know what path parameters to pass-in to that
  /// freshly initialized tab.
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
  ///
  /// **NB:** When popping a stackedRoute, its state is lost. If you want to keep
  /// its state, add a tabRoute instead, and you can return a different scaffold
  /// for that tabRoute's index inside the [tabsScaffoldBuilder]. Example :
  ///
  /// ```dart
  /// tabsScaffoldBuilder: (context, body, currentIndex, onTabPressed) =>
  ///      currentIndex == 3 ?
  ///      Scaffold(
  ///        body: body,
  ///      ) :
  ///      Scaffold(
  ///        body: body,
  ///        bottomNavigationBar: BottomNavigationBar(
  ///          ...
  ///        ),
  ///  ),
  /// ```
  final List<VxSimpleRoute>? stackedRoutes;

  /// Builder method for the scaffold of the [tabsRoutes].
  ///
  /// Example :
  ///
  /// ```dart
  /// tabsScaffoldBuilder: (context, vRouterData, body, currentIndex, onTabPressed) =>
  ///     Scaffold(
  ///       body: body,
  ///       bottomNavigationBar: BottomNavigationBar(
  ///         currentIndex: currentIndex,
  ///         onTap: onTabPressed,
  ///         items: const [
  ///           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
  ///           BottomNavigationBarItem(
  ///               icon: Icon(Icons.settings), label: 'Profile'),
  ///         ],
  ///       ),
  ///     ),
  /// ```
  final Widget Function(
      BuildContext context,
      VRouterData vRouterData,
      Widget body,
      int currentIndex,
      void Function(int)? onTabPressed) tabsScaffoldBuilder;

  /// Builder method for the scaffold of the [stackedRoutes].
  ///
  /// Defaults to [VxTabsScaffold.defaultStackedScaffoldBuilder]
  final Widget Function(
          BuildContext context, VRouterData vRouterData, Widget body)
      stackedScaffoldBuilder;

  /// This Builder method wraps both [tabsScaffoldBuilder] and
  /// [stackedScaffoldBuilder].
  final Widget Function(
          BuildContext context, VRouterData vRouterData, Widget child)?
      buildWrapper;

  /// Default builder for [stackedScaffoldBuilder]
  static Scaffold defaultStackedScaffoldBuilder(
          BuildContext context, VRouterData vRouterData, Widget body) =>
      Scaffold(body: body);

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
        widgetBuilder: (context, vRouterData, child) => TabsScaffoldWidget(
          vRouterData: vRouterData,
          initialGoToResolver: initialGoToResolver,
          initialPopToResolver: initialPopToResolver,
          initialTabIndex: initialTabIndex,
          child: child,
          currentIndex: index,
          tabsLength: tabsRoutes.length,
          tabsRoutesNames: tabsRoutesNames,
          stackedScaffoldBuilder: stackedScaffoldBuilder,
          tabsScaffoldBuilder: tabsScaffoldBuilder,
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
          widgetBuilder: (context, vRouterData, child) => TabsScaffoldWidget(
            vRouterData: vRouterData,
            initialGoToResolver: initialGoToResolver,
            initialPopToResolver: initialPopToResolver,
            initialTabIndex: initialTabIndex,
            child: child,
            currentIndex: TabsScaffoldWidget.stackedScaffoldIndex,
            tabsLength: tabsRoutes.length,
            tabsRoutesNames: tabsRoutesNames,
            stackedScaffoldBuilder: stackedScaffoldBuilder,
            tabsScaffoldBuilder: tabsScaffoldBuilder,
            buildWrapper: buildWrapper,
          ),
          nestedRoutes: stackedRoutes!,
        ),
    ];
  }
}

class TabsScaffoldWidget extends HookWidget {
  const TabsScaffoldWidget({
    Key? key,
    required this.vRouterData,
    required this.initialGoToResolver,
    required this.initialPopToResolver,
    required this.initialTabIndex,
    required this.tabsLength,
    required this.tabsRoutesNames,
    required this.currentIndex,
    required this.child,
    required this.tabsScaffoldBuilder,
    required this.stackedScaffoldBuilder,
    required this.buildWrapper,
  })  : assert(tabsRoutesNames.length == tabsLength),
        assert(
            (currentIndex >= 0 && currentIndex < tabsLength) ||
                currentIndex == TabsScaffoldWidget.stackedScaffoldIndex,
            "The currentIndex must be the index of a tab, or equal TabsScaffoldWidget.stackedScaffoldIndex"),
        super(key: key);

  static const stackedScaffoldIndex = -1;

  final Widget child;

  final VRouterData vRouterData;

  /// The current index :
  ///
  /// **If it's in the range `0 → tabsLength - 1` :**
  ///
  /// It corresponds to the index of a tab, so in the build method we build the
  /// tabs scaffold by calling [tabsScaffoldBuilder] , with this index
  /// passed-in.
  ///
  /// **If it equals [TabsScaffoldWidget.stackedScaffoldIndex] :**
  ///
  /// In the build method we build the stacked scaffold by calling
  /// [stackedScaffoldBuilder], which will be stacked on top of the tabs
  /// scaffold.

  final int currentIndex;

  /// The number of tabs
  final int tabsLength;

  /// Thhe route names of the tabs. Used internally to navigate to the tabs,
  /// using [VRouterNavigator.toNamed]
  final List<String> tabsRoutesNames;

  /// See [VxTabsScaffold.tabsScaffoldBuilder]
  final Widget Function(
      BuildContext context,
      VRouterData vRouterData,
      Widget body,
      int currentIndex,
      void Function(int)? onTabPressed) tabsScaffoldBuilder;

  /// See [VxTabsScaffold.stackedScaffoldBuilder]
  final Widget Function(
          BuildContext context, VRouterData vRouterData, Widget body)
      stackedScaffoldBuilder;

  /// See [VxTabsScaffold.buildWrapper]
  final Widget Function(
          BuildContext context, VRouterData vRouterData, Widget child)?
      buildWrapper;

  /// See [VxTabsScaffold.initialTabIndex]
  final InitialGoToResolver initialGoToResolver;

  /// See [VxTabsScaffold.initialTabIndex]
  final InitialPopToResolver initialPopToResolver;

  /// See [VxTabsScaffold.initialTabIndex]
  final int initialTabIndex;

  List<VxTab> _generateInitialTabs() {
    return List.generate(tabsLength, (index) {
      return VxTab(null, tabsRoutesNames[index], Container());
    });
  }

  @override
  Widget build(BuildContext context) {
    /// The different tabs
    final tabs = useState(_generateInitialTabs());

    /// The index of the last visited tab.
    final lastTabIndex = useState(initialTabIndex);

    /// When we are in a tab, we update lastTabIndex, and we populate its child
    /// and lastVisitedUrl
    if (currentIndex != TabsScaffoldWidget.stackedScaffoldIndex) {
      lastTabIndex.value = currentIndex;

      tabs.value = tabs.value
          .mapIndexed<VxTab>(
            (index, tab) => index == currentIndex
                ? tab.copyWith(
                    lastVisitedUrl: context.vRouter.url,
                    child: child,
                  )
                : tab,
          )
          .toList();
    }

    /// TODO Add animation for stackedIndex

    final widget = IndexedStack(
      index: currentIndex == TabsScaffoldWidget.stackedScaffoldIndex ? 1 : 0,
      children: [
        _buildTabsScaffold(context, tabs.value, lastTabIndex.value),
        if (currentIndex == TabsScaffoldWidget.stackedScaffoldIndex)
          _buildStackedScaffold(tabs.value, lastTabIndex.value, context),
      ],
    );
    final buildWrapper = this.buildWrapper;

    return buildWrapper == null
        ? widget
        : buildWrapper(context, vRouterData, widget);
  }

  /// The tabs scaffold
  Widget _buildTabsScaffold(
      BuildContext context, List<VxTab> tabs, int lastTabIndex) {
    return tabsScaffoldBuilder(
      context,
      vRouterData,

      /// The indexed stack contains the tabs only (without the stackedScaffold)
      IndexedStack(
        index: lastTabIndex,
        children: tabs.map((tab) => tab.child).toList(),
      ),
      lastTabIndex,
      (index) {
        final fromIndex = lastTabIndex;
        final toIndex = index;

        if (fromIndex != toIndex) {
          final targetTab = tabs[toIndex];
          final targetTabLastVisitedUrl = targetTab.lastVisitedUrl;

          /// - (A) If we visited the target tab before (a.k.a targetTabLastVisitedUrl
          /// is not null), we navigate to its lastVisited url.
          ///
          /// - (B) Otherwise, we navigate to its root route, and we use the
          /// [initialGoToResolver] to determine what pathParameters and other
          /// args to pass-in.

          // (A)
          if (targetTabLastVisitedUrl != null) {
            context.vRouter.to(targetTabLastVisitedUrl);
          }
          // (B)
          else {
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
        } else {
          //TODO when clicking on the same tab we are in, do a specific behaviour.
          print('TODO: implement specific behaviour');
        }
      },
    );
  }

  /// The stacked scaffold.
  VWidgetGuard _buildStackedScaffold(
      List<VxTab> tabs, int lastTabIndex, BuildContext context) {
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
      child: stackedScaffoldBuilder(
        context,
        vRouterData,
        child,
      ),
    );
  }
}
