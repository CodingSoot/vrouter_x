import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/_core/errors.dart';
import 'package:vrouter_x/src/widgets/path_widget_switcher/path_widget.dart';

/// Declaratively switch child widgets based on the current vRouterData (Or based on a vRouterData you provide).
///
/// This is useful in 2 primary use cases:
/// - When you have scaffolding around your Navigator, like a SideBar or a TitleBar and you would like it to react to location changes
/// - When multiple paths resolve to the same Page and you want to move subsequent routing further down the tree
///
/// ### Example :
/// ```dart
/// class SideBar extends StatelessWidget {
///     Widget build(_){
///      return PathWidgetSwitcher(
///         pathWidgets: [
///           PathWidget(
///             path: '/', //or MainRoute.routeInfo.path!
///             builder: (path) => const MainMenu(),
///           ),
///           PathWidget(
///             path: '/profile', //or ProfileRoute.routeInfo.path!
///             builder: (path) => const ProfileMenu(),
///           ),
///         ]);
///     }
/// }
/// ```
class PathWidgetSwitcher extends StatelessWidget {
  /// Use this constructor when you want to automatically extract the current
  /// vRouterData from the context.
  PathWidgetSwitcher({
    Key? key,
    required this.pathWidgets,
    this.builder = defaultBuilder,
    this.caseSensitive = false,
  })  : vRouterDataOption = none(),
        super(key: key);

  /// Use this constructor when you want to manually pass-in the current
  /// vRouterData.
  PathWidgetSwitcher.fromVRouterData({
    Key? key,
    required VRouterData vRouterData,
    required this.pathWidgets,
    this.builder = defaultBuilder,
    this.caseSensitive = false,
  })  : vRouterDataOption = some(vRouterData),
        super(key: key);

  /// A list of all matching paths and their associated builder method.
  final List<PathWidget> pathWidgets;

  /// Whether to treat paths as case sensitive or not. Can be over-ridden on a
  /// per path basis.
  final bool caseSensitive;

  /// This will hold some() when the vRouterData has been provided in the
  /// constructor, and none() otherwise.
  final Option<VRouterData> vRouterDataOption;

  /// The builder for the current pathWidget's child.
  ///
  /// You can for example use an [AnimatedSwitcher], or a package such as
  /// animated_size_and_fade to animate the transition between different
  /// children when the current pathWidget changes.
  ///
  /// Defaults to [defaultBuilder].
  final Widget Function(BuildContext context, Widget child) builder;

  static Widget defaultBuilder(BuildContext context, Widget child) => child;

  /// Find a matching PathWidget for the current vRouterData.
  Option<PathWidget> _findPathWidget(VRouterData vRouterData) {
    // When matching, we only need the path (without the query params or the
    // hash)
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

    final matchOption = _getMostSpecificMatch(currentPath, matches);
    return matchOption;
  }

  /// Given a list of possible matches, return the most exact one.
  Option<PathWidget> _getMostSpecificMatch(
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
    final vRouterData = vRouterDataOption.getOrElse(() => context.vRouter);

    final pathWidgetOption = _findPathWidget(vRouterData);

    final child = pathWidgetOption.match(
      (pathWidget) => pathWidget.builder(pathWidget.path),
      () => throw UnknownPathWidgetError(path: vRouterData.path ?? ''),
    );

    return builder(context, child);
  }
}
