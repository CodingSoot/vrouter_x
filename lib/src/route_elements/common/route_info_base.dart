import 'package:vrouter/vrouter.dart';

abstract class RouteInfoBase {
  RouteInfoBase({required this.path, required this.name});

  /// Same as [VNester.path].
  ///
  /// If you want to match:
  /// - An absolute path, start with “/”
  /// - A relative path, do NOT start with “/”
  /// - The parent path, use a null path
  final String? path;

  /// Same as [VNester.name].
  final String name;
}
