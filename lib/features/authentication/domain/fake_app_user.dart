import 'package:fitness_app/features/authentication/domain/app_user.dart';

class FakeAppUser extends AppUser {
  FakeAppUser({
    required super.id,
    required super.email,
    required this.password,
  });
  final String password;
}
