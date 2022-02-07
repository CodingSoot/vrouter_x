import 'package:example/example3/main.dart';
import 'package:example/example3/routes2.dart';
import 'package:example/example3/routes3.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vrouter_x/vrouter_x.dart';
import 'package:vrouter/vrouter.dart';

part 'routes1.freezed.dart';

@freezed
class ARouteData extends RouteData with _$ARouteData {
  const factory ARouteData() = _ARouteData;
}

class ARoute extends VxSwitchRoute<ARouteData> {
  ARoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SwitchRouteInfo<ARouteData>(
    path: '/a1/initial',
    name: 'A',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VxRouteSwitcher<State2>.withMainRedirection(
        routeRef,
        path: null,
        switchRoutes: [
          A1Route(routeRef),
          A2Route(routeRef),
          A3Route(routeRef),
        ],
        provider: state2Provider,
        mapStateToSwitchRoute: (state, vRouterData) => state.when(
          A1: () => MatchedRouteDetails(
            switchRouteName: A1Route.routeInfo.name,
            routeData: const A1RouteData(),
            pathParameters: {'id': 'initial'},
          ),
          A2: () => MatchedRouteDetails(
            switchRouteName: A2Route.routeInfo.name,
            routeData: const A2RouteData(),
            pathParameters: {'id': 'initial'},
          ),
          A3: () => MatchedRouteDetails(
            switchRouteName: A3Route.routeInfo.name,
            routeData: const A3RouteData(),
            pathParameters: {'id': 'initial'},
          ),
        ),
        mainSwitchRouteName: A1Route.routeInfo.name,
        redirectToQueryParam: '_redirect-2',
        parentRouteSwitchers: [
          ParentRouteSwitcher<State1>(
            provider: state1Provider,
            isStateMatchingChild: (state) =>
                state.whenOrNull(
                  A: () => true,
                ) ??
                false,
          )
        ],
      )
    ];
  }
}

@freezed
class BRouteData extends RouteData with _$BRouteData {
  const factory BRouteData() = _BRouteData;
}

class BRoute extends VxSwitchRoute<BRouteData> {
  BRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SwitchRouteInfo<BRouteData>(
    path: '/b',
    name: 'B',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const BaseWidget('B'),
      ),
    ];
  }
}

@freezed
class CRouteData extends RouteData with _$CRouteData {
  const factory CRouteData() = _CRouteData;
}

class CRoute extends VxSwitchRoute<CRouteData> {
  CRoute(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SwitchRouteInfo<CRouteData>(
    path: '/c1/initial',
    name: 'C',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VxRouteSwitcher<State3>.withMainRedirection(routeRef,
          path: null,
          switchRoutes: [
            C1Route(routeRef),
            C2Route(routeRef),
            C3Route(routeRef),
          ],
          provider: state3Provider,
          mapStateToSwitchRoute: (state, vRouterData) => state.when(
                C1: () => MatchedRouteDetails(
                  switchRouteName: C1Route.routeInfo.name,
                  routeData: const C1RouteData(),
                  pathParameters: {'id': 'initial'},
                ),
                C2: () => MatchedRouteDetails(
                  switchRouteName: C2Route.routeInfo.name,
                  routeData: const C2RouteData(),
                  pathParameters: {'id': 'initial'},
                ),
                C3: () => MatchedRouteDetails(
                  switchRouteName: C3Route.routeInfo.name,
                  routeData: const C3RouteData(),
                  pathParameters: {'id': 'initial'},
                ),
              ),
          mainSwitchRouteName: C1Route.routeInfo.name,
          redirectToQueryParam: '_redirect-3',
          parentRouteSwitchers: [
            ParentRouteSwitcher<State1>(
              provider: state1Provider,
              isStateMatchingChild: (state) =>
                  state.whenOrNull(
                    C: () => true,
                  ) ??
                  false,
            )
          ])
    ];
  }
}
