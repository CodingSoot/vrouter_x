import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/route_elements/common/route_ref.dart';

part 'redirect_to_resolver.freezed.dart';

/// [previousVRouterData] is the vRouterData of the route just before redirecting.
typedef RedirectToResolverCallback<T> = T Function(
  RouteRef routeRef,
  VRouterData previousVRouterData,
);

@freezed
class RedirectToResolver with _$RedirectToResolver {
  /// Use this resolver when you want the path parameters to be automatically
  /// extracted from the previous route's vRouterData (= the vRouterData of the
  /// route just before redirection).
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
  /// /// [previousVRouterData]
  /// redirectToResolver: RedirectToResolver.automaticPathParameters(
  ///         extractedPathParameters:
  ///             (routeRef, previousVRouterData) =>
  ///                 ['id', 'name'],
  ///       ),
  /// ```
  ///
  const factory RedirectToResolver.automaticPathParameters({
    required RedirectToResolverCallback<List<String>> extractedPathParameters,
    @Default(RedirectToResolver.defaultQueryParameters)
        RedirectToResolverCallback<Map<String, String>> queryParameters,
    @Default(RedirectToResolver.defaultHistoryState)
        RedirectToResolverCallback<Map<String, String>> historyState,
    @Default(RedirectToResolver.defaultHash)
        RedirectToResolverCallback<String> hash,
    @Default(RedirectToResolver.defaultIsReplacement)
        RedirectToResolverCallback<bool> isReplacement,
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
  /// redirectToResolver: RedirectToResolver.manualPathParameters(
  ///         pathParameters:
  ///             (routeRef, previousVRouterData) =>
  ///                 {'id': this.id, 'name' : routeRef.read(nameProvider), },
  ///       ),
  /// ```
  ///
  const factory RedirectToResolver.manualPathParameters({
    required RedirectToResolverCallback<Map<String, String>> pathParameters,
    @Default(RedirectToResolver.defaultQueryParameters)
        RedirectToResolverCallback<Map<String, String>> queryParameters,
    @Default(RedirectToResolver.defaultHistoryState)
        RedirectToResolverCallback<Map<String, String>> historyState,
    @Default(RedirectToResolver.defaultHash)
        RedirectToResolverCallback<String> hash,
    @Default(RedirectToResolver.defaultIsReplacement)
        RedirectToResolverCallback<bool> isReplacement,
  }) = _ManualPathParameters;

  /// Use this resolver when no path parameters are needed.
  ///
  /// All the callbacks ([queryParameters] - [historyState] - [hash] -
  /// [isReplacement]) correspond to the optional parameters that will be passed
  /// to [VRouterNavigator.toNamed] during navigation.
  const factory RedirectToResolver.noPathParameters({
    @Default(RedirectToResolver.defaultQueryParameters)
        RedirectToResolverCallback<Map<String, String>> queryParameters,
    @Default(RedirectToResolver.defaultHistoryState)
        RedirectToResolverCallback<Map<String, String>> historyState,
    @Default(RedirectToResolver.defaultHash)
        RedirectToResolverCallback<String> hash,
    @Default(RedirectToResolver.defaultIsReplacement)
        RedirectToResolverCallback<bool> isReplacement,
  }) = _NoPathParameters;

  static Map<String, String> defaultQueryParameters(
    RouteRef routeRef,
    VRouterData previousVRouterData,
  ) =>
      const {};

  static Map<String, String> defaultHistoryState(
    RouteRef routeRef,
    VRouterData previousVRouterData,
  ) =>
      const {};

  static String defaultHash(
    RouteRef routeRef,
    VRouterData previousVRouterData,
  ) =>
      '';

  static bool defaultIsReplacement(
    RouteRef routeRef,
    VRouterData previousVRouterData,
  ) =>
      false;
}
