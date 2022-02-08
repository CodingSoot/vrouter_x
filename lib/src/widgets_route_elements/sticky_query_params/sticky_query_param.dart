import 'package:fpdart/fpdart.dart';

/// A Sticky query parameter is a query parameter that is persisted during
/// navigation.
class StickyConfig {
  StickyConfig.exact({
    required String parameterName,
    this.deleteFlag = '_',
  }) {
    hasMatch = (other) => parameterName == other;
  }

  StickyConfig.prefix({
    required String prefix,
    this.deleteFlag = '_',
  }) {
    hasMatch = (other) => other.startsWith(prefix);
  }

  StickyConfig.suffix({
    required String suffix,
    this.deleteFlag = '_',
  }) {
    hasMatch = (other) => other.endsWith(suffix);
  }

  StickyConfig.regExp({
    required RegExp regExp,
    this.deleteFlag = '_',
  }) {
    hasMatch = (other) => regExp.hasMatch(other);
  }

  late final bool Function(String other) hasMatch;

  final String deleteFlag;

  /// Returns the sticky query parameters among the provided
  /// [queryParameters]
  Map<String, String> getStickyQueryParams(
      Map<String, String> queryParameters) {
    return queryParameters.filterWithKey((key, value) => hasMatch(key));
  }

  /// Returns the non-sticky query parameters among the provided
  /// [queryParameters]
  Map<String, String> getNormalQueryParams(
      Map<String, String> queryParameters) {
    return queryParameters.filterWithKey((key, value) => !hasMatch(key));
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
