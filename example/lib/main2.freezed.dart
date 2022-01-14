// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'main2.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$MyStateTearOff {
  const _$MyStateTearOff();

  _Main main({required int number}) {
    return _Main(
      number: number,
    );
  }

  _Profile profile({required int number}) {
    return _Profile(
      number: number,
    );
  }

  _Purple purple({required int number}) {
    return _Purple(
      number: number,
    );
  }
}

/// @nodoc
const $MyState = _$MyStateTearOff();

/// @nodoc
mixin _$MyState {
  int get number => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number) main,
    required TResult Function(int number) profile,
    required TResult Function(int number) purple,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number)? main,
    TResult Function(int number)? profile,
    TResult Function(int number)? purple,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number)? main,
    TResult Function(int number)? profile,
    TResult Function(int number)? purple,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Main value) main,
    required TResult Function(_Profile value) profile,
    required TResult Function(_Purple value) purple,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_Main value)? main,
    TResult Function(_Profile value)? profile,
    TResult Function(_Purple value)? purple,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Main value)? main,
    TResult Function(_Profile value)? profile,
    TResult Function(_Purple value)? purple,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MyStateCopyWith<MyState> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyStateCopyWith<$Res> {
  factory $MyStateCopyWith(MyState value, $Res Function(MyState) then) =
      _$MyStateCopyWithImpl<$Res>;
  $Res call({int number});
}

/// @nodoc
class _$MyStateCopyWithImpl<$Res> implements $MyStateCopyWith<$Res> {
  _$MyStateCopyWithImpl(this._value, this._then);

  final MyState _value;
  // ignore: unused_field
  final $Res Function(MyState) _then;

  @override
  $Res call({
    Object? number = freezed,
  }) {
    return _then(_value.copyWith(
      number: number == freezed
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
abstract class _$MainCopyWith<$Res> implements $MyStateCopyWith<$Res> {
  factory _$MainCopyWith(_Main value, $Res Function(_Main) then) =
      __$MainCopyWithImpl<$Res>;
  @override
  $Res call({int number});
}

/// @nodoc
class __$MainCopyWithImpl<$Res> extends _$MyStateCopyWithImpl<$Res>
    implements _$MainCopyWith<$Res> {
  __$MainCopyWithImpl(_Main _value, $Res Function(_Main) _then)
      : super(_value, (v) => _then(v as _Main));

  @override
  _Main get _value => super._value as _Main;

  @override
  $Res call({
    Object? number = freezed,
  }) {
    return _then(_Main(
      number: number == freezed
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_Main implements _Main {
  const _$_Main({required this.number});

  @override
  final int number;

  @override
  String toString() {
    return 'MyState.main(number: $number)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Main &&
            const DeepCollectionEquality().equals(other.number, number));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(number));

  @JsonKey(ignore: true)
  @override
  _$MainCopyWith<_Main> get copyWith =>
      __$MainCopyWithImpl<_Main>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number) main,
    required TResult Function(int number) profile,
    required TResult Function(int number) purple,
  }) {
    return main(number);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number)? main,
    TResult Function(int number)? profile,
    TResult Function(int number)? purple,
  }) {
    return main?.call(number);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number)? main,
    TResult Function(int number)? profile,
    TResult Function(int number)? purple,
    required TResult orElse(),
  }) {
    if (main != null) {
      return main(number);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Main value) main,
    required TResult Function(_Profile value) profile,
    required TResult Function(_Purple value) purple,
  }) {
    return main(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_Main value)? main,
    TResult Function(_Profile value)? profile,
    TResult Function(_Purple value)? purple,
  }) {
    return main?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Main value)? main,
    TResult Function(_Profile value)? profile,
    TResult Function(_Purple value)? purple,
    required TResult orElse(),
  }) {
    if (main != null) {
      return main(this);
    }
    return orElse();
  }
}

abstract class _Main implements MyState {
  const factory _Main({required int number}) = _$_Main;

  @override
  int get number;
  @override
  @JsonKey(ignore: true)
  _$MainCopyWith<_Main> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$ProfileCopyWith<$Res> implements $MyStateCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) then) =
      __$ProfileCopyWithImpl<$Res>;
  @override
  $Res call({int number});
}

