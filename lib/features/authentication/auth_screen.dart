import 'package:fitness_app/features/authentication/widgets/sign_in_form.dart';
import 'package:fitness_app/features/authentication/widgets/sign_up_form.dart';
import 'package:fitness_app/utility/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              spacing: 15,
              children: [
                // logo and Title
                _buildHeader(),

                // tab Bar
                _buildTabBar(),

                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .37,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // SignIn Form
                      SignInForm(),

                      // SignUp Form
                      SignUpForm(
                        onSignup: () =>
                            Navigator.pushNamed(context, '/profile'),
                      ),
                    ],
                  ),
                ),

                // Social Login
                _buildSocialLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      spacing: 5,
      children: [
        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
            borderRadius: BorderRadius.circular(80),
          ),
          child: Icon(Icons.fitness_center, color: Colors.white, size: 40),
        ),
        Text(
          'Fitness AI Buddy',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Text(
          'Your AI-Powered Fitness Companion',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium!.color,
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'Sign In'),
          Tab(text: 'Sign Up'),
        ],
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      spacing: 10,
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.textSecondary)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or Continue with',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(child: Divider(color: AppColors.textSecondary)),
          ],
        ),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Image.asset(
              'assets/icons/google.png',
              width: 40,
              fit: BoxFit.cover,
            ),
            label: Text('Continue with Google'),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Image.asset(
              'assets/icons/apple.png',
              width: 40,
              fit: BoxFit.cover,
            ),
            label: Text('Continue with Apple'),
          ),
        ),
      ],
    );
  }
}
