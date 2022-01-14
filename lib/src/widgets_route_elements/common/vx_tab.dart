import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

/// Used internally to hold information about a tab.
class VxTab {
  const VxTab(
    this.lastVisitedUrl,
    this.routeName,
    this.child,
  );

  /// The last visited url in the tab.
  ///
  /// Null when the tab has not been visited before.
  final String? lastVisitedUrl;

  /// The route name. Used to initially navigate to the tab when it has not been
  /// visited before, using [VRouterNavigator.toNamed].
  final String routeName;

  /// The last rendered widget of the tab.
  final Widget child;

  @override
  String toString() =>
      'VxTab(lastVisitedUrl: $lastVisitedUrl, routeName: $routeName, child: $child)';

  VxTab copyWith({
    String? lastVisitedUrl,
    String? routeName,
    Widget? child,
  }) {
    return VxTab(
      lastVisitedUrl ?? this.lastVisitedUrl,
      routeName ?? this.routeName,
      child ?? this.child,
    );
  }
}
