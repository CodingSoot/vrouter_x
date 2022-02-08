import 'package:example/example3/switcher4/switcher4_routes.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vrouter_x/vrouter_x.dart';
import 'package:vrouter/vrouter.dart';

import '../main.dart';
part 'switcher2_routes.freezed.dart';

@freezed
class A1RouteData extends RouteData with _$A1RouteData {
  const factory A1RouteData() = _A1RouteData;
}

class A1Route extends VxSwitchRoute<A1RouteData> {
  A1Route(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SwitchRouteInfo<A1RouteData>(
    path: D1Route.routeInfo.path,
    name: 'A1',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VxRouteSwitcher<State4>.withMainRedirection(
        routeRef,
        path: null,
        switchRoutes: [
          D1Route(routeRef),
          D2Route(routeRef),
          D3Route(routeRef),
        ],
        provider: state4Provider,
        mapStateToSwitchRoute: (state, vRouterData) => state.when(
          D1: () => MatchedRouteDetails(
            switchRouteName: D1Route.routeInfo.name,
            routeData: const D1RouteData(),
            pathParameters: {'id': 'initial'},
          ),
          D2: () => MatchedRouteDetails(
            switchRouteName: D2Route.routeInfo.name,
            routeData: const D2RouteData(),
            pathParameters: {'id': 'initial'},
          ),
          D3: () => MatchedRouteDetails(
            switchRouteName: D3Route.routeInfo.name,
            routeData: const D3RouteData(),
            pathParameters: {'id': 'initial'},
          ),
        ),
        mainSwitchRouteName: D1Route.routeInfo.name,
        redirectQueryParamName: 'redirect-4',
        parentRouteSwitchers: [
          ParentRouteSwitcher<State1>(
            provider: state1Provider,
            redirectQueryParamName: 'redirect-1',
            isStateMatchingChild: (state) =>
                state.whenOrNull(
                  A: () => true,
                ) ??
                false,
          ),
          ParentRouteSwitcher<State2>(
            provider: state2Provider,
            redirectQueryParamName: 'redirect-2',
            isStateMatchingChild: (state) =>
                state.whenOrNull(
                  A1: () => true,
                ) ??
                false,
          )
        ],
      )
    ];
  }
}

@freezed
class A2RouteData extends RouteData with _$A2RouteData {
  const factory A2RouteData() = _A2RouteData;
}

class A2Route extends VxSwitchRoute<A2RouteData> {
  A2Route(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SwitchRouteInfo<A2RouteData>(
    path: '/a2/:id',
    name: 'A2',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const BaseWidget('A2'),
      ),
    ];
  }
}

@freezed
class A3RouteData extends RouteData with _$A3RouteData {
  const factory A3RouteData() = _A3RouteData;
}

class A3Route extends VxSwitchRoute<A3RouteData> {
  A3Route(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SwitchRouteInfo<A3RouteData>(
    path: '/a3/:id',
    name: 'A3',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const BaseWidget('A3'),
      ),
    ];
  }
}
