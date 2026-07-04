// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClassificationResult {

 String get bestKey; double get confidence; Map<String, double> get scores;
/// Create a copy of ClassificationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClassificationResultCopyWith<ClassificationResult> get copyWith => _$ClassificationResultCopyWithImpl<ClassificationResult>(this as ClassificationResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClassificationResult&&(identical(other.bestKey, bestKey) || other.bestKey == bestKey)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other.scores, scores));
}


@override
int get hashCode => Object.hash(runtimeType,bestKey,confidence,const DeepCollectionEquality().hash(scores));

@override
String toString() {
  return 'ClassificationResult(bestKey: $bestKey, confidence: $confidence, scores: $scores)';
}


}

/// @nodoc
abstract mixin class $ClassificationResultCopyWith<$Res>  {
  factory $ClassificationResultCopyWith(ClassificationResult value, $Res Function(ClassificationResult) _then) = _$ClassificationResultCopyWithImpl;
@useResult
$Res call({
 String bestKey, double confidence, Map<String, double> scores
});




}
/// @nodoc
class _$ClassificationResultCopyWithImpl<$Res>
    implements $ClassificationResultCopyWith<$Res> {
  _$ClassificationResultCopyWithImpl(this._self, this._then);

  final ClassificationResult _self;
  final $Res Function(ClassificationResult) _then;

/// Create a copy of ClassificationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bestKey = null,Object? confidence = null,Object? scores = null,}) {
  return _then(_self.copyWith(
bestKey: null == bestKey ? _self.bestKey : bestKey // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,scores: null == scores ? _self.scores : scores // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}

}


/// Adds pattern-matching-related methods to [ClassificationResult].
extension ClassificationResultPatterns on ClassificationResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClassificationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClassificationResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClassificationResult value)  $default,){
final _that = this;
switch (_that) {
case _ClassificationResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClassificationResult value)?  $default,){
final _that = this;
switch (_that) {
case _ClassificationResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String bestKey,  double confidence,  Map<String, double> scores)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClassificationResult() when $default != null:
return $default(_that.bestKey,_that.confidence,_that.scores);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String bestKey,  double confidence,  Map<String, double> scores)  $default,) {final _that = this;
switch (_that) {
case _ClassificationResult():
return $default(_that.bestKey,_that.confidence,_that.scores);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String bestKey,  double confidence,  Map<String, double> scores)?  $default,) {final _that = this;
switch (_that) {
case _ClassificationResult() when $default != null:
return $default(_that.bestKey,_that.confidence,_that.scores);case _:
  return null;

}
}

}

/// @nodoc


class _ClassificationResult extends ClassificationResult {
  const _ClassificationResult({required this.bestKey, required this.confidence, required final  Map<String, double> scores}): _scores = scores,super._();
  

@override final  String bestKey;
@override final  double confidence;
 final  Map<String, double> _scores;
@override Map<String, double> get scores {
  if (_scores is EqualUnmodifiableMapView) return _scores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_scores);
}


/// Create a copy of ClassificationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClassificationResultCopyWith<_ClassificationResult> get copyWith => __$ClassificationResultCopyWithImpl<_ClassificationResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClassificationResult&&(identical(other.bestKey, bestKey) || other.bestKey == bestKey)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other._scores, _scores));
}


@override
int get hashCode => Object.hash(runtimeType,bestKey,confidence,const DeepCollectionEquality().hash(_scores));

@override
String toString() {
  return 'ClassificationResult(bestKey: $bestKey, confidence: $confidence, scores: $scores)';
}


}

/// @nodoc
abstract mixin class _$ClassificationResultCopyWith<$Res> implements $ClassificationResultCopyWith<$Res> {
  factory _$ClassificationResultCopyWith(_ClassificationResult value, $Res Function(_ClassificationResult) _then) = __$ClassificationResultCopyWithImpl;
@override @useResult
$Res call({
 String bestKey, double confidence, Map<String, double> scores
});




}
/// @nodoc
class __$ClassificationResultCopyWithImpl<$Res>
    implements _$ClassificationResultCopyWith<$Res> {
  __$ClassificationResultCopyWithImpl(this._self, this._then);

  final _ClassificationResult _self;
  final $Res Function(_ClassificationResult) _then;

/// Create a copy of ClassificationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bestKey = null,Object? confidence = null,Object? scores = null,}) {
  return _then(_ClassificationResult(
bestKey: null == bestKey ? _self.bestKey : bestKey // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,scores: null == scores ? _self._scores : scores // ignore: cast_nullable_to_non_nullable
as Map<String, double>,
  ));
}


}

/// @nodoc
mixin _$ExtractedMetadata {

 String? get sender; DateTime? get documentDate; int? get amountCents; String get currency; String? get iban; String? get titleSuggestion;
/// Create a copy of ExtractedMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExtractedMetadataCopyWith<ExtractedMetadata> get copyWith => _$ExtractedMetadataCopyWithImpl<ExtractedMetadata>(this as ExtractedMetadata, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExtractedMetadata&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.documentDate, documentDate) || other.documentDate == documentDate)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.iban, iban) || other.iban == iban)&&(identical(other.titleSuggestion, titleSuggestion) || other.titleSuggestion == titleSuggestion));
}


@override
int get hashCode => Object.hash(runtimeType,sender,documentDate,amountCents,currency,iban,titleSuggestion);

@override
String toString() {
  return 'ExtractedMetadata(sender: $sender, documentDate: $documentDate, amountCents: $amountCents, currency: $currency, iban: $iban, titleSuggestion: $titleSuggestion)';
}


}

