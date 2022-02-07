import 'package:fpdart/fpdart.dart';
import 'package:vrouter_x/src/route_elements/route_elements.dart';

/// A Sticky query parameter is a query parameter that is persisted during
/// navigation.
class StickyQueryParam {
  static const prefix = '_';

  static const deleteFlag = '_';

  /// Returns the sticky query parameters among the provided
  /// [queryParameters]
  static Map<String, String> getStickyQueryParams(
      Map<String, String> queryParameters) {
    return queryParameters
        .filterWithKey((key, value) => key.startsWith(prefix));
  }

  /// Returns the non-sticky query parameters among the provided
  /// [queryParameters]
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
