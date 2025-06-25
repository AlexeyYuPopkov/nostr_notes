import 'package:equatable/equatable.dart';

/// [OptionalBox] is convenient for usage with copyWith pattern.
/// It is used to avoid nullable fields in class that uses copyWith method.
final class OptionalBox<T> extends Equatable {
  final T? value;

  const OptionalBox(this.value);

  factory OptionalBox.nil() => OptionalBox<T>(null);

  @override
  List<Object?> get props => [value];

  bool get isNull => value == null;
  bool get isNotNull => !isNull;
}
