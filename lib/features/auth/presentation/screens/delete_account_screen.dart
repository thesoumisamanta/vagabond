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

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthDeleteAccountSuccess) {
          CustomSnackBar.showSuccess(context, state.message);
          context.go('/login');
        } else if (state is AuthFailure) {
          CustomSnackBar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              AppStrings.deleteAccountTitle,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          extendBodyBehindAppBar: true,
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: GlassCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AuthHeader(
                            icon: Icons.warning_amber_rounded,
                            title: AppStrings.deleteAccountHeaderTitle,
                            subtitle: AppStrings.deleteAccountSubtitle,
                            iconColor: Colors.redAccent,
                            iconSize: 48.0,
                            titleFontSize: 20.0,
                          ),
                          const SizedBox(height: 32),
                          CustomTextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            labelText: AppStrings.deleteAccountPasswordLabel,
                            hintText: AppStrings.deleteAccountPasswordHint,
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
                                return AppStrings.deleteAccountPasswordRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          CustomButton(
                            text: AppStrings.deleteAccountButton,
                            isLoading: isLoading,
                            gradientColors: const [Colors.redAccent, Color(0xFFDC2626)],
                            shadowColor: Colors.redAccent,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  DeleteAccountRequested(password: _passwordController.text),
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
          ),
        );
      },
    );
  }
}
