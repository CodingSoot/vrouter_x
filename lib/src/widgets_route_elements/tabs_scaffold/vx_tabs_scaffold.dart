import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/route_elements/common/vx_route_base.dart';
import 'package:vrouter_x/src/route_elements/route_elements.dart';
import 'package:vrouter_x/src/widgets_route_elements/common/path_info.dart';
import 'package:vrouter_x/src/widgets_route_elements/common/vx_tab.dart';

/// A [VRouteElement] that allows you to easily setup a [BottomNavigationBar]
/// or your own [NavigationBar].
///
/// It implements several features including :
/// - Preserved state for each tab
/// - Lazily loaded tabs
/// - Seamless integration with Flutter's BottomNavigationBar or your own custom NavigationBar
/// - Possibility to stack routes on top of the BottomNavigationBar.
///
class VxTabsScaffold extends VRouteElementBuilder {
  VxTabsScaffold({
    required this.path,
    required this.tabsRoutes,
    this.stackedRoutes,
    required this.tabsScaffoldBuilder,
    this.stackedScaffoldBuilder = VxTabsScaffold.defaultStackedScaffoldBuilder,
    this.buildWrapper,
  }) : assert(path.startsWith('/'),
            "The path of the VTabsScaffold must be absolute");

  /// The path of this [VRouteElement]. It must be absolute.
  final String path;

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
  /// tabsScaffoldBuilder: (context, body, currentIndex, onTabPressed) =>
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
  final Widget Function(BuildContext context, VRouterData state, Widget body,
      int currentIndex, void Function(int)? onTabPressed) tabsScaffoldBuilder;

  /// This BuilderMethod wraps both tabsScaffoldBuilder and stackedScaffoldBuilder.
  final Widget Function(BuildContext context, VRouterData state, Widget child)?
      buildWrapper;

  /// Builder method for the scaffold of the [stackedRoutes]
  ///
  /// Defaults to [VxTabsScaffold.defaultStackedScaffoldBuilder]
  final Widget Function(BuildContext context, VRouterData state, Widget body)
      stackedScaffoldBuilder;

  ///Default builder for [stackedScaffoldBuilder]
  static Scaffold defaultStackedScaffoldBuilder(
          BuildContext context, VRouterData state, Widget body) =>
      Scaffold(body: body);

  @override
  List<VRouteElement> buildRoutes() {
    final tabsPaths =
        tabsRoutes.map((tabRoute) => tabRoute.routeInfoInstance.path).toList();

    final tabsRouteElements = tabsRoutes.mapIndexed((index, tabRoute) {
      return VNester.builder(
        ///TODO add other parameters in constructor

        path: path,
        widgetBuilder: (context, state, child) => TabsScaffoldWidget(
          state: state,
          rootPath: path,
          tabsPaths: tabsPaths,
          child: child,
          currentIndex: index,
          tabsLength: tabsRoutes.length,
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
          ///TODO add other parameters in constructor
          path: path,
          widgetBuilder: (context, state, child) => TabsScaffoldWidget(
            state: state,
            rootPath: path,
            tabsPaths: tabsPaths,
            child: child,
            currentIndex: TabsScaffoldWidget.stackedScaffoldIndex,
            tabsLength: tabsRoutes.length,
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
    required this.state,
    required this.rootPath,
    required this.tabsPaths,
    required this.tabsLength,
    required this.currentIndex,
    required this.child,
    required this.tabsScaffoldBuilder,
    required this.stackedScaffoldBuilder,
    required this.buildWrapper,
  })  : assert(tabsPaths.length == tabsLength,
            "The tabsPaths length must equal tabsLength"),
        assert(
            (currentIndex >= 0 && currentIndex < tabsLength) ||
                currentIndex == TabsScaffoldWidget.stackedScaffoldIndex,
            "The currentIndex must be the index of a tab, or equal TabsScaffoldWidget.stackedScaffoldIndex"),
        super(key: key);

  static const stackedScaffoldIndex = -1;

  final VRouterData state;

  /// The path of the [VxTabsScaffold], which is an absolute path.
  final String rootPath;

  /// The paths of the tabs of the [VxTabsScaffold].
  final List<String?> tabsPaths;

  final Widget child;

  /// The current index :
  ///
  ///  - **If it's in the range [0 → tabsLength - 1] :** It corresponds to the
  ///    index of a tab, so we build the tabsScaffold with this index.
  ///  - **If it equals [TabsScaffoldWidget.stackedScaffoldIndex] :** We build the
  ///    stackedScaffold
  ///
  final int currentIndex;

  /// The number of tabs
  final int tabsLength;

  final Widget Function(BuildContext context, VRouterData state, Widget body,
      int currentIndex, void Function(int)? onTabPressed) tabsScaffoldBuilder;

  final Widget Function(BuildContext context, VRouterData state, Widget body)
      stackedScaffoldBuilder;

  /// This BuilderMethod wraps both tabsScaffoldBuilder and stackedScaffoldBuilder.
  final Widget Function(BuildContext context, VRouterData state, Widget child)?
      buildWrapper;

  List<VxTab> _generateInitialTabs() {
    return List.generate(tabsLength, (index) {
      final tabPath = tabsPaths[index];
      //Forming the absolute path of the tab.
      final absoluteTabPath = PathInfo.makeAbsolutePath(rootPath, tabPath);

      return VxTab(absoluteTabPath, Container());
    });
  }

  @override
  Widget build(BuildContext context) {
    /// The different tabs
    final tabs = useState(_generateInitialTabs());

    /// The index of the last visited tab.
    final lastTabIndex = useState(0);

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

    ///TODO Add animation for stackedIndex

    final widget = currentIndex == TabsScaffoldWidget.stackedScaffoldIndex
        ? _buildStackedScaffold(tabs, lastTabIndex, context)
        : _buildTabsScaffold(context, tabs);

    final buildWrapper = this.buildWrapper;

    return buildWrapper == null ? widget : buildWrapper(context, state, widget);
  }

  /// The tabs scaffold
  Widget _buildTabsScaffold(
      BuildContext context, ValueNotifier<List<VxTab>> tabs) {
    return tabsScaffoldBuilder(
      context,
      state,

      ///The indexed stack contains the tabs only (without the stackedScaffold)
      IndexedStack(
        index: currentIndex,
        children: tabs.value.map((tab) => tab.child).toList(),
      ),
      currentIndex,
      (index) {
        final targetTab = tabs.value[index];
        context.vRouter.to(targetTab.lastVisitedUrl);
      },
    );
  }

  /// The stacked scaffold.
  VWidgetGuard _buildStackedScaffold(ValueNotifier<List<VxTab>> tabs,
      ValueNotifier<int> lastTabIndex, BuildContext context) {
    /// OnPop, we redirect to the lastVisitedUrl of the last visited tab
    return VWidgetGuard(
      onPop: (vRedirector) async {
        final lastVisitedTab = tabs.value[lastTabIndex.value];
        vRedirector.to(lastVisitedTab.lastVisitedUrl);
      },
      child: stackedScaffoldBuilder(
        context,
        state,

        ///The indexed stack contains the tabs + the stacked child.
        IndexedStack(
          index: tabsLength,
          children: [...tabs.value.map((tab) => tab.child).toList(), child],
        ),
      ),
    );
  }
}
