import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/_core/logger.dart';
import 'package:vrouter_x/src/widgets_route_elements/sticky_query_params/sticky_query_param.dart';
import 'package:fpdart/fpdart.dart';

/// This is a route element (a VGuard) that persists a set of query parameters
/// in all its subroutes. This is a route element (a VGuard) that persists a set
/// of query parameters in all its subroutes. These query parameters are called
/// "Sticky query parameters".
///
/// When navigating inside the scope of [StickyQueryParamsScope], if you omit a
/// sticky query parameter, it will be automatically re-added. If you want to
/// remove the sticky query parameter from the url, you should set its value to
/// the specified [StickyConfig.deleteFlag].
///
/// ### Example
///
/// ```dart
/// StickyQueryParamsScope(
///   stickyConfigs: [
///     StickyConfig.exact(name: 'book-id', deleteFlag: '.'),
///     StickyConfig.prefix(prefix: 'book', deleteFlag: '*'),
///     StickyConfig.suffix(suffix: 'id'),
///     StickyConfig.regExp(regExp: RegExp(r"\d+")),
///   ],
///   stackedRoutes: [
///     ...
///   ],
/// );
/// ```
///
/// In this example, the sticky query parameters that will be persisted are :
///
/// - The query parameter named 'book-id'. It can be removed from the url by
///   setting its value to `.`.
/// - All the query parameters which name starts with 'book'. Each one can be
///   removed from the url by setting its value to `*`.
/// - All the query parameters which name ends with 'id'. Each one can be
///   removed from the url by setting its value to `_`, which is the default
///   `deleteFlag`.
/// - All the query parameters which name consists of digits only. Each one can
///   be removed from the url by setting its value to `_`, which is the default
///   `deleteFlag`.
class StickyQueryParamsScope extends VRouteElementBuilder {
  StickyQueryParamsScope({
    required this.stickyConfigs,
    required this.stackedRoutes,
  });

  /// See [VRouteElement.buildRoutes]
  final List<VRouteElement> stackedRoutes;

  /// A list of [StickyConfig]s that describe which query parameters to make
  /// sticky.
  final List<StickyConfig> stickyConfigs;

  @override
  List<VRouteElement> buildRoutes() {
    return [
      VGuard(
        beforeEnter: _beforeEnterAndUpdate,
        beforeUpdate: _beforeEnterAndUpdate,
        afterEnter: _afterEnterAndUpdate,
        afterUpdate: _afterEnterAndUpdate,
        stackedRoutes: stackedRoutes,
      ),
    ];
  }

  /// BeforeEnter/Update : Persisting phase
  ///
  /// We persist all the sticky query params that were present in the
  /// previousVRouterData and :
  /// - Are not present in the newVRouterData
  /// - Are not flagged for deletion (These have been or will be deleted in
  ///   afterEnter/Update).
  ///
  /// ### Important remark :
  ///
  /// In beforeEnter/Update, when we navigate using the vRedirector, the new
  /// vRedirector gets the same old `previousVRouterData`. So if you add a
  /// sticky query parameter in the middle of the beforeEnter/Update
  /// rederections chain, it will not be automatically persisted because the
  /// persistence relies on the queryParam to be present in the
  /// `previousVRouterData`.
  ///
  /// For this reason, if you add new sticky queryParameters using a vRedirector
  /// navigation, and you might have other subsequent vRedirector navigations
  /// you might do, make sure to **manually** persist the added sticky
  /// queryParams until the final page is **reached and accessed**.
  Future<void> _beforeEnterAndUpdate(VRedirector vRedirector) async {
    final previousVRouterData = vRedirector.previousVRouterData;
    final newVRouterData = vRedirector.newVRouterData!;

    /// The keys of the query params that were flagged for deletion.
    final flaggedQueryParamsKeys = <String>{};

    for (final config in stickyConfigs) {
      final previousStickyQueryParams = config
          .getStickyQueryParams(previousVRouterData?.queryParameters ?? {});

      previousStickyQueryParams.forEach((key, value) {
        if (value == config.deleteFlag) {
          flaggedQueryParamsKeys.add(key);
        }
      });
    }

    /// We persist the stickyQueryParams that were present in the
    /// previousVRouterData and not in the newVRouterData, and that were not
    /// flagged for deletion

    final allQueryParamsToPersist = <String, String>{};
    for (final config in stickyConfigs) {
      final previousStickyQueryParams = config
          .getStickyQueryParams(previousVRouterData?.queryParameters ?? {});

      final newStickyQueryParams =
          config.getStickyQueryParams(newVRouterData.queryParameters);

      final queryParamsToPersist = previousStickyQueryParams.filterWithKey(
          (key, value) =>
              !flaggedQueryParamsKeys.contains(key) &&
              !newStickyQueryParams.containsKey(key));

      allQueryParamsToPersist.addAll(queryParamsToPersist);
    }

    if (allQueryParamsToPersist.isEmpty) {
      return;
    }

    final newUri = Uri.parse(newVRouterData.url!);

    final updatedUri = newUri.replace(
      queryParameters: {
        ...newUri.queryParameters,
        ...allQueryParamsToPersist,
      },
    );
    logger.i('''
      Persisting the queryParams "$allQueryParamsToPersist".
      Updated url : ${updatedUri.toString()}
      ''');
    vRedirector.to(updatedUri.toString());
  }

  /// AfterEnter/Update : Clean-up phase
  ///
  /// We delete the sticky query params that are flagged for deletion (= which
  /// value equals [StickyConfig.deleteFlag]).
  ///
  /// ### Important remark :
  ///
  /// In beforeEnter/Update, when we redirect to a url, the new
  /// vRedirector gets the same old vRouterData. So if a query parameter is
  /// marked for deletion in the middle of the beforeEnter/Update rederections
  /// chain, and then deleted from within the same chain, it will be persisted
  /// again, because the `previousVRouterData` would still hold the first
  /// value of that query parameter.
  ///
  /// For this reason, we can't delete the flagged sticky query params in
  /// beforeEnter/Update. Instead, we do this in afterEnter/Update.
  Future<void> _afterEnterAndUpdate(
      BuildContext context, String? from, String to) async {
    final newUri = Uri.parse(to);

    /// The keys of the query params flagged for deletion.
    final allFlaggedQueryParams = <String, String>{};

    for (final config in stickyConfigs) {
      final newStickyQueryParams =
          config.getStickyQueryParams(newUri.queryParameters);

      final flaggedQueryParams =
          newStickyQueryParams.filter((value) => value == config.deleteFlag);

      allFlaggedQueryParams.addAll(flaggedQueryParams);
    }

    if (allFlaggedQueryParams.isEmpty) {
      return;
    }

    /// We delete the flaggedQueryParams
    final updatedQueryParams = newUri.queryParameters
        .filterWithKey((key, value) => !allFlaggedQueryParams.containsKey(key));

    final updatedUri = newUri.replace(
      queryParameters: updatedQueryParams,
    );

    logger.i('''
      Deleting the queryParams "$allFlaggedQueryParams"
      Updated url : ${updatedUri.toString()}
      ''');
    context.vRouter.to(updatedUri.toString());
  }
}