/// @nodoc
abstract mixin class $ExtractedMetadataCopyWith<$Res>  {
  factory $ExtractedMetadataCopyWith(ExtractedMetadata value, $Res Function(ExtractedMetadata) _then) = _$ExtractedMetadataCopyWithImpl;
@useResult
$Res call({
 String? sender, DateTime? documentDate, int? amountCents, String currency, String? iban, String? titleSuggestion
});




}
/// @nodoc
class _$ExtractedMetadataCopyWithImpl<$Res>
    implements $ExtractedMetadataCopyWith<$Res> {
  _$ExtractedMetadataCopyWithImpl(this._self, this._then);

  final ExtractedMetadata _self;
  final $Res Function(ExtractedMetadata) _then;

/// Create a copy of ExtractedMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sender = freezed,Object? documentDate = freezed,Object? amountCents = freezed,Object? currency = null,Object? iban = freezed,Object? titleSuggestion = freezed,}) {
  return _then(_self.copyWith(
sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String?,documentDate: freezed == documentDate ? _self.documentDate : documentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,amountCents: freezed == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,iban: freezed == iban ? _self.iban : iban // ignore: cast_nullable_to_non_nullable
as String?,titleSuggestion: freezed == titleSuggestion ? _self.titleSuggestion : titleSuggestion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExtractedMetadata].
extension ExtractedMetadataPatterns on ExtractedMetadata {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExtractedMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExtractedMetadata() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExtractedMetadata value)  $default,){
final _that = this;
switch (_that) {
case _ExtractedMetadata():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExtractedMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _ExtractedMetadata() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? sender,  DateTime? documentDate,  int? amountCents,  String currency,  String? iban,  String? titleSuggestion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExtractedMetadata() when $default != null:
return $default(_that.sender,_that.documentDate,_that.amountCents,_that.currency,_that.iban,_that.titleSuggestion);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? sender,  DateTime? documentDate,  int? amountCents,  String currency,  String? iban,  String? titleSuggestion)  $default,) {final _that = this;
switch (_that) {
case _ExtractedMetadata():
return $default(_that.sender,_that.documentDate,_that.amountCents,_that.currency,_that.iban,_that.titleSuggestion);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? sender,  DateTime? documentDate,  int? amountCents,  String currency,  String? iban,  String? titleSuggestion)?  $default,) {final _that = this;
switch (_that) {
case _ExtractedMetadata() when $default != null:
return $default(_that.sender,_that.documentDate,_that.amountCents,_that.currency,_that.iban,_that.titleSuggestion);case _:
  return null;

}
}

}

/// @nodoc


class _ExtractedMetadata implements ExtractedMetadata {
  const _ExtractedMetadata({this.sender, this.documentDate, this.amountCents, this.currency = 'EUR', this.iban, this.titleSuggestion});
  

@override final  String? sender;
@override final  DateTime? documentDate;
@override final  int? amountCents;
@override@JsonKey() final  String currency;
@override final  String? iban;
@override final  String? titleSuggestion;

/// Create a copy of ExtractedMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExtractedMetadataCopyWith<_ExtractedMetadata> get copyWith => __$ExtractedMetadataCopyWithImpl<_ExtractedMetadata>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExtractedMetadata&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.documentDate, documentDate) || other.documentDate == documentDate)&&(identical(other.amountCents, amountCents) || other.amountCents == amountCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.iban, iban) || other.iban == iban)&&(identical(other.titleSuggestion, titleSuggestion) || other.titleSuggestion == titleSuggestion));
}


@override
int get hashCode => Object.hash(runtimeType,sender,documentDate,amountCents,currency,iban,titleSuggestion);

@override
String toString() {
  return 'ExtractedMetadata(sender: $sender, documentDate: $documentDate, amountCents: $amountCents, currency: $currency, iban: $iban, titleSuggestion: $titleSuggestion)';
}


}

/// @nodoc
abstract mixin class _$ExtractedMetadataCopyWith<$Res> implements $ExtractedMetadataCopyWith<$Res> {
  factory _$ExtractedMetadataCopyWith(_ExtractedMetadata value, $Res Function(_ExtractedMetadata) _then) = __$ExtractedMetadataCopyWithImpl;
@override @useResult
$Res call({
 String? sender, DateTime? documentDate, int? amountCents, String currency, String? iban, String? titleSuggestion
});




}
/// @nodoc
class __$ExtractedMetadataCopyWithImpl<$Res>
    implements _$ExtractedMetadataCopyWith<$Res> {
  __$ExtractedMetadataCopyWithImpl(this._self, this._then);

  final _ExtractedMetadata _self;
  final $Res Function(_ExtractedMetadata) _then;

/// Create a copy of ExtractedMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sender = freezed,Object? documentDate = freezed,Object? amountCents = freezed,Object? currency = null,Object? iban = freezed,Object? titleSuggestion = freezed,}) {
  return _then(_ExtractedMetadata(
sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as String?,documentDate: freezed == documentDate ? _self.documentDate : documentDate // ignore: cast_nullable_to_non_nullable
as DateTime?,amountCents: freezed == amountCents ? _self.amountCents : amountCents // ignore: cast_nullable_to_non_nullable
as int?,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,iban: freezed == iban ? _self.iban : iban // ignore: cast_nullable_to_non_nullable
as String?,titleSuggestion: freezed == titleSuggestion ? _self.titleSuggestion : titleSuggestion // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
