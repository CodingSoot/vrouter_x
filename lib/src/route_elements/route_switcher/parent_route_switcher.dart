import 'package:fpdart/src/map_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vrouter_x/src/route_elements/route_elements.dart';

/// This class represents a [VxRouteSwitcher] that is the parent of another
/// [VxRouteSwitcher]. We'll refer to the first one as "the parent", and the
/// latter as "the child".
class ParentRouteSwitcher<T> {
  ParentRouteSwitcher({
    required this.provider,
    required bool Function(T state) isStateMatchingChild,
  }) : _isStateMatchingChild = isStateMatchingChild;

  final bool Function(T state) _isStateMatchingChild;

  /// The provider of the parent [VxRouteSwitcher].
  final ProviderBase<T> provider;

  /// Whether the state of the parent [VxRouteSwitcher] is matching the route
  /// containing the child [VxRouteSwitcher].
  bool isStateMatchingChild(RouteRef routeRef) {
    final state = routeRef.read(provider);
    return _isStateMatchingChild(state);
  }
}

/// TODO move somewhere
class StickyQueryParam {
  static const prefix = '_';

  static const deleteFlag = '_';

  static Map<String, String> getStickyQueryParams(
      Map<String, String> queryParameters) {
    return queryParameters
        .filterWithKey((key, value) => key.startsWith(prefix));
  }

  static Map<String, String> getNormalQueryParams(
      Map<String, String> queryParameters) {
    return queryParameters
        .filterWithKey((key, value) => !key.startsWith(prefix));
  }

  /// Returns the [uri] without the sticky query parameters.
  static Uri removeStickyQueryParams(Uri uri) {
    final normalQueryParams = uri.queryParameters.filterWithKey(
        (key, value) => !key.startsWith(StickyQueryParam.prefix));

    final result = uri.replace(
      queryParameters: normalQueryParams,
    );

    return result;
  }
}
