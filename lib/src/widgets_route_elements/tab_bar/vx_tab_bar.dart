import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/widgets_route_elements/common/path_info.dart';
import 'package:vrouter_x/src/widgets_route_elements/common/tab_path_info.dart';
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
///  - Each tabRoute should indicate a key to indicate that path and alias lead
///    to the same screen, so that the state and animations are correct when
///    going from a stackedRoute to a tabRoute.
///  - The widget of each tab route should mixin [AutomaticKeepAliveClientMixin]
///    if you want to keep the state.
class VxTabBar extends VRouteElementBuilder {
  VxTabBar({
    required this.path,
    required this.tabsRoutes,
    this.stackedRoutes,
    required this.tabBarViewBuilder,
  }) : assert(path.startsWith('/'), "The path of the VTabBar must be absolute");

  /// The path of this [VRouteElement]. It must be absolute.
  final String path;

  /// The [VRouteElement]s of the tabs
  final List<TabPathInfo> tabsRoutes;

  /// A callback that should return the [VRouteElement]s of the routes that will
  /// be stacked on top of the Tabs (Optional)
  ///
  /// [parentPath] is the path of the parent tab. You can use it to form the
  /// path of the stackedRoute. For example :
  ///
  /// ```dart
  /// stackedRoutes: (parentPath) => [
  ///    PathWrapper(
  ///      path: '$parentPath/details',
  ///      buildRoute: (path) => VWidget(
  ///        path: path,
  ///        ...
  ///      ),
  ///    ),
  ///  ],
  /// ```
  ///
  /// **NB:** When popping a stackedRoute, we return the last visited tabRoute's
  /// path, but not its last visited url.
  ///
  /// *For example :*
  ///
  /// ```
  /// tabsRoutes :
  /// |_ tab1
  /// |_ tab2
  /// |   |_ tab2_details
  /// |_tab3
  ///
  /// stackedRoutes :
  /// |_ info
  /// ```
  ///
  /// If we were in tab2_details, and we go to info, when we pop we're taken
  /// back to tab2.
  ///
  /// If I ever need a different behaviour, I can implement it using an
  /// [IndexedStack], like what I made for [VTabsScaffold].
  ///
  final List<PathInfo> Function(String? parentPath)? stackedRoutes;

  /// Builder method for the TabBarView.
  final Widget Function(BuildContext context, TabController tabController,
      List<Widget> children) tabBarViewBuilder;

  @override
  List<VRouteElement> buildRoutes() {
    //for type promotion
    final stackedRoutes = this.stackedRoutes;

    final tabsPaths = tabsRoutes.map((tabRoute) => tabRoute.path).toList();

    return tabsRoutes.mapIndexed((index, tabRoute) {
      final tabStackedRoutes =
          stackedRoutes != null ? stackedRoutes(tabRoute.path) : null;

      ///When dealing with stackedRoutes of a VNester, we need to add their
      ///paths as aliases to the VNester.nestedRoutes, so that the VNester
      ///functions properly.
      ///
      ///See https://github.com/lulupointu/vrouter/issues/143
      final aliases = tabStackedRoutes
          ?.map((stackedRoute) => stackedRoute.path ?? path)
          .toSet()
          .toList();

      final tabRouteElement = tabRoute.build(aliases);

      return VNester(
        ///TODO add other parameters in constructor
        path: path,
        widgetBuilder: (child) => TabBarWidget(
          child: child,
          currentIndex: index,
          rootPath: path,
          tabsPaths: tabsPaths,
          tabsLength: tabsRoutes.length,
          tabBarViewBuilder: tabBarViewBuilder,
        ),

        nestedRoutes: [
          ///The tab
          tabRouteElement
        ],

        /// The stacked routes
        stackedRoutes: [
          if (tabStackedRoutes != null)
            VPopHandler(
                onPop: (vRedirector) async {
                  final targetTabPath = tabRoute.path;
                  final targetTabAbsolutePath =
                      PathInfo.makeAbsolutePath(path, targetTabPath);
                  vRedirector.to(targetTabAbsolutePath);
                },
                stackedRoutes: tabStackedRoutes
                    .map((pathRoute) => pathRoute.build())
                    .toList())
        ],
      );
    }).toList();
  }
}

class TabBarWidget extends HookWidget {
  const TabBarWidget({
    Key? key,
    required this.rootPath,
    required this.tabsPaths,
    required this.tabsLength,
    required this.currentIndex,
    required this.child,
    required this.tabBarViewBuilder,
  })  : assert(tabsPaths.length == tabsLength,
            "The tabsPaths length must equal tabsLength"),
        assert(currentIndex >= 0 && currentIndex < tabsLength,
            "The currentIndex must be the index of a tab"),
        super(key: key);

  /// The path of the [VxTabBar], which is an absolute path.
  final String rootPath;

  /// The paths of the tabs of the [VxTabBar].
  final List<String?> tabsPaths;

  final Widget child;

  /// The current index of the tab.
  final int currentIndex;

  /// The number of tabs
  final int tabsLength;

  final Widget Function(BuildContext context, TabController tabController,
      List<Widget> children) tabBarViewBuilder;

  /// We use this as the index to easily fetch the new widget when in comes into
  /// view
  int getTabControllerIndex(TabController tabController) {
    return tabController.index + tabController.offset.sign.toInt();
  }

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

    final tabController = useTabController(
      initialLength: tabsLength,
      initialIndex: currentIndex,
    );

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

    ///We listen to the swipe on the TabBarView
    return NotificationListener<ScrollNotification>(
      onNotification: (_) {
        // Syncs the url with the tabController
        final tabControllerIndex = getTabControllerIndex(tabController);
        if (tabControllerIndex != currentIndex) {
          final targetTab = tabs.value[tabControllerIndex];
          context.vRouter.to(targetTab.lastVisitedUrl);
        }
        return false;
      },
      child: tabBarViewBuilder(
          context, tabController, tabs.value.map((tab) => tab.child).toList()),
    );
  }
}
