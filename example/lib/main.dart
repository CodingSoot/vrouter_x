import 'package:example/main2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/vrouter_x.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends ConsumerWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeRef = RouteRef.fromWidgetRef(ref);

    return VRouter(
      debugShowCheckedModeBanner: false,
      // initialUrl: '/profile',
      routes: [
        VGuard(
          beforeEnter: (vRedirector) async {
            print('''
            Path : ${vRedirector.newVRouterData!.path}
            Names : ${vRedirector.newVRouterData!.names}
            Path parameters : ${vRedirector.newVRouterData!.pathParameters}
            ''');
          },
          beforeUpdate: (vRedirector) async {
            print('''
            Path : ${vRedirector.newVRouterData!.path}
            Names : ${vRedirector.newVRouterData!.names}
            Path parameters : ${vRedirector.newVRouterData!.pathParameters}
            ''');
          },
          stackedRoutes: [
            VxTabsScaffold(
              path: '/', // must be absolute
              initialTabIndex: 0,
              initialPopToResolver:
                  InitialPopToResolver.automaticPathParameters(
                extractedPathParameters: (stackedViewVRouterData) => [],
              ),
              initialGoToResolver: InitialGoToResolver.automaticPathParameters(
                extractedPathParameters:
                    (previousTabIndex, nextTabIndex, previousTabVRouterData) =>
                        [],
              ),
              tabsRoutes: [
                MainRoute(routeRef),
                ProfileRoute(routeRef),
              ],
              stackedRoutes: [
                PurpleRoute(routeRef),
              ],
              tabsScaffoldBuilder:
                  (context, state, body, currentIndex, onTabPressed) =>
                      MyScaffold(
                body: body,
                currentIndex: currentIndex,
                onTabPressed: onTabPressed,
              ),
              stackedScaffoldBuilder: (context, state, body) =>
                  Scaffold(body: body),
            )
          ],
        )
      ],
    );
  }
}

class MyScaffold extends StatelessWidget {
  const MyScaffold({
    Key? key,
    required this.body,
    required this.currentIndex,
    required this.onTabPressed,
  }) : super(key: key);

  final int currentIndex;
  final void Function(int)? onTabPressed;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      appBar: PfPathWidgetSwitcher(
        pathWidgets: [
          PathWidget(
            path: MainRoute.routeInfo.path!,
            builder: (path) => AppBar(
              key: ValueKey(path),
              backgroundColor: Colors.indigo,
              title: const Text('Main'),
            ),
            prefix: false,
          ),
          PathWidget(
            path: ProfileRoute.routeInfo.path!,
            builder: (path) => AppBar(
              key: ValueKey(path),
              backgroundColor: Colors.teal,
              title: const Text('Profile'),
            ),
            prefix: false,
          ),
          PathWidget(
            path: '*',
            builder: (path) => AppBar(
              key: ValueKey(path),
              backgroundColor: Colors.purpleAccent,
              title: const Text('Other'),
            ),
            prefix: false,
          ),
        ],
        builder: (context, child) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: child,
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: PathWidgetSwitcher(
        pathWidgets: [
          PathWidget(
            path: MainRoute.routeInfo.path!,
            builder: (path) => MyFAB(
              key: ValueKey(path),
              color: Colors.indigo,
            ),
            prefix: false,
          ),
          PathWidget(
            path: ProfileRoute.routeInfo.path!,
            builder: (path) => MyFAB(
              key: ValueKey(path),
              color: Colors.teal,
            ),
            prefix: false,
          ),
          PathWidget(
            path: '*',
            builder: (path) => MyFAB(
              key: ValueKey(path),
              color: Colors.purpleAccent,
            ),
            prefix: false,
          ),
        ],
        builder: (context, child) => AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: child,
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTabPressed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profile'),
      ],
    );
  }
}

class MyFAB extends StatelessWidget {
  const MyFAB({
    Key? key,
    required this.color,
  }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          backgroundColor: color,
          child: const Text('Plus'),
          onPressed: () => PlusRoute.routeInfo.navigate(context.vRouter),
        ),
        const SizedBox(height: 20.0),
        FloatingActionButton(
          backgroundColor: color,
          child: const Text('Purple'),
          onPressed: () => PurpleRoute.routeInfo.navigate(context.vRouter),
        ),
      ],
    );
  }
}

class PurpleRoute extends VxSimpleRoute {
  PurpleRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SimpleRouteInfo(
    path: '/purple',
    name: 'purple',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const ColorScreen(color: Colors.purple, title: 'Purple'),
      ),
    ];
  }
}

