import 'package:fpdart/src/map_extension.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vrouter_x/src/route_elements/route_elements.dart';

/// This class represents a [VxRouteSwitcher] that is the parent of another
/// [VxRouteSwitcher]. We'll refer to the first one as "the parent", and the
/// latter as "the child".
class ParentRouteSwitcher<T> {
  ParentRouteSwitcher({
    required this.provider,
    required bool Function(T state) isStateMatchingChild,
  }) : _isStateMatchingChild = isStateMatchingChild;

  final bool Function(T state) _isStateMatchingChild;

  /// The provider of the parent [VxRouteSwitcher].
  final ProviderBase<T> provider;

  /// Whether the state of the parent [VxRouteSwitcher] is matching the route
  /// containing the child [VxRouteSwitcher].
  bool isStateMatchingChild(RouteRef routeRef) {
    final state = routeRef.read(provider);
    return _isStateMatchingChild(state);
  }
}
