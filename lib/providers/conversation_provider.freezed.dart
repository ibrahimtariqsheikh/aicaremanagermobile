// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ConversationState {
  Conversation? get conversation;
  bool get isLoading;
  String? get error;

  /// Create a copy of ConversationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ConversationStateCopyWith<ConversationState> get copyWith =>
      _$ConversationStateCopyWithImpl<ConversationState>(
          this as ConversationState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ConversationState &&
            (identical(other.conversation, conversation) ||
                other.conversation == conversation) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, conversation, isLoading, error);

  @override
  String toString() {
    return 'ConversationState(conversation: $conversation, isLoading: $isLoading, error: $error)';
  }
}

/// @nodoc
abstract mixin class $ConversationStateCopyWith<$Res> {
  factory $ConversationStateCopyWith(
          ConversationState value, $Res Function(ConversationState) _then) =
      _$ConversationStateCopyWithImpl;
  @useResult
  $Res call({Conversation? conversation, bool isLoading, String? error});
}

/// @nodoc
class _$ConversationStateCopyWithImpl<$Res>
    implements $ConversationStateCopyWith<$Res> {
  _$ConversationStateCopyWithImpl(this._self, this._then);

  final ConversationState _self;
  final $Res Function(ConversationState) _then;

  /// Create a copy of ConversationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? conversation = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      conversation: freezed == conversation
          ? _self.conversation
          : conversation // ignore: cast_nullable_to_non_nullable
              as Conversation?,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _ConversationState implements ConversationState {
  const _ConversationState(
      {this.conversation, this.isLoading = false, this.error});

  @override
  final Conversation? conversation;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  /// Create a copy of ConversationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ConversationStateCopyWith<_ConversationState> get copyWith =>
      __$ConversationStateCopyWithImpl<_ConversationState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ConversationState &&
            (identical(other.conversation, conversation) ||
                other.conversation == conversation) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, conversation, isLoading, error);

  @override
  String toString() {
    return 'ConversationState(conversation: $conversation, isLoading: $isLoading, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$ConversationStateCopyWith<$Res>
    implements $ConversationStateCopyWith<$Res> {
  factory _$ConversationStateCopyWith(
          _ConversationState value, $Res Function(_ConversationState) _then) =
      __$ConversationStateCopyWithImpl;
  @override
  @useResult
  $Res call({Conversation? conversation, bool isLoading, String? error});
}

/// @nodoc
class __$ConversationStateCopyWithImpl<$Res>
    implements _$ConversationStateCopyWith<$Res> {
  __$ConversationStateCopyWithImpl(this._self, this._then);

  final _ConversationState _self;
  final $Res Function(_ConversationState) _then;

  /// Create a copy of ConversationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? conversation = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_ConversationState(
      conversation: freezed == conversation
          ? _self.conversation
          : conversation // ignore: cast_nullable_to_non_nullable
              as Conversation?,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
