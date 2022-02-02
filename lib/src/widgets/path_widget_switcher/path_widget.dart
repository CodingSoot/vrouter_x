import 'package:flutter/material.dart';
import 'package:vrouter_x/src/widgets/path_widget_switcher/path_widget_switcher.dart';

/// A path and associated widget builder.
class PathWidget {
  PathWidget({
    required this.path,
    required this.builder,
    this.prefix = false,
    this.caseSensitive,
  }) : assert(
          path.startsWith('/') || path == '*',
          "The path should be absolute, or be equal to the wildcard '*'.",
        );

  /// The path to match.
  ///
  /// It should be absolute (should start with a '/'), or be equal to the
  /// wildcard '*'.
  final String path;

  /// The widget builder.
  ///
  /// NB : The [path] is passed-in in this builder for easy use as a ValueKey.
  final Widget Function(String path) builder;

  /// Whether to treat this path as a prefix.
  ///
  /// Defaults to `false`.
  final bool prefix;

  /// Whether to treat paths as case sensitive or not. If specified, it
  /// overrides the value of [PathWidgetSwitcher.caseSensitive].
  final bool? caseSensitive;

  List<String> get pathSegments => Uri.tryParse(path)?.pathSegments ?? [];

  PathWidget get asPrefix => copyWith(prefix: true);

  PathWidget copyWith({
    String? path,
    Widget Function(String path)? builder,
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