/// @nodoc
class __$ProfileCopyWithImpl<$Res> extends _$MyStateCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(_Profile _value, $Res Function(_Profile) _then)
      : super(_value, (v) => _then(v as _Profile));

  @override
  _Profile get _value => super._value as _Profile;

  @override
  $Res call({
    Object? number = freezed,
  }) {
    return _then(_Profile(
      number: number == freezed
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_Profile implements _Profile {
  const _$_Profile({required this.number});

  @override
  final int number;

  @override
  String toString() {
    return 'MyState.profile(number: $number)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Profile &&
            const DeepCollectionEquality().equals(other.number, number));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(number));

  @JsonKey(ignore: true)
  @override
  _$ProfileCopyWith<_Profile> get copyWith =>
      __$ProfileCopyWithImpl<_Profile>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number) main,
    required TResult Function(int number) profile,
    required TResult Function(int number) purple,
  }) {
    return profile(number);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number)? main,
    TResult Function(int number)? profile,
    TResult Function(int number)? purple,
  }) {
    return profile?.call(number);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number)? main,
    TResult Function(int number)? profile,
    TResult Function(int number)? purple,
    required TResult orElse(),
  }) {
    if (profile != null) {
      return profile(number);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Main value) main,
    required TResult Function(_Profile value) profile,
    required TResult Function(_Purple value) purple,
  }) {
    return profile(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_Main value)? main,
    TResult Function(_Profile value)? profile,
    TResult Function(_Purple value)? purple,
  }) {
    return profile?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Main value)? main,
    TResult Function(_Profile value)? profile,
    TResult Function(_Purple value)? purple,
    required TResult orElse(),
  }) {
    if (profile != null) {
      return profile(this);
    }
    return orElse();
  }
}

abstract class _Profile implements MyState {
  const factory _Profile({required int number}) = _$_Profile;

  @override
  int get number;
  @override
  @JsonKey(ignore: true)
  _$ProfileCopyWith<_Profile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$PurpleCopyWith<$Res> implements $MyStateCopyWith<$Res> {
  factory _$PurpleCopyWith(_Purple value, $Res Function(_Purple) then) =
      __$PurpleCopyWithImpl<$Res>;
  @override
  $Res call({int number});
}

/// @nodoc
class __$PurpleCopyWithImpl<$Res> extends _$MyStateCopyWithImpl<$Res>
    implements _$PurpleCopyWith<$Res> {
  __$PurpleCopyWithImpl(_Purple _value, $Res Function(_Purple) _then)
      : super(_value, (v) => _then(v as _Purple));

  @override
  _Purple get _value => super._value as _Purple;

  @override
  $Res call({
    Object? number = freezed,
  }) {
    return _then(_Purple(
      number: number == freezed
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_Purple implements _Purple {
  const _$_Purple({required this.number});

  @override
  final int number;

  @override
  String toString() {
    return 'MyState.purple(number: $number)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Purple &&
            const DeepCollectionEquality().equals(other.number, number));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(number));

  @JsonKey(ignore: true)
  @override
  _$PurpleCopyWith<_Purple> get copyWith =>
      __$PurpleCopyWithImpl<_Purple>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(int number) main,
    required TResult Function(int number) profile,
    required TResult Function(int number) purple,
  }) {
    return purple(number);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(int number)? main,
    TResult Function(int number)? profile,
    TResult Function(int number)? purple,
  }) {
    return purple?.call(number);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(int number)? main,
    TResult Function(int number)? profile,
    TResult Function(int number)? purple,
    required TResult orElse(),
  }) {
    if (purple != null) {
      return purple(number);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Main value) main,
    required TResult Function(_Profile value) profile,
    required TResult Function(_Purple value) purple,
  }) {
    return purple(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(_Main value)? main,
    TResult Function(_Profile value)? profile,
    TResult Function(_Purple value)? purple,
  }) {
    return purple?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Main value)? main,
    TResult Function(_Profile value)? profile,
    TResult Function(_Purple value)? purple,
    required TResult orElse(),
  }) {
    if (purple != null) {
      return purple(this);
    }
    return orElse();
  }
}

abstract class _Purple implements MyState {
  const factory _Purple({required int number}) = _$_Purple;

  @override
  int get number;
  @override
  @JsonKey(ignore: true)
  _$PurpleCopyWith<_Purple> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
class _$PurpleRouteDataTearOff {
  const _$PurpleRouteDataTearOff();

