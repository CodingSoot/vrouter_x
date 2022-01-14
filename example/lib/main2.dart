import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/vrouter_x.dart';

part 'main2.freezed.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

@freezed
class MyState with _$MyState {
  const factory MyState.main({required int number}) = _Main;
  const factory MyState.profile({required int number}) = _Profile;
  const factory MyState.purple({required int number}) = _Purple;
}

final myStateProvider = StateProvider<MyState>((ref) {
  return const MyState.main(number: 0);
});

class MyScaffold extends ConsumerWidget {
  const MyScaffold({Key? key, required this.body}) : super(key: key);

  final Widget body;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'btn-home-1',
                backgroundColor: Colors.lightBlue,
                child: const Icon(Icons.home),
                onPressed: () {
                  context.vRouter.to(MainRoute.routeInfo.path!);
                },
              ),
              const SizedBox(height: 20),
              FloatingActionButton(
                heroTag: 'btn-profile-1',
                backgroundColor: Colors.lightBlue,
                child: const Icon(Icons.person),
                onPressed: () {
                  context.vRouter.to(ProfileRoute.routeInfo.path!);
                },
              ),
              const SizedBox(height: 20),
              FloatingActionButton(
                heroTag: 'btn-person-1',
                backgroundColor: Colors.lightBlue,
                child: const Icon(Icons.piano),
                onPressed: () {
                  context.vRouter.to(PurpleRoute.routeInfo.path!);
                },
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'btn-home',
                child: const Icon(Icons.home),
                onPressed: () {
                  final number = ref.read(myStateProvider).number + 1;
                  final state = MyState.main(number: number);

                  ref.read(myStateProvider.state).state = state;
                },
              ),
              const SizedBox(height: 20),
              FloatingActionButton(
                heroTag: 'btn-profile',
                child: const Icon(Icons.person),
                onPressed: () {
                  final number = ref.read(myStateProvider).number + 1;
                  final state = MyState.profile(number: number);

                  ref.read(myStateProvider.state).state = state;
                },
              ),
              const SizedBox(height: 20),
              FloatingActionButton(
                heroTag: 'btn-person',
                child: const Icon(Icons.piano),
                onPressed: () {
                  final number = ref.read(myStateProvider).number + 1;
                  final state = MyState.purple(number: number);

                  ref.read(myStateProvider.state).state = state;
                },
              ),
            ],
          ),
        ],
      ),
      body: body,
    );
  }
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
      initialUrl: '/profile',
      routes: [
        VxRouteSwitcher<MyState>(
          routeRef,
          path: '/',
          switchRoutes: [
            MainRoute(routeRef),
            ProfileRoute(routeRef),
            PurpleRoute(routeRef),
          ],
          provider: myStateProvider,
          mapStateToSwitchRoute: (state, previousVRouterData) {
            return state.when(
              main: (number) => MatchedRouteDetails(
                switchRouteName: MainRoute.routeInfo.name,
                routeData: MainRouteData(number: number),
              ),
              profile: (number) => MatchedRouteDetails(
                switchRouteName: ProfileRoute.routeInfo.name,
                routeData: ProfileRouteData(number: number),
              ),
              purple: (number) => MatchedRouteDetails(
                switchRouteName: PurpleRoute.routeInfo.name,
                routeData: const PurpleRouteData(),
              ),
            );
          },
        )
      ],
    );
  }
}

@freezed
class PurpleRouteData extends RouteData with _$PurpleRouteData {
  const factory PurpleRouteData() = _PurpleRouteData;
}

class PurpleRoute extends VxSwitchRoute<PurpleRouteData> {
  PurpleRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
          widgetBuilder: (context, vRouterData, child) =>
              MyScaffold(body: child),
          afterRedirect: () async {
            await Future.delayed(Duration(seconds: 1));
            print('redirected out of purple');
          },
          afterSwitch: () async {
            await Future.delayed(Duration(seconds: 1));
            print('switched to purple');
          },
        );

  static final routeInfo = SwitchRouteInfo<PurpleRouteData>(
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

@freezed
class GreenRouteData extends RouteData with _$GreenRouteData {
  const factory GreenRouteData() = _GreenRouteData;
}

class GreenRoute extends VxDataRoute {
  GreenRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
          afterRedirect: () async {
            await Future.delayed(Duration(seconds: 1));
            print('redirected out of green');
          },
        );

  static final routeInfo = DataRouteInfo(
    path: '/green/:id',
    name: 'green',
    redirectToResolver: const RedirectToResolver.noPathParameters(),
    redirectToRouteName: MainRoute.routeInfo.name,
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
              ),
            )
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
          widget: const ColorScreen(color: Colors.pink, title: 'Plus')),
    ];
  }
}

@freezed
class ProfileRouteData extends RouteData with _$ProfileRouteData {
  const factory ProfileRouteData({required int number}) = _ProfileRouteData;
}

class ProfileRoute extends VxSwitchRoute<ProfileRouteData> {
  ProfileRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
          widgetBuilder: (context, vRouterData, child) =>
              MyScaffold(body: child),
          afterRedirect: () async {
            await Future.delayed(Duration(seconds: 1));
            print('redirected out of profile');
          },
          afterSwitch: () async {
            await Future.delayed(Duration(seconds: 1));
            print('switched to profile');
          },
        );

  static final routeInfo = SwitchRouteInfo<ProfileRouteData>(
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

@freezed
class MainRouteData extends RouteData with _$MainRouteData {
  const factory MainRouteData({required int number}) = _MainRouteData;
}

class MainRoute extends VxSwitchRoute<MainRouteData> {
  MainRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
          widgetBuilder: (context, vRouterData, child) =>
              MyScaffold(body: child),
          afterRedirect: () async {
            await Future.delayed(Duration(seconds: 1));
            print('redirected out of main');
          },
          afterSwitch: () async {
            await Future.delayed(Duration(seconds: 1));
            print('switched to main');
          },
        );

  static final routeInfo = SwitchRouteInfo<MainRouteData>(
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
          GreenRoute(routeRef),
          PlusRoute(routeRef),
        ],
      ),
    ];
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton(
        child: const Text('Go to green'),
        onPressed: () {
          GreenRoute.routeInfo.navigate(
              RouteRef.fromWidgetRef(ref), context.vRouter,
              data: const GreenRouteData(),
              pathParameters: {
                'id': 'hey',
              });
        },
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const BaseWidget(
      title: 'Settings',
      buttonText: 'Pop',
      to: '/profile',
    );
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routeData = ref.watch(ProfileRoute.routeInfo.routeDataProvider);

    return BaseWidget(
        title: 'Profile : ${routeData.number}',
        buttonText: 'Go to Settings',
        to: '/profile/settings');
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
