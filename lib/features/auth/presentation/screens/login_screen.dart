import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/core/widgets/custom_snackbar.dart';
import 'package:vagabond/core/widgets/custom_text_form_field.dart';
import 'package:vagabond/core/widgets/custom_button.dart';
import 'package:vagabond/core/widgets/glass_card.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_event.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_state.dart';
import 'package:vagabond/features/auth/presentation/widgets/auth_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthProfileSuccess) {
          CustomSnackBar.showSuccess(context, AppStrings.loginSuccessMessage);
          context.go('/dashboard');
        } else if (state is AuthLoginRequiresVerification) {
          CustomSnackBar.showWarning(context, state.message);
          context.go('/otp?email=${Uri.encodeComponent(state.email)}');
        } else if (state is AuthFailure) {
          debugPrint(state.error);
          CustomSnackBar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A), // Slate 900
                  Color(0xFF1E1B4B), // Indigo 950
                  Color(0xFF0F172A), // Slate 900
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AuthHeader(
                            icon: Icons.lock_outline_rounded,
                            title: AppStrings.loginWelcomeBack,
                            subtitle: AppStrings.loginSubtitle,
                          ),
                          const SizedBox(height: 32),
                          CustomTextFormField(
                            controller: _usernameController,
                            labelText: AppStrings.loginUsernameLabel,
                            hintText: AppStrings.loginUsernameHint,
                            prefixIcon: Icon(Icons.person_outline, color: Colors.white.withOpacity(0.6)),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.loginUsernameRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomTextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            labelText: AppStrings.loginPasswordLabel,
                            hintText: AppStrings.loginPasswordHint,
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.6)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.loginPasswordRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          CustomButton(
                            text: AppStrings.loginButton,
                            isLoading: isLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  LoginRequested(
                                    emailOrUsername: _usernameController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  ),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.loginDontHaveAccount,
                                style: TextStyle(color: Colors.white.withOpacity(0.6)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.push('/register');
                                },
                                child: const Text(
                                  AppStrings.loginRegisterLink,
                                  style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
