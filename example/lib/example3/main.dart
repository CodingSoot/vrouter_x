import 'package:example/example3/switcher1/switcher1_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/vrouter_x.dart';

part 'main.freezed.dart';

/// .
/// └── Switcher 1
///     ├── (A*) : Switcher 2
///     │   ├── (A1) : Switcher 4
///     │   │   ├── (D1*)
///     │   │   ├── (D2)
///     │   │   └── (D3)
///     │   ├── (A2*)
///     │   └── (A3)
///     ├── (B)
///     └── (C) : Switcher 3
///         ├── (C1*)
///         ├── (C2)
///         └── (C3)
///
/// * : main switchRoute

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

@freezed
class State1 with _$State1 {
  const factory State1.A() = _A;
  const factory State1.B() = _B;
  const factory State1.C() = _C;
}

final state1Provider = StateProvider<State1>((ref) {
  return const State1.A();
});

@freezed
class State2 with _$State2 {
  const factory State2.A1() = _A1;
  const factory State2.A2() = _A2;
  const factory State2.A3() = _A3;
}

final state2Provider = StateProvider<State2>((ref) {
  return const State2.A1();
});

@freezed
class State3 with _$State3 {
  const factory State3.C1() = _C1;
  const factory State3.C2() = _C2;
  const factory State3.C3() = _C3;
}

final state3Provider = StateProvider<State3>((ref) {
  return const State3.C1();
});

@freezed
class State4 with _$State4 {
  const factory State4.D1() = _D1;
  const factory State4.D2() = _D2;
  const factory State4.D3() = _D3;
}

final state4Provider = StateProvider<State4>((ref) {
  return const State4.D1();
});

class MyScaffold extends ConsumerWidget {
  const MyScaffold({Key? key, required this.body}) : super(key: key);

  final Widget body;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FAB(
                  provider: state1Provider,
                  title: 'A',
                  isMainSwitchRoute: true,
                  stateOnPress: const State1.A(),
                ),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FAB(
                            provider: state2Provider,
                            title: 'A1',
                            isMainSwitchRoute: true,
                            stateOnPress: const State2.A1(),
                          ),
                          const SizedBox(height: 10),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FAB(
                                  provider: state4Provider,
                                  title: 'D1',
                                  isMainSwitchRoute: true,
                                  stateOnPress: const State4.D1(),
                                ),
                                const VerticalDivider(
                                  thickness: 1.0,
                                ),
                                FAB(
                                  provider: state4Provider,
                                  title: 'D2',
                                  stateOnPress: const State4.D2(),
                                ),
                                const VerticalDivider(
                                  thickness: 1.0,
                                ),
                                FAB(
                                  provider: state4Provider,
                                  title: 'D3',
                                  stateOnPress: const State4.D3(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const VerticalDivider(
                        thickness: 2.0,
                      ),
                      FAB(
                        provider: state2Provider,
                        title: 'A2',
                        stateOnPress: const State2.A2(),
                      ),
                      const VerticalDivider(
                        thickness: 2.0,
                      ),
                      FAB(
                        provider: state2Provider,
                        title: 'A3',
                        stateOnPress: const State2.A3(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const VerticalDivider(),
            FAB(
              provider: state1Provider,
              title: 'B',
              stateOnPress: const State1.B(),
            ),
            const VerticalDivider(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FAB(
                  provider: state1Provider,
                  title: 'C',
                  stateOnPress: const State1.C(),
                ),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FAB(
                        provider: state3Provider,
                        title: 'C1',
                        isMainSwitchRoute: true,
                        stateOnPress: const State3.C1(),
                      ),
                      const VerticalDivider(
                        thickness: 2.0,
                      ),
                      FAB(
                        provider: state3Provider,
                        title: 'C2',
                        stateOnPress: const State3.C2(),
                      ),
                      const VerticalDivider(
                        thickness: 2.0,
                      ),
                      FAB(
                        provider: state3Provider,
                        title: 'C3',
                        stateOnPress: const State3.C3(),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      body: body,
    );
  }
}

class FAB<T> extends ConsumerWidget {
  const FAB({
    Key? key,
    required this.provider,
    required this.title,
    this.isMainSwitchRoute = false,
    required this.stateOnPress,
  }) : super(key: key);

  final StateProvider<T> provider;

  final T stateOnPress;

  final bool isMainSwitchRoute;

  /// Must be unique
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      heroTag: title,
      child: Text(title),
      backgroundColor: isMainSwitchRoute ? Colors.blue[700] : Colors.blue,
      onPressed: () {
        ref.read(provider.state).state = stateOnPress;
      },
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
      theme: ThemeData.light().copyWith(
          dividerTheme: const DividerThemeData(
        thickness: 3.0,
        color: Colors.indigo,
      )),
      initialUrl: '/d1/init',
      routes: [
        MainRoute(routeRef),
      ],
    );
  }
}

class MainRoute extends VxSimpleRoute {
  MainRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
          widgetBuilder: (context, vRouterData, child) => MyScaffold(
            body: child,
          ),
        );

  static final routeInfo = SimpleRouteInfo(
    path: '/',
    name: 'main',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VxRouteSwitcher<State1>.withMainRedirection(
        routeRef,
        path: null,
        switchRoutes: [
          ARoute(routeRef),
          BRoute(routeRef),
          CRoute(routeRef),
        ],
        provider: state1Provider,
        mapStateToSwitchRoute: (state, vRouterData) => state.when(
          A: () => MatchedRouteDetails(
            switchRouteName: ARoute.routeInfo.name,
            routeData: const ARouteData(),
            pathParameters: {'id': 'initial'},
          ),
          B: () => MatchedRouteDetails(
            switchRouteName: BRoute.routeInfo.name,
            routeData: const BRouteData(),
            pathParameters: {'id': 'initial'},
          ),
          C: () => MatchedRouteDetails(
            switchRouteName: CRoute.routeInfo.name,
            routeData: const CRouteData(),
            pathParameters: {'id': 'initial'},
          ),
        ),
        mainSwitchRouteName: ARoute.routeInfo.name,
        redirectToQueryParam: 'redirect-1',
      ),
    ];
  }
}

class BaseWidget extends StatelessWidget {
  const BaseWidget(
    this.title, {
    Key? key,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }
}
