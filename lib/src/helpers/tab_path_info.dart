import 'package:vrouter/vrouter.dart';

/// Simple wrapper that wraps a [VRouteElement], so that the `path` parameter
/// becomes accessible to [VxTabBar].
///
/// It also provides the [aliases] that should be passed into the [VRouteElement],
/// so that the [VxTabBar] functions properly.
///
/// Example :
/// ```dart
/// TabPathInfo(
///    path: 'home',
///    // This path variable below equals 'home'
///    buildRoute: (path, aliases) => VWidget(
///      path: path,
///      aliases: aliases,
///      ...
///    ),
///  )
///
/// ```
class TabPathInfo {
  const TabPathInfo({
    required this.path,
    required this.buildRoute,
  });

  final String? path;

  final VRouteElement Function(String? path, List<String> aliases) buildRoute;

  VRouteElement build(List<String>? aliases) => buildRoute(path, aliases ?? []);
}
