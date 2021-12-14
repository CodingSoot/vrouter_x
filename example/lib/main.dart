import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/vrouter_x.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VRouter(
      debugShowCheckedModeBanner: false,
      // initialUrl: '/profile',
      routes: [
        VxTabsScaffold(
          path: '/', // must be absolute
          tabsRoutes: [
            PathInfo(
              path:
                  null, // Null makes it the path of the parent "/", which is the initial route
              buildRoute: (path) => VWidget(
                path: path,
                key: const ValueKey(
                    'Home'), //I think it's for the indexed stack to work well ?
                widget: const HomeScreen(),
                stackedRoutes: [
                  VxTabBar(
                    path: '/', // must be absolute
                    tabsRoutes: [
                      TabPathInfo(
                        path: 'red',
                        buildRoute: (path, aliases) => VWidget(
                          path: path,
                          key: const ValueKey('Red'),
                          // We use a key to indicate that path and alias lead to the same screen
                          aliases: aliases,
                          widget: ColorScreen(
                            color: Colors.redAccent,
                            title: 'Red',
                            extraWidget: (context) => ElevatedButton(
                              onPressed: () {
                                context.vRouter.to('plus');
                              },
                              child: const Text('Plus'),
                            ),
                          ),
                        ),
                      ),
                      TabPathInfo(
                        path: 'green',
                        buildRoute: (path, aliases) => VWidget(
                            path: path,
                            key: const ValueKey('Green'),
                            // We use a key to indicate that path and alias lead to the same screen
                            aliases: aliases,
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
                                      context.vRouter.to('plus');
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
                                        context.vRouter.to('/green/plus');
                                      },
                                      child: const Text('Plus'),
                                    ),
                                  ))
                            ]),
                      ),
                      TabPathInfo(
                        path: 'yellow',
                        buildRoute: (path, aliases) => VWidget(
                          path: path,
                          key: const ValueKey('Yellow'),
                          // We use a key to indicate that path and alias lead to the same screen
                          aliases: aliases,
                          widget: ColorScreen(
                            color: Colors.yellow,
                            title: 'Yellow',
                            extraWidget: (context) => ElevatedButton(
                              onPressed: () {
                                context.vRouter.to('plus');
                              },
                              child: const Text('Plus'),
                            ),
                          ),
                        ),
                      ),
                    ],
                    stackedRoutes: (parentPath) => [
                      PathInfo(
                        path: '$parentPath/plus',
                        buildRoute: (path) => VWidget.builder(
                          path: path,
                          builder: (context, state) => const ColorScreen(
                            color: Colors.pink,
                            title: 'Plus',
                          ),
                        ),
                      ),
                    ],
                    tabBarViewBuilder: (context, tabController, children) =>
                        TabBarView(
                            controller: tabController, children: children),
                  ),
                ],
              ),
            ),
            PathInfo(
              path: 'profile',
              buildRoute: (path) => VWidget(
                path: path,
                widget: const ProfileScreen(),
                stackedRoutes: [
                  VWidget(path: 'settings', widget: const SettingsScreen())
                ],
              ),
            )
          ],
          stackedRoutes: [
            PathInfo(
              path: 'purple',
              buildRoute: (path) => VWidget(
                path: path,
                // key: const ValueKey('Purple'),
                widget:
                    const ColorScreen(color: Colors.purple, title: 'Purple'),
              ),
            )
          ],
          tabsScaffoldBuilder: (context, body, currentIndex, onTabPressed) =>
              Scaffold(
            body: body,
            floatingActionButton: FloatingActionButton(
              onPressed: () => context.vRouter.to('/purple'),
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onTabPressed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: 'Profile'),
              ],
            ),
          ),
          stackedScaffoldBuilder: (context, body) => Scaffold(body: body),
        )
      ],
    );
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
        title: 'Home', buttonText: 'Go to Color Tabs', to: '/red');
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
