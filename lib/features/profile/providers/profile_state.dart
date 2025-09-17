// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fitness_app/models/user_profile.dart';

class ProfileState {
  ProfileState({this.value = const AsyncValue.data(null)});

  final AsyncValue<UserProfile?> value;

  bool get isLoading => value.isLoading;
  @override
  bool operator ==(covariant ProfileState other) {
    if (identical(this, other)) return true;

    return other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ProfileState(value: $value)';

  ProfileState copyWith({AsyncValue<UserProfile?>? value}) {
    return ProfileState(value: value ?? this.value);
  }
}
