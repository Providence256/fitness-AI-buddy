import 'package:fitness_app/common/primary_button.dart';
import 'package:fitness_app/features/authentication/provider/email_password_sign_in_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpForm extends ConsumerStatefulWidget {
  const SignUpForm({super.key, this.onSignup});

  final VoidCallback? onSignup;

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String get email => _emailController.text;
  String get password => _passwordController.text;
  String get confirmPassword => _confirmPasswordController.text;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(
        emailPasswordSignInControllerProvider.notifier,
      );

      final success = await controller.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (success) {
        widget.onSignup?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emailPasswordSignInControllerProvider);
    return Form(
      key: _formKey,
      child: Column(
        spacing: 12,
        children: [
          SizedBox(height: 5),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: Icon(Icons.visibility_off_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: Icon(Icons.visibility_off_outlined),
            ),
            validator: (value) {
              if (value != password) {
                return 'Password does not match';
              }
              return null;
            },
          ),
          PrimaryButton(
            text: 'Create account',
            isLoading: state.isLoading,
            onPressed: state.isLoading ? null : () => _submit(),
          ),
        ],
      ),
    );
  }
}
