import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple wrapper for the different possible riverpod refs, with only reading
/// allowed.

class RouteRef {
  RouteRef.fromRef(Ref ref) : _reader = ref.read;

  RouteRef.fromWidgetRef(WidgetRef ref) : _reader = ref.read;

  final T Function<T>(ProviderBase<T> provider) _reader;

  T read<T>(ProviderBase<T> provider) => _reader<T>(provider);
}
