// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailPasswordState {
  EmailPasswordState({this.value = const AsyncValue.data(null)});
  final AsyncValue<void> value;

  bool get isLoading => value.isLoading;
  @override
  String toString() => 'EmailPasswordState(value: $value)';

  @override
  bool operator ==(covariant EmailPasswordState other) {
    if (identical(this, other)) return true;

    return other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  EmailPasswordState copyWith({AsyncValue<void>? value}) {
    return EmailPasswordState(value: value ?? this.value);
  }
}
