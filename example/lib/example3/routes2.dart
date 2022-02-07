import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vrouter_x/vrouter_x.dart';
import 'package:vrouter/vrouter.dart';

import 'main.dart';

part 'routes2.freezed.dart';

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
    path: '/a1/:id',
    name: 'A1',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const BaseWidget('A1'),
      ),
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
