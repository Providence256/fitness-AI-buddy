import 'package:fitness_app/features/authentication/data/auth_repository.dart';
import 'package:fitness_app/features/authentication/domain/email_password_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailPasswordSignInController extends StateNotifier<EmailPasswordState> {
  EmailPasswordSignInController(this.authRepository)
    : super(EmailPasswordState());

  final AuthRepository authRepository;

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    state = state.copyWith(value: AsyncValue.loading());

    final value = await AsyncValue.guard(
      () => authRepository.signInWithEmailAndPassword(email, password),
    );

    state = state.copyWith(value: value);
    return value.hasError == false;
  }

  Future<bool> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    state = state.copyWith(value: AsyncValue.loading());

    final value = await AsyncValue.guard(
      () => authRepository.createUserWithEmailAndPassword(email, password),
    );

    state = state.copyWith(value: value);
    return value.hasError == false;
  }
}

final emailPasswordSignInControllerProvider =
    StateNotifierProvider.autoDispose<
      EmailPasswordSignInController,
      EmailPasswordState
    >((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      return EmailPasswordSignInController(authRepository);
    });
