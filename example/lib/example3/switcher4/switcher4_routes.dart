import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vrouter_x/vrouter_x.dart';
import 'package:vrouter/vrouter.dart';

import '../main.dart';

part 'switcher4_routes.freezed.dart';

@freezed
class D1RouteData extends RouteData with _$D1RouteData {
  const factory D1RouteData() = _D1RouteData;
}

class D1Route extends VxSwitchRoute<D1RouteData> {
  D1Route(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SwitchRouteInfo<D1RouteData>(
    path: '/d1/:id',
    name: 'D1',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const BaseWidget('D1'),
      ),
    ];
  }
}

@freezed
class D2RouteData extends RouteData with _$D2RouteData {
  const factory D2RouteData() = _D2RouteData;
}

class D2Route extends VxSwitchRoute<D2RouteData> {
  D2Route(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SwitchRouteInfo<D2RouteData>(
    path: '/d2/:id',
    name: 'D2',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const BaseWidget('D2'),
      ),
    ];
  }
}

@freezed
class D3RouteData extends RouteData with _$D3RouteData {
  const factory D3RouteData() = _D3RouteData;
}

class D3Route extends VxSwitchRoute<D3RouteData> {
  D3Route(RouteRef routeRef)
      : super(
          routeInfoInstance: routeInfo,
          routeRef: routeRef,
        );

  static final routeInfo = SwitchRouteInfo<D3RouteData>(
    path: '/d3/:id',
    name: 'D3',
  );

  @override
  List<VRouteElement> buildRoutesX() {
    return [
      VWidget(
        path: null,
        widget: const BaseWidget('D3'),
      ),
    ];
  }
}
