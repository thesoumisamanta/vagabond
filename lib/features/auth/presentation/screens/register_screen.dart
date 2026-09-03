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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _accountType = AppStrings.registerAccountTypePersonal; // Default value
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthRegisterSuccess) {
          CustomSnackBar.showSuccess(context, state.message);
          context.push('/otp?email=${Uri.encodeComponent(_emailController.text.trim())}');
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
                          const AuthHeader(
                            icon: Icons.person_add_outlined,
                            title: AppStrings.registerCreateAccount,
                            subtitle: AppStrings.registerSubtitle,
                          ),
                          const SizedBox(height: 32),
                          CustomTextFormField(
                            controller: _fullNameController,
                            labelText: AppStrings.registerFullNameLabel,
                            hintText: AppStrings.registerFullNameHint,
                            prefixIcon: Icon(Icons.person_outline, color: Colors.white.withOpacity(0.6)),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.registerFullNameRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomTextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            labelText: AppStrings.registerEmailLabel,
                            hintText: AppStrings.registerEmailHint,
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.6)),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.registerEmailRequired;
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return AppStrings.registerEmailInvalid;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomTextFormField(
                            controller: _usernameController,
                            labelText: AppStrings.registerUsernameLabel,
                            hintText: AppStrings.registerUsernameHint,
                            prefixIcon: Icon(Icons.person_outline, color: Colors.white.withOpacity(0.6)),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return AppStrings.registerUsernameRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomTextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            labelText: AppStrings.registerPasswordLabel,
                            hintText: AppStrings.registerPasswordHint,
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
                                return AppStrings.registerPasswordRequired;
                              }
                              if (value.length < 6) {
                                return AppStrings.registerPasswordTooShort;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomTextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            labelText: AppStrings.registerConfirmPasswordLabel,
                            hintText: AppStrings.registerConfirmPasswordHint,
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
                                return AppStrings.registerConfirmPasswordRequired;
                              }
                              if (value != _passwordController.text) {
                                return AppStrings.registerPasswordsDoNotMatch;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<String>(
                            value: _accountType,
                            dropdownColor: const Color(0xFF1E1B4B),
                            style: const TextStyle(color: Colors.white),
                            iconEnabledColor: Colors.white.withOpacity(0.6),
                            decoration: InputDecoration(
                              labelText: AppStrings.registerAccountTypeLabel,
                              labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                              prefixIcon: Icon(Icons.business_center_outlined, color: Colors.white.withOpacity(0.6)),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.03),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: AppStrings.registerAccountTypePersonal,
                                child: Text(AppStrings.registerAccountTypePersonal),
                              ),
                              DropdownMenuItem(
                                value: AppStrings.registerAccountTypeBusiness,
                                child: Text(AppStrings.registerAccountTypeBusiness),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _accountType = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 32),
                          CustomButton(
                            text: AppStrings.registerButton,
                            isLoading: isLoading,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                context.read<AuthBloc>().add(
                                  RegisterRequested(
                                    email: _emailController.text.trim(),
                                    username: _usernameController.text.trim(),
                                    password: _passwordController.text.trim(),
                                    fullName: _fullNameController.text.trim(),
                                    accountType: _accountType,
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
                                AppStrings.registerAlreadyHaveAccount,
                                style: TextStyle(color: Colors.white.withOpacity(0.6)),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.pop();
                                },
                                child: const Text(
                                  AppStrings.registerLoginLink,
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
