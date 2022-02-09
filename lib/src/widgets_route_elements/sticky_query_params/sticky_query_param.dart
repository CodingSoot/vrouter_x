import 'package:fpdart/fpdart.dart';
import 'package:vrouter_x/src/widgets_route_elements/sticky_query_params/sticky_query_params_scope.dart';

/// A Sticky query parameter is a query parameter that is automatically
/// persisted when navigating between the routes of the
/// [StickyQueryParamsScope].
///
/// In other words, when navigating inside the scope of
/// [StickyQueryParamsScope], if you omit a sticky query parameter, it will be
/// automatically added. If you want to delete the sticky query parameter, you
/// should set its value to the specified [StickyConfig.deleteFlag]
///
/// A [StickyConfig] allows you to describe what query parameters to make
/// sticky, and what `deleteFlag` to use to delete them.

class StickyConfig {
  /// Use this if you want to match a query parameter that has the exact name
  /// [name].
  StickyConfig.exact({
    required String name,
    this.deleteFlag = '_',
  }) {
    isSticky = (other) => name == other;
  }

  /// Use this if you want to match all query parameters which name starts with
  /// [prefix]
  StickyConfig.prefix({
    required String prefix,
    this.deleteFlag = '_',
  }) {
    isSticky = (other) => other.startsWith(prefix);
  }

  /// Use this if you want to match all query parameters which name ends with
  /// [suffix]
  StickyConfig.suffix({
    required String suffix,
    this.deleteFlag = '_',
  }) {
    isSticky = (other) => other.endsWith(suffix);
  }

  /// Use this if you want to match all query parameters which name matches the
  /// [regExp]
  StickyConfig.regExp({
    required RegExp regExp,
    this.deleteFlag = '_',
  }) {
    isSticky = (other) => regExp.hasMatch(other);
  }

  /// Whether the given query parameter is sticky according to this
  /// [StickyConfig].
  late final bool Function(String queryParamName) isSticky;

  /// The value you should set a sticky query parameter to delete it.
  final String deleteFlag;

  /// Returns the sticky query parameters among the provided [queryParameters]
  Map<String, String> getStickyQueryParams(
      Map<String, String> queryParameters) {
    return queryParameters.filterWithKey((key, value) => isSticky(key));
  }

  /// Returns the non-sticky query parameters among the provided
  /// [queryParameters]
  Map<String, String> getNormalQueryParams(
      Map<String, String> queryParameters) {
    return queryParameters.filterWithKey((key, value) => !isSticky(key));
  }

  /// Returns the [uri] without the sticky query parameters.
  Uri removeStickyQueryParams(Uri uri) {
    final normalQueryParams = getNormalQueryParams(uri.queryParameters);

    final result = uri.replace(
      queryParameters: normalQueryParams,
    );

    return result;
  }
}