  _PurpleRouteData call() {
    return const _PurpleRouteData();
  }
}

/// @nodoc
const $PurpleRouteData = _$PurpleRouteDataTearOff();

/// @nodoc
mixin _$PurpleRouteData {}

/// @nodoc
abstract class $PurpleRouteDataCopyWith<$Res> {
  factory $PurpleRouteDataCopyWith(
          PurpleRouteData value, $Res Function(PurpleRouteData) then) =
      _$PurpleRouteDataCopyWithImpl<$Res>;
}

/// @nodoc
class _$PurpleRouteDataCopyWithImpl<$Res>
    implements $PurpleRouteDataCopyWith<$Res> {
  _$PurpleRouteDataCopyWithImpl(this._value, this._then);

  final PurpleRouteData _value;
  // ignore: unused_field
  final $Res Function(PurpleRouteData) _then;
}

/// @nodoc
abstract class _$PurpleRouteDataCopyWith<$Res> {
  factory _$PurpleRouteDataCopyWith(
          _PurpleRouteData value, $Res Function(_PurpleRouteData) then) =
      __$PurpleRouteDataCopyWithImpl<$Res>;
}

/// @nodoc
class __$PurpleRouteDataCopyWithImpl<$Res>
    extends _$PurpleRouteDataCopyWithImpl<$Res>
    implements _$PurpleRouteDataCopyWith<$Res> {
  __$PurpleRouteDataCopyWithImpl(
      _PurpleRouteData _value, $Res Function(_PurpleRouteData) _then)
      : super(_value, (v) => _then(v as _PurpleRouteData));

  @override
  _PurpleRouteData get _value => super._value as _PurpleRouteData;
}

/// @nodoc

class _$_PurpleRouteData implements _PurpleRouteData {
  const _$_PurpleRouteData();

