import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/_core/logger.dart';
import 'package:vrouter_x/src/widgets_route_elements/sticky_query_params/sticky_query_param.dart';
import 'package:fpdart/fpdart.dart';

class StickyQueryParamsScope extends VRouteElementBuilder {
  StickyQueryParamsScope({
    required this.stickyConfigs,
    required this.stackedRoutes,
  });

  /// See [VRouteElement.buildRoutes]
  final List<VRouteElement> stackedRoutes;

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

  /// We persist all the sticky query params, except those that were flagged for
  /// deletion (which have been or will be deleted in afterEnter/Update).
  ///
  /// > NB : In beforeEnter/Update, when we redirect to a url, the new
  /// > vRedirector gets the same old vRouterData. However, this doesn't cause
  /// > any problem for persisting the the sticky queryParams.
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

    /// We persist the stickyQueryParams that were present in the previous
    /// url and not in the new url, and that are were not flagged for deletion

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

  /// Deleting the sticky query params that are flagged for deletion (= which
  /// value equals [StickyConfig.deleteFlag]).
  ///
  /// > NB : In beforeEnter/Update, when we redirect to a url, the new
  /// > vRedirector gets the same old vRouterData. For this reason, we can't
  /// > delete the flagged sticky query params in beforeEnter/Update. Instead,
  /// > we do this afterEnter/Update.
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
