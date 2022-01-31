import 'package:vrouter/vrouter.dart';
import 'package:vrouter_x/src/_core/errors.dart';

class VxUtils {
  /// Extracts the path parameters specified in [pathParamsToExtract] from the
  /// [vRouterData].
  ///
  /// Throws a [PathParamNotFoundError] if a path parameter is not found in the
  /// [vRouterData].
  static Map<String, String> extractPathParamsFromVRouterData(
      VRouterData vRouterData, List<String> pathParamsToExtract) {
    final result = <String, String>{};

    final vRouterDataPathParams = vRouterData.pathParameters;

    for (final pathParam in pathParamsToExtract) {
      if (!vRouterDataPathParams.keys.contains(pathParam)) {
        throw PathParamNotFoundError(
          pathParam: pathParam,
          vRouterData: vRouterData,
        );
      }
      result.putIfAbsent(pathParam, () => vRouterDataPathParams[pathParam]!);
    }

    return result;
  }
}
