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

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthResetPasswordSuccess) {
          CustomSnackBar.showSuccess(context, state.message);
          context.go('/login');
        } else if (state is AuthFailure) {
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
                  Color(0xFF0F172A),
                  Color(0xFF1E1B4B),
                  Color(0xFF0F172A),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ),
                  Expanded(
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
                                  title: AppStrings.resetPasswordHeaderTitle,
                                  subtitle: AppStrings.resetPasswordSubtitle,
                                ),
                                const SizedBox(height: 32),
                                CustomTextFormField(
                                  controller: _newPasswordController,
                                  obscureText: _obscureNewPassword,
                                  labelText: AppStrings.resetPasswordNewLabel,
                                  hintText: AppStrings.resetPasswordNewHint,
                                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.6)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureNewPassword = !_obscureNewPassword;
                                      });
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppStrings.resetPasswordNewRequired;
                                    }
                                    if (value.length < 6) {
                                      return AppStrings.resetPasswordNewTooShort;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                CustomTextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  labelText: AppStrings.resetPasswordConfirmLabel,
                                  hintText: AppStrings.resetPasswordConfirmHint,
                                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.6)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppStrings.resetPasswordConfirmRequired;
                                    }
                                    if (value != _newPasswordController.text) {
                                      return AppStrings.resetPasswordPasswordsDoNotMatch;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                CustomButton(
                                  text: AppStrings.resetPasswordButton,
                                  isLoading: isLoading,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        ResetPasswordRequested(
                                          email: widget.email,
                                          otp: widget.otp,
                                          newPassword: _newPasswordController.text,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
