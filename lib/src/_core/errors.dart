import 'package:vrouter/vrouter.dart';

/// Thrown when the [pathParam] was not found in the specified [vRouterData].
class PathParamNotFoundError extends Error {
  PathParamNotFoundError({
    required this.pathParam,
    required this.vRouterData,
  });

  final String pathParam;

  final VRouterData vRouterData;

  @override
  String toString() {
    return '''
    The path parameter "$pathParam" was not found in the vRouterData.
    Available path parameters : ${vRouterData.pathParameters.keys.join(" - ")}
    ''';
  }
}

class RouteNotFoundError extends Error {
  RouteNotFoundError({
    this.customMessage = '',
  });

  final String? customMessage;

  @override
  String toString() {
    return '''
    Error : Route not found.
    $customMessage
    ''';
  }
}

/// Thrown when the current vRouterData's path has no matching
/// PathWidget.
class UnknownPathWidgetError extends Error {
  final String path;

  UnknownPathWidgetError({required this.path});

  @override
  String toString() => '''
    The path '$path' has no matching PathWidget.
    Consider using PathWidget(path: '*', builder: myUnknownBuilder) at the 
    bottom of your PathWidgetSwitcher builders to catch any wrong route.
    ''';
}

class UnreachableError extends Error {
  UnreachableError({
    this.customMessage = '',
  });

  final String? customMessage;

  @override
  String toString() {
    return '''
    Error : This part of the code should be unreachable.
    $customMessage
    ''';
  }
}
