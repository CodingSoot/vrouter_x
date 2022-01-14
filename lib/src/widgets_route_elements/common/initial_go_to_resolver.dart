import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vrouter/vrouter.dart';

part 'initial_go_to_resolver.freezed.dart';

typedef GoToResolverCallback<T> = T Function(
  int previousTabIndex,
  int nextTabIndex,
  VRouterData previousTabVRouterData,
);

@freezed
class InitialGoToResolver with _$InitialGoToResolver {
  /// Use this resolver when you want the path parameters to be automatically
  /// extracted from the previous tab's vRouterData.
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
  /// /// The path parameters 'id' and 'name' will be extracted from the
  /// /// [previousTabVRouterData]
  /// initialGoToResolver: InitialGoToResolver.automaticPathParameters(
  ///         extractedPathParameters:
  ///             (previousTabIndex, nextTabIndex, previousTabVRouterData) =>
  ///                 ['id', 'name'],
  ///       ),
  /// ```
  ///
  const factory InitialGoToResolver.automaticPathParameters({
    required GoToResolverCallback<List<String>> extractedPathParameters,
    @Default(InitialGoToResolver.defaultQueryParameters)
        GoToResolverCallback<Map<String, String>> queryParameters,
    @Default(InitialGoToResolver.defaultHistoryState)
        GoToResolverCallback<Map<String, String>> historyState,
    @Default(InitialGoToResolver.defaultHash) GoToResolverCallback<String> hash,
    @Default(InitialGoToResolver.defaultIsReplacement)
        GoToResolverCallback<bool> isReplacement,
  }) = _AutomaticPathParameters;

  /// Use this resolver when you want to manually provide the path parameters
  /// that will be  passed to [VRouterNavigator.toNamed] during navigation.
  ///
  /// All the other callbacks ([queryParameters] - [historyState] - [hash] -
  /// [isReplacement]) correspond to the optional parameters that will be passed
  /// to [VRouterNavigator.toNamed] during navigation.
  ///
  /// Example :
  ///
  /// ```dart
  /// /// We manually specify the pathParameters.
  /// initialGoToResolver: InitialGoToResolver.manualPathParameters(
  ///         pathParameters:
  ///             (previousTabIndex, nextTabIndex, previousTabVRouterData) =>
  ///                 {'id': this.id, 'name' : this.name, },
  ///       ),
  /// ```
  ///
  const factory InitialGoToResolver.manualPathParameters({
    required GoToResolverCallback<Map<String, String>> pathParameters,
    @Default(InitialGoToResolver.defaultQueryParameters)
        GoToResolverCallback<Map<String, String>> queryParameters,
    @Default(InitialGoToResolver.defaultHistoryState)
        GoToResolverCallback<Map<String, String>> historyState,
    @Default(InitialGoToResolver.defaultHash) GoToResolverCallback<String> hash,
    @Default(InitialGoToResolver.defaultIsReplacement)
        GoToResolverCallback<bool> isReplacement,
  }) = _ManualPathParameters;

  /// Use this resolver when no path parameters are needed.
  ///
  /// All the callbacks ([queryParameters] - [historyState] - [hash] -
  /// [isReplacement]) correspond to the optional parameters that will be passed
  /// to [VRouterNavigator.toNamed] during navigation.
  const factory InitialGoToResolver.noPathParameters({
    @Default(InitialGoToResolver.defaultQueryParameters)
        GoToResolverCallback<Map<String, String>> queryParameters,
    @Default(InitialGoToResolver.defaultHistoryState)
        GoToResolverCallback<Map<String, String>> historyState,
    @Default(InitialGoToResolver.defaultHash) GoToResolverCallback<String> hash,
    @Default(InitialGoToResolver.defaultIsReplacement)
        GoToResolverCallback<bool> isReplacement,
  }) = _NoPathParameters;

  static Map<String, String> defaultQueryParameters(
    int previousTabIndex,
    int nextTabIndex,
    VRouterData previousTabVRouterData,
  ) =>
      const {};

  static Map<String, String> defaultHistoryState(
    int previousTabIndex,
    int nextTabIndex,
    VRouterData previousTabVRouterData,
  ) =>
      const {};

  static String defaultHash(
    int previousTabIndex,
    int nextTabIndex,
    VRouterData previousTabVRouterData,
  ) =>
      '';

  static bool defaultIsReplacement(
    int previousTabIndex,
    int nextTabIndex,
    VRouterData previousTabVRouterData,
  ) =>
      false;
}
