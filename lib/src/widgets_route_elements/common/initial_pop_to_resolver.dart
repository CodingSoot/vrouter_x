import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vrouter/vrouter.dart';

part 'initial_pop_to_resolver.freezed.dart';

typedef PopToResolverCallback<T> = T Function(
  VRouterData stackedWidgetVRouterData,
);

@freezed
class InitialPopToResolver with _$InitialPopToResolver {
  /// Use this resolver when you want the path parameters to be automatically
  /// extracted from the stacked route's vRouterData.
  ///
  /// The list of the names of the path parameters that will be extracted should
  /// be provided using the [extractedPathParameters] callback.
  ///
  /// All the other callbacks ([queryParameters] - [historyState] - [hash] -
  /// [isReplacement]) correspond to the optional parameters that will be passed
  /// to [VRouterNavigator.toNamed] during navigation.
  ///
  /// Example :
  ///
  /// ```dart
  /// /// The path parameters 'id' and 'name' will be extracted from
  /// /// the [stackedWidgetVRouterData]
  /// initialPopToResolver: InitialPopToResolver.automaticPathParameters(
  ///         extractedPathParameters: (stackedWidgetVRouterData) =>
  ///             ['id', 'name'],
  ///       ),
  /// ```
  ///
  const factory InitialPopToResolver.automaticPathParameters({
    required PopToResolverCallback<List<String>> extractedPathParameters,
    @Default(InitialPopToResolver.defaultQueryParameters)
        PopToResolverCallback<Map<String, String>> queryParameters,
    @Default(InitialPopToResolver.defaultHistoryState)
        PopToResolverCallback<Map<String, String>> historyState,
    @Default(InitialPopToResolver.defaultHash)
        PopToResolverCallback<String> hash,
    @Default(InitialPopToResolver.defaultIsReplacement)
        PopToResolverCallback<bool> isReplacement,
  }) = _AutomaticPathParameters;

  /// Use this resolver when you want to manually provide the path parameters
  /// that will be passed to [VRouterNavigator.toNamed] during navigation.
  ///
  /// All the other callbacks ([queryParameters] - [historyState] - [hash] -
  /// [isReplacement]) correspond to the optional parameters that will be passed
  /// to [VRouterNavigator.toNamed] during navigation.
  ///
  /// Example :
  ///
  /// ```dart
  /// /// We manually specify the pathParameters.
  /// initialPopToResolver: InitialPopToResolver.manualPathParameters(
  ///         pathParameters: (stackedWidgetVRouterData) =>
  ///                 {'id': this.id, 'name' : this.name, },
  ///       ),
  /// ```
  ///
  const factory InitialPopToResolver.manualPathParameters({
    required PopToResolverCallback<Map<String, String>> pathParameters,
    @Default(InitialPopToResolver.defaultQueryParameters)
        PopToResolverCallback<Map<String, String>> queryParameters,
    @Default(InitialPopToResolver.defaultHistoryState)
        PopToResolverCallback<Map<String, String>> historyState,
    @Default(InitialPopToResolver.defaultHash)
        PopToResolverCallback<String> hash,
    @Default(InitialPopToResolver.defaultIsReplacement)
        PopToResolverCallback<bool> isReplacement,
  }) = _ManualPathParameters;

  /// Use this resolver when no path parameters are needed.
  ///
  /// All the callbacks ([queryParameters] - [historyState] - [hash] -
  /// [isReplacement]) correspond to the optional parameters that will be passed
  /// to [VRouterNavigator.toNamed] during navigation.
  const factory InitialPopToResolver.noPathParameters({
    @Default(InitialPopToResolver.defaultQueryParameters)
        PopToResolverCallback<Map<String, String>> queryParameters,
    @Default(InitialPopToResolver.defaultHistoryState)
        PopToResolverCallback<Map<String, String>> historyState,
    @Default(InitialPopToResolver.defaultHash)
        PopToResolverCallback<String> hash,
    @Default(InitialPopToResolver.defaultIsReplacement)
        PopToResolverCallback<bool> isReplacement,
  }) = _NoPathParameters;

  static Map<String, String> defaultQueryParameters(
    VRouterData stackedWidgetVRouterData,
  ) =>
      const {};

  static Map<String, String> defaultHistoryState(
    VRouterData stackedWidgetVRouterData,
  ) =>
      const {};

  static String defaultHash(
    VRouterData stackedWidgetVRouterData,
  ) =>
      '';

  static bool defaultIsReplacement(
    VRouterData stackedWidgetVRouterData,
  ) =>
      false;
}
