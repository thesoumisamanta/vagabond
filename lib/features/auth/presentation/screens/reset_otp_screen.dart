import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:vagabond/core/widgets/custom_snackbar.dart';
import 'package:vagabond/core/widgets/custom_button.dart';
import 'package:vagabond/core/widgets/glass_card.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_event.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_state.dart';
import 'package:vagabond/features/auth/presentation/widgets/auth_header.dart';

class ResetOtpScreen extends StatefulWidget {
  final String email;

  const ResetOtpScreen({super.key, required this.email});

  @override
  State<ResetOtpScreen> createState() => _ResetOtpScreenState();
}

class _ResetOtpScreenState extends State<ResetOtpScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 48,
      height: 56,
      textStyle: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: const Color(0xFF6366F1), width: 2)),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(color: Colors.white.withOpacity(0.05)),
    );

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthVerifyResetOtpSuccess) {
          CustomSnackBar.showSuccess(context, state.message);
          context.push(
            '/reset-password?email=${Uri.encodeComponent(state.email)}&otp=${Uri.encodeComponent(state.otp)}',
          );
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
                                AuthHeader(
                                  icon: Icons.mark_email_read_outlined,
                                  title: AppStrings.resetOtpTitle,
                                  subtitle: '${AppStrings.resetOtpSubtitlePrefix}${widget.email}',
                                ),
                                const SizedBox(height: 32),
                                Center(
                                  child: Pinput(
                                    length: 6,
                                    controller: _pinController,
                                    focusNode: _focusNode,
                                    defaultPinTheme: defaultPinTheme,
                                    focusedPinTheme: focusedPinTheme,
                                    submittedPinTheme: submittedPinTheme,
                                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                                    validator: (value) {
                                      if (value == null || value.length < 6) {
                                        return AppStrings.resetOtpRequired;
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(height: 32),
                                CustomButton(
                                  text: AppStrings.resetOtpVerifyButton,
                                  isLoading: isLoading,
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<AuthBloc>().add(
                                        VerifyResetOtpRequested(
                                          email: widget.email,
                                          otp: _pinController.text.trim(),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(AppStrings.resetOtpDidNotReceive, style: TextStyle(color: Colors.white.withOpacity(0.6))),
                                    GestureDetector(
                                      onTap: () {
                                        context.read<AuthBloc>().add(
                                          ForgotPasswordRequested(email: widget.email),
                                        );
                                      },
                                      child: const Text(
                                        AppStrings.resetOtpResendLink,
                                        style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () => context.pop(),
                                  child: Text(
                                    AppStrings.resetOtpBackToForgotPassword,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      decoration: TextDecoration.underline,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
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
