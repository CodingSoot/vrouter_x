import 'package:flutter/material.dart';

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

  /// The widget builder.
  ///
  /// NB : The [path] is passed-in in this builder for easy use as a ValueKey.
  final Widget Function(String path) builder;
  final bool prefix;

  /// Whether to treat paths as case sensitive or not. If specified, it
  /// overrides the value of [PathWidgetSwitcher.caseSensitive].
  final bool? caseSensitive;

  List<String> get pathSegments => Uri.tryParse(path)?.pathSegments ?? [];

  PathWidget get exact => copyWith(prefix: false);

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
