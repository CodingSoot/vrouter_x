import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vrouter_x/vrouter_x.dart';
import 'package:vrouter/vrouter.dart';

import '../main.dart';

part 'switcher3_routes.freezed.dart';

@freezed
class C1RouteData extends RouteData with _$C1RouteData {
  const factory C1RouteData() = _C1RouteData;
}

class C1Route extends VxSwitchRoute<C1RouteData> {
  C1Route(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SwitchRouteInfo<C1RouteData>(
    path: '/c1/:id',
    name: 'C1',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const BaseWidget('C1'),
      ),
    ];
  }
}

@freezed
class C2RouteData extends RouteData with _$C2RouteData {
  const factory C2RouteData() = _C2RouteData;
}

class C2Route extends VxSwitchRoute<C2RouteData> {
  C2Route(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SwitchRouteInfo<C2RouteData>(
    path: '/c2/:id',
    name: 'C2',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const BaseWidget('C2'),
      ),
    ];
  }
}

@freezed
class C3RouteData extends RouteData with _$C3RouteData {
  const factory C3RouteData() = _C3RouteData;
}

class C3Route extends VxSwitchRoute<C3RouteData> {
  C3Route(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SwitchRouteInfo<C3RouteData>(
    path: '/c3/:id',
    name: 'C3',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const BaseWidget('C3'),
      ),
    ];
  }
}
