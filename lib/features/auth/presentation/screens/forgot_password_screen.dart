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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthForgotPasswordSuccess) {
          CustomSnackBar.showSuccess(context, state.message);
          context.push('/reset-otp?email=${Uri.encodeComponent(state.email)}');
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
                                  icon: Icons.lock_reset_rounded,
                                  title: AppStrings.forgotPasswordHeaderTitle,
                                  subtitle: AppStrings.forgotPasswordSubtitle,
                                ),
                                const SizedBox(height: 32),
                                CustomTextFormField(
                                  controller: _emailController,
                                  labelText: AppStrings.forgotPasswordEmailLabel,
                                  hintText: AppStrings.forgotPasswordEmailHint,
                                  keyboardType: TextInputType.emailAddress,
                                  prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.6)),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return AppStrings.forgotPasswordEmailRequired;
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return AppStrings.forgotPasswordEmailInvalid;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                CustomButton(
                                  text: AppStrings.forgotPasswordSendOtpButton,
                                  isLoading: isLoading,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        ForgotPasswordRequested(
                                          email: _emailController.text.trim(),
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
