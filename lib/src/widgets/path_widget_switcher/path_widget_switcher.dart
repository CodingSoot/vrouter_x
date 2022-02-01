import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/_core/errors.dart';
import 'package:vrouter_x/src/widgets/path_widget_switcher/path_widget.dart';

class PathWidgetSwitcher extends StatelessWidget {
  /// Use this constructor when you want to automatically extract the current
  /// vRouterData from the context.
  PathWidgetSwitcher({
    Key? key,
    required this.pathWidgets,
    this.duration = const Duration(milliseconds: 400),
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.caseSensitive = false,
  }) : super(key: key) {
    getVRouterData = (context) => context.vRouter;
  }

  /// Use this constructor when you want to manually pass-in the current
  /// vRouterData.
  PathWidgetSwitcher.fromVRouterData({
    Key? key,
    required VRouterData vRouterData,
    required this.pathWidgets,
    this.duration = const Duration(milliseconds: 400),
    this.transitionBuilder = AnimatedSwitcher.defaultTransitionBuilder,
    this.caseSensitive = false,
  }) : super(key: key) {
    getVRouterData = (context) => vRouterData;
  }

  late final VRouterData Function(BuildContext context) getVRouterData;

  /// Duration of the animation when switching widgets
  final Duration duration;

  /// Allows custom animations when switching widgets, defaults to `AnimatedSwitcher.defaultTransitionBuilder`
  final AnimatedSwitcherTransitionBuilder transitionBuilder;

  /// A list of all matching paths and their associated builder method.
  final List<PathWidget> pathWidgets;

  /// Whether to treat paths as case sensitive or not. Can be over-ridden on a
  /// per path basis.
  final bool caseSensitive;

  /// Find a matching RoutedWidget for the current vRouterData.
  Option<PathWidget> findPathWidget(VRouterData vRouterData) {
    //We need only the path when matching (without the query params or the hash)
    final currentPath = vRouterData.path ?? '';

    List<PathWidget> matches = pathWidgets.where((pathWidget) {
      if (pathWidget.path == '*') {
        return true;
      }

      final regEx = pathToRegExp(
        pathWidget.path,
        prefix: pathWidget.prefix,
        caseSensitive: pathWidget.caseSensitive ?? caseSensitive,
      );

      if (pathWidget.prefix) {
        return regEx.matchAsPrefix(currentPath) != null;
      }
      return regEx.hasMatch(currentPath);
    }).toList();

    final matchOption = getMostSpecificMatch(currentPath, matches);
    return matchOption;
  }

  /// Given a list of possible matches, return the most exact one.
  Option<PathWidget> getMostSpecificMatch(
    String currentPath,
    List<PathWidget> matches,
  ) {
    // Return none if we have no matches
    if (matches.isEmpty) {
      return none();
    }

    // If we have an exact match, use that
    for (final m in matches) {
      if (m.path == currentPath) {
        return some(m);
      }
    }

    // Next, take the first non-prefixed match we see
    for (final m in matches) {
      if (!m.prefix) {
        return some(m);
      }
    }
    // Last resort, we sort by the number of path segments first, and then by
    // the length of the path.
    matches.sort((a, b) {
      // Wildcard paths '*' should be last in the list, and sorted according to
      // their original order
      if (b.path == '*') {
        return -1;
      }
      if (a.path == '*') {
        return 1;
      }

      final firstComparison =
          b.pathSegments.length.compareTo(a.pathSegments.length);

      if (firstComparison != 0) {
        return firstComparison;
      }

      return b.path.length.compareTo(a.path.length);
    });
    return some(matches[0]);
  }

  @override
  Widget build(BuildContext context) {
    final vRouterData = getVRouterData(context);

    final pathWidgetOption = findPathWidget(vRouterData);

    final child = pathWidgetOption.match(
      (pathWidget) => pathWidget.builder(pathWidget.path),
      () => throw UnknownPathWidgetError(path: vRouterData.path ?? ''),
    );

    return AnimatedSwitcher(
      duration: duration,
      child: child,
      transitionBuilder: transitionBuilder,
    );
  }
}
