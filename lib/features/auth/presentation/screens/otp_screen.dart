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

class OtpScreen extends StatefulWidget {
  final String email;

  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
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
        if (state is AuthVerifyOtpSuccess) {
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
                          AuthHeader(
                            icon: Icons.mark_email_read_outlined,
                            title: AppStrings.otpVerifyEmail,
                            subtitle: '${AppStrings.otpSubtitlePrefix}${widget.email}',
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
                                  return AppStrings.otpRequired;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          CustomButton(
                            text: AppStrings.otpVerifyButton,
                            isLoading: isLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  VerifyOtpRequested(email: widget.email, otp: _pinController.text.trim()),
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppStrings.otpDidNotReceive, style: TextStyle(color: Colors.white.withOpacity(0.6))),
                              GestureDetector(
                                onTap: () {
                                  // Resend OTP action
                                },
                                child: const Text(
                                  AppStrings.otpResendLink,
                                  style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              context.pop();
                            },
                            child: Text(
                              AppStrings.otpBackToRegister,
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
          ),
        );
      },
    );
  }
}
