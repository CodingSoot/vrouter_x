import 'package:vrouter/vrouter.dart';

/// Simple wrapper that wraps a [VRouteElement], so that the `path` parameter
/// becomes accessible to [VTabsScaffold] and [VTabBar].
///
/// Example :
/// ```dart
/// PathRoute(
///    path: 'home',
///    // This path variable below equals 'home'
///    buildRoute: (path) => VWidget(
///      path: path,
///      ...
///    ),
///  )
///
/// ```
class PathInfo {
  const PathInfo({
    required this.path,
    required this.buildRoute,
  });

  final String? path;

  final VRouteElement Function(String? path) buildRoute;

  VRouteElement build() => buildRoute(path);

  /// Helper method, that transforms [childPath] into an absolute path.
  ///
  /// - [absoluteParentPath] is the absolute path of the parent
  /// - [childPath] is the path of the child. It can be :
  ///   - [null] : In which case it's the same path as the parent
  ///   - absolute
  ///   - relative
  ///
  static String makeAbsolutePath(String absoluteParentPath, String? childPath) {
    //Child path is null
    if (childPath == null) {
      return absoluteParentPath;
    }
    //Child path is absolute
    if (childPath.startsWith('/')) {
      return childPath;
    }
    //Child path is relative
    return absoluteParentPath.endsWith('/')
        ? '$absoluteParentPath$childPath'
        : '$absoluteParentPath/$childPath';
  }
}
