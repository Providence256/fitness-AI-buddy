import 'package:fitness_app/features/authentication/domain/app_user.dart';
import 'package:fitness_app/features/authentication/domain/fake_app_user.dart';
import 'package:fitness_app/utility/in_memory_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class AuthRepository {
  final _authState = InMemoryStore<AppUser?>(null);

  Stream<AppUser?> authStateChanges() => _authState.stream;
  AppUser? get currentUser => _authState.value;

  final List<FakeAppUser> _users = [];

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    for (final u in _users) {
      // matching email and password
      if (u.email == email && u.password == password) {
        _authState.value = u;
        return;
      }
      // same email, wrong password
      if (u.email == email && u.password != password) {
        throw Exception("Wrong-password");
      }
    }

    throw Exception("User not found");
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    Future.delayed(Duration(milliseconds: 2000));
    for (final u in _users) {
      if (u.email == email) {
        throw Exception("Email already exists");
      }
    }

    if (password.length < 8) {
      throw Exception("Password is too weak");
    }

    _createNewUser(email, password);
  }

  void dispose() => _authState.close();

  void _createNewUser(String email, String password) {
    final user = FakeAppUser(
      id: email.split('').reversed.join(),
      email: email,
      password: password,
    );

    _users.add(user);

    _authState.value = user;
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
