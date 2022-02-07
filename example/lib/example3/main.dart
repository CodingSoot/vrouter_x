import 'package:example/example3/routes1.dart';
import 'package:example/example3/routes2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/vrouter_x.dart';

part 'main.freezed.dart';

/// .
/// └── Switcher 1
///     ├── (A) : Switcher 2
///     │   ├── (A1)
///     │   ├── (A2)
///     │   └── (A3)
///     ├── (B)
///     └── (C) : Switcher 3
///         ├── (C1)
///         ├── (C2)
///         └── (C3)
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
              FAB(
                provider: state1Provider,
                title: 'A',
                stateOnPress: const State1.A(),
              ),
              const SizedBox(height: 20),
              FAB(
                provider: state1Provider,
                title: 'B',
                stateOnPress: const State1.B(),
              ),
              const SizedBox(height: 20),
              FAB(
                provider: state1Provider,
                title: 'C',
                stateOnPress: const State1.C(),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FAB(
                provider: state2Provider,
                title: 'A1',
                stateOnPress: const State2.A1(),
              ),
              const SizedBox(height: 20),
              FAB(
                provider: state2Provider,
                title: 'A2',
                stateOnPress: const State2.A2(),
              ),
              const SizedBox(height: 20),
              FAB(
                provider: state2Provider,
                title: 'A3',
                stateOnPress: const State2.A3(),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FAB(
                provider: state3Provider,
                title: 'C1',
                stateOnPress: const State3.C1(),
              ),
              const SizedBox(height: 20),
              FAB(
                provider: state3Provider,
                title: 'C2',
                stateOnPress: const State3.C2(),
              ),
              const SizedBox(height: 20),
              FAB(
                provider: state3Provider,
                title: 'C3',
                stateOnPress: const State3.C3(),
              ),
            ],
          ),
        ],
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
    required this.stateOnPress,
  }) : super(key: key);

  final StateProvider<T> provider;

  final T stateOnPress;

  /// Must be unique
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      heroTag: title,
      child: Text(title),
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
      initialUrl: '/a1/init',
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
          ),
          B: () => MatchedRouteDetails(
            switchRouteName: BRoute.routeInfo.name,
            routeData: const BRouteData(),
          ),
          C: () => MatchedRouteDetails(
            switchRouteName: CRoute.routeInfo.name,
            routeData: const CRouteData(),
          ),
        ),
        mainSwitchRouteName: ARoute.routeInfo.name,
        redirectToQueryParam: '_redirect-1',
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