  @override
  String toString() {
    return 'PurpleRouteData()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _PurpleRouteData);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

abstract class _PurpleRouteData implements PurpleRouteData {
  const factory _PurpleRouteData() = _$_PurpleRouteData;
}

/// @nodoc
class _$GreenRouteDataTearOff {
  const _$GreenRouteDataTearOff();

  _GreenRouteData call() {
    return const _GreenRouteData();
  }
}

/// @nodoc
const $GreenRouteData = _$GreenRouteDataTearOff();

/// @nodoc
mixin _$GreenRouteData {}

/// @nodoc
abstract class $GreenRouteDataCopyWith<$Res> {
  factory $GreenRouteDataCopyWith(
          GreenRouteData value, $Res Function(GreenRouteData) then) =
      _$GreenRouteDataCopyWithImpl<$Res>;
}

/// @nodoc
class _$GreenRouteDataCopyWithImpl<$Res>
    implements $GreenRouteDataCopyWith<$Res> {
  _$GreenRouteDataCopyWithImpl(this._value, this._then);

  final GreenRouteData _value;
  // ignore: unused_field
  final $Res Function(GreenRouteData) _then;
}

/// @nodoc
abstract class _$GreenRouteDataCopyWith<$Res> {
  factory _$GreenRouteDataCopyWith(
          _GreenRouteData value, $Res Function(_GreenRouteData) then) =
      __$GreenRouteDataCopyWithImpl<$Res>;
}

/// @nodoc
class __$GreenRouteDataCopyWithImpl<$Res>
    extends _$GreenRouteDataCopyWithImpl<$Res>
    implements _$GreenRouteDataCopyWith<$Res> {
  __$GreenRouteDataCopyWithImpl(
      _GreenRouteData _value, $Res Function(_GreenRouteData) _then)
      : super(_value, (v) => _then(v as _GreenRouteData));

  @override
  _GreenRouteData get _value => super._value as _GreenRouteData;
}

/// @nodoc

class _$_GreenRouteData implements _GreenRouteData {
  const _$_GreenRouteData();

  @override
  String toString() {
    return 'GreenRouteData()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _GreenRouteData);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

abstract class _GreenRouteData implements GreenRouteData {
  const factory _GreenRouteData() = _$_GreenRouteData;
}

/// @nodoc
class _$ProfileRouteDataTearOff {
  const _$ProfileRouteDataTearOff();

  _ProfileRouteData call({required int number}) {
    return _ProfileRouteData(
      number: number,
    );
  }
}

/// @nodoc
const $ProfileRouteData = _$ProfileRouteDataTearOff();

/// @nodoc
mixin _$ProfileRouteData {
  int get number => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProfileRouteDataCopyWith<ProfileRouteData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileRouteDataCopyWith<$Res> {
  factory $ProfileRouteDataCopyWith(
          ProfileRouteData value, $Res Function(ProfileRouteData) then) =
      _$ProfileRouteDataCopyWithImpl<$Res>;
  $Res call({int number});
}

/// @nodoc
class _$ProfileRouteDataCopyWithImpl<$Res>
    implements $ProfileRouteDataCopyWith<$Res> {
  _$ProfileRouteDataCopyWithImpl(this._value, this._then);

  final ProfileRouteData _value;
  // ignore: unused_field
  final $Res Function(ProfileRouteData) _then;

  @override
  $Res call({
    Object? number = freezed,
  }) {
    return _then(_value.copyWith(
      number: number == freezed
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
abstract class _$ProfileRouteDataCopyWith<$Res>
    implements $ProfileRouteDataCopyWith<$Res> {
  factory _$ProfileRouteDataCopyWith(
          _ProfileRouteData value, $Res Function(_ProfileRouteData) then) =
      __$ProfileRouteDataCopyWithImpl<$Res>;
  @override
  $Res call({int number});
}

/// @nodoc
class __$ProfileRouteDataCopyWithImpl<$Res>
    extends _$ProfileRouteDataCopyWithImpl<$Res>
    implements _$ProfileRouteDataCopyWith<$Res> {
  __$ProfileRouteDataCopyWithImpl(
      _ProfileRouteData _value, $Res Function(_ProfileRouteData) _then)
      : super(_value, (v) => _then(v as _ProfileRouteData));

  @override
  _ProfileRouteData get _value => super._value as _ProfileRouteData;

  @override
  $Res call({
    Object? number = freezed,
  }) {
    return _then(_ProfileRouteData(
      number: number == freezed
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_ProfileRouteData implements _ProfileRouteData {
  const _$_ProfileRouteData({required this.number});

  @override
  final int number;

  @override
  String toString() {
    return 'ProfileRouteData(number: $number)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProfileRouteData &&
            const DeepCollectionEquality().equals(other.number, number));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(number));

  @JsonKey(ignore: true)
  @override
  _$ProfileRouteDataCopyWith<_ProfileRouteData> get copyWith =>
      __$ProfileRouteDataCopyWithImpl<_ProfileRouteData>(this, _$identity);
}

abstract class _ProfileRouteData implements ProfileRouteData {
  const factory _ProfileRouteData({required int number}) = _$_ProfileRouteData;

  @override
  int get number;
  @override
  @JsonKey(ignore: true)
  _$ProfileRouteDataCopyWith<_ProfileRouteData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
class _$MainRouteDataTearOff {
  const _$MainRouteDataTearOff();

  _MainRouteData call({required int number}) {
    return _MainRouteData(
      number: number,
    );
  }
}

/// @nodoc
const $MainRouteData = _$MainRouteDataTearOff();

/// @nodoc
mixin _$MainRouteData {
  int get number => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MainRouteDataCopyWith<MainRouteData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MainRouteDataCopyWith<$Res> {
  factory $MainRouteDataCopyWith(
          MainRouteData value, $Res Function(MainRouteData) then) =
      _$MainRouteDataCopyWithImpl<$Res>;
  $Res call({int number});
}

/// @nodoc
class _$MainRouteDataCopyWithImpl<$Res>
    implements $MainRouteDataCopyWith<$Res> {
  _$MainRouteDataCopyWithImpl(this._value, this._then);

  final MainRouteData _value;
  // ignore: unused_field
  final $Res Function(MainRouteData) _then;

  @override
  $Res call({
    Object? number = freezed,
  }) {
    return _then(_value.copyWith(
      number: number == freezed
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
abstract class _$MainRouteDataCopyWith<$Res>
    implements $MainRouteDataCopyWith<$Res> {
  factory _$MainRouteDataCopyWith(
          _MainRouteData value, $Res Function(_MainRouteData) then) =
      __$MainRouteDataCopyWithImpl<$Res>;
  @override
  $Res call({int number});
}

/// @nodoc
class __$MainRouteDataCopyWithImpl<$Res>
    extends _$MainRouteDataCopyWithImpl<$Res>
    implements _$MainRouteDataCopyWith<$Res> {
  __$MainRouteDataCopyWithImpl(
      _MainRouteData _value, $Res Function(_MainRouteData) _then)
      : super(_value, (v) => _then(v as _MainRouteData));

  @override
  _MainRouteData get _value => super._value as _MainRouteData;

  @override
  $Res call({
    Object? number = freezed,
  }) {
    return _then(_MainRouteData(
      number: number == freezed
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_MainRouteData implements _MainRouteData {
  const _$_MainRouteData({required this.number});

  @override
  final int number;

  @override
  String toString() {
    return 'MainRouteData(number: $number)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MainRouteData &&
            const DeepCollectionEquality().equals(other.number, number));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(number));

  @JsonKey(ignore: true)
  @override
  _$MainRouteDataCopyWith<_MainRouteData> get copyWith =>
      __$MainRouteDataCopyWithImpl<_MainRouteData>(this, _$identity);
}

abstract class _MainRouteData implements MainRouteData {
  const factory _MainRouteData({required int number}) = _$_MainRouteData;

  @override
  int get number;
  @override
  @JsonKey(ignore: true)
  _$MainRouteDataCopyWith<_MainRouteData> get copyWith =>
      throw _privateConstructorUsedError;
}
