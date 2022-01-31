import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/_core/errors.dart';

class PathWidgetSwitcher extends StatelessWidget {
  /// Use this constructor when you want to automatically extract the current
  /// vRouterData from the context.
  PathWidgetSwitcher({
    Key? key,
    required this.builders,
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
    required this.builders,
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
  final List<PathWidget> Function() builders;

  /// Whether to treat paths as case sensitive or not. Can be over-ridden on a
  /// per path basis.
  final bool caseSensitive;

  /// Find a matching RoutedWidget for the current vRouterData.
  Option<PathWidget> findPathWidget(VRouterData vRouterData) {
    //We need only the path when matching (without the query params or the hash)
    final currentPath = vRouterData.path ?? '';

    List<PathWidget> matches = builders().where((pathWidget) {
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
      // We make sure '*' gets sorted after something like '/'
      if (b.path == '*') {
        return -1;
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
      (pathWidget) => pathWidget.builder(),
      () => throw UnknownPathWidgetError(path: vRouterData.path ?? ''),
    );

    //TODO keys
    return AnimatedSwitcher(
      duration: duration,
      child: child,
      transitionBuilder: transitionBuilder,
    );
  }
}

/// A path and associated widget builder.
class PathWidget {
  PathWidget({
    required this.path,
    required this.builder,
    this.prefix = true,
    this.caseSensitive,
  }) : assert(
          path.startsWith('/') || path == '*',
          "The path should be absolute, or be equal to the wildcard '*'.",
        );

  final String path;
  final T Function<T extends Widget>() builder;
  final bool prefix;

  /// Whether to treat paths as case sensitive or not. If specified, it
  /// overrides the value of [PathWidgetSwitcher.caseSensitive].
  final bool? caseSensitive;

  List<String> get pathSegments => Uri.tryParse(path)?.pathSegments ?? [];

  PathWidget get exact => copyWith(prefix: false);

  PathWidget copyWith({
    String? path,
    T Function<T extends Widget>()? builder,
    bool? prefix,
    bool? caseSensitive,
  }) {
    return PathWidget(
      path: path ?? this.path,
      builder: builder ?? this.builder,
      prefix: prefix ?? this.prefix,
      caseSensitive: caseSensitive ?? this.caseSensitive,
    );
  }
}