class RedRoute extends VxSimpleRoute {
  RedRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SimpleRouteInfo(
    path: '/red/:id',
    name: 'red',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const ColorScreen(color: Colors.red, title: 'Red'),
      ),
    ];
  }
}

class GreenRoute extends VxSimpleRoute {
  GreenRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SimpleRouteInfo(
    path: '/green/:id',
    name: 'green',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
          path: null,
          widget: ColorScreen(
            color: Colors.green,
            title: 'Green',
            extraWidget: (context) => Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.vRouter.to('light-green');
                  },
                  child: const Text('Light Green'),
                ),
                ElevatedButton(
                  onPressed: () {
                    PlusRoute.routeInfo.navigate(context.vRouter);
                  },
                  child: const Text('Plus'),
                ),
              ],
            ),
          ),
          stackedRoutes: [
            VWidget(
                path: 'light-green',
                widget: ColorScreen(
                  color: Colors.lightGreen.shade200,
                  title: 'Light Green',
                  extraWidget: (context) => ElevatedButton(
                    onPressed: () {
                      PlusRoute.routeInfo.navigate(context.vRouter);
                    },
                    child: const Text('Plus'),
                  ),
                ))
          ]),
    ];
  }
}

class PlusRoute extends VxSimpleRoute {
  PlusRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SimpleRouteInfo(
    path: '/plus',
    name: 'plus',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const ColorScreen(color: Colors.purple, title: 'Purple'),
      ),
    ];
  }
}

class ProfileRoute extends VxSimpleRoute {
  ProfileRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SimpleRouteInfo(
    path: '/profile',
    name: 'profile',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const ProfileScreen(),
        stackedRoutes: [
          VWidget(path: 'settings', widget: const SettingsScreen())
        ],
      ),
    ];
  }
}

class MainRoute extends VxSimpleRoute {
  MainRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SimpleRouteInfo(
    path: '/',
    name: 'main',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const HomeScreen(),
        stackedRoutes: [
          VxTabBar(
            path: '/', // must be absolute
            initialTabIndex: 0,
            initialPopToResolver: InitialPopToResolver.manualPathParameters(
              pathParameters: (stackedViewVRouterData) => {'id': 'hey'},
            ),
            initialGoToResolver: InitialGoToResolver.automaticPathParameters(
              extractedPathParameters:
                  (previousTabIndex, nextTabIndex, previousTabVRouterData) =>
                      ['id'],
            ),
            tabsRoutes: [
              RedRoute(routeRef),
              GreenRoute(routeRef),
            ],
            stackedRoutes: [
              PlusRoute(routeRef),
            ],
            tabBarViewBuilder: (context, state, tabController, children) =>
                TabBarView(
              controller: tabController,
              children: children,
            ),
          ),
        ],
      ),
    ];
  }
}

class BaseWidget extends HookWidget {
  final String title;
  final String buttonText;
  final String to;

  const BaseWidget({
    Key? key,
    required this.title,
    required this.buttonText,
    required this.to,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isChecked = useState(false);

    return Material(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => context.vRouter.to(to),
              child: Text(buttonText),
            ),
            const SizedBox(height: 50),
            Checkbox(
              value: isChecked.value,
              onChanged: (value) => isChecked.value = value ?? false,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseWidget(
        title: 'Home', buttonText: 'Go to Color Tabs', to: '/red/hey');
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseWidget(
        title: 'Settings', buttonText: 'Pop', to: '/profile');
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseWidget(
        title: 'Profile',
        buttonText: 'Go to Settings',
        to: '/profile/settings');
  }
}

class ColorScreen extends HookWidget {
  const ColorScreen({
    Key? key,
    required this.color,
    required this.title,
    this.extraWidget,
  }) : super(key: key);

  final Color color;
  final String title;
  final Widget Function(BuildContext context)? extraWidget;

  @override
  Widget build(BuildContext context) {
    //for type promotion
    final extraWidget = this.extraWidget;

    /// This is so that the state of the tabs inside the [TabBarView] is kept.
    useAutomaticKeepAlive();

    final isChecked = useState(false);

    return Container(
      color: color,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () => context.vRouter.pop(),
              child: const Text('Pop'),
            ),
            const SizedBox(height: 50),
            Checkbox(
              value: isChecked.value,
              onChanged: (value) => isChecked.value = value ?? false,
            ),
            if (extraWidget != null) const SizedBox(height: 50),
            if (extraWidget != null) extraWidget(context),
          ],
        ),
      ),
    );
  }
}
