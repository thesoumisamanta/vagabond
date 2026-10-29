import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/core/widgets/custom_button.dart';
import 'package:vagabond/core/widgets/custom_snackbar.dart';
import 'package:vagabond/core/widgets/custom_text_form_field.dart';
import 'package:vagabond/core/widgets/glass_card.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/auth/presentation/widgets/auth_header.dart';
import 'package:vagabond/features/support/presentation/cubit/support_cubit.dart';
import 'package:vagabond/features/support/presentation/cubit/support_state.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final String _selectedPriority = 'medium';

  @override
  void initState() {
    super.initState();
    // Prefill name & email from logged in user if available
    final user = context.read<AuthBloc>().currentUser;
    if (user != null) {
      _nameController.text = user.fullName.isNotEmpty ? user.fullName : user.username;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupportCubit, SupportState>(
      listener: (context, state) {
        if (state is SupportContactSuccess) {
          CustomSnackBar.showSuccess(context, state.message);
          _subjectController.clear();
          _messageController.clear();
          context.pop();
        } else if (state is SupportFailure) {
          CustomSnackBar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is SupportLoading;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              AppStrings.helpSupportTitle,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AuthHeader(
                              icon: Icons.support_agent_rounded,
                              title: AppStrings.helpSupportHeaderTitle,
                              subtitle: AppStrings.helpSupportSubtitle,
                              iconSize: 48,
                              titleFontSize: 20,
                            ),
                            const SizedBox(height: 28),

                            // Name Field
                            CustomTextFormField(
                              controller: _nameController,
                              labelText: AppStrings.helpSupportNameLabel,
                              hintText: AppStrings.helpSupportNameHint,
                              prefixIcon: Icon(Icons.person_outline, color: Colors.white.withOpacity(0.6)),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppStrings.helpSupportNameRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email Field
                            CustomTextFormField(
                              controller: _emailController,
                              labelText: AppStrings.helpSupportEmailLabel,
                              hintText: AppStrings.helpSupportEmailHint,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.6)),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppStrings.helpSupportEmailRequired;
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                                  return AppStrings.helpSupportEmailInvalid;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Subject Field
                            CustomTextFormField(
                              controller: _subjectController,
                              labelText: AppStrings.helpSupportSubjectLabel,
                              hintText: AppStrings.helpSupportSubjectHint,
                              prefixIcon: Icon(Icons.subject_rounded, color: Colors.white.withOpacity(0.6)),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppStrings.helpSupportSubjectRequired;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Message Field
                            CustomTextFormField(
                              controller: _messageController,
                              labelText: AppStrings.helpSupportMessageLabel,
                              hintText: AppStrings.helpSupportMessageHint,
                              maxLines: 4,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 56.0),
                                child: Icon(Icons.chat_bubble_outline, color: Colors.white.withOpacity(0.6)),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return AppStrings.helpSupportMessageRequired;
                                }
                                if (value.trim().length < 5) {
                                  return AppStrings.helpSupportMessageTooShort;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            CustomButton(
                              text: AppStrings.helpSupportSubmitButton,
                              isLoading: isLoading,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<SupportCubit>().submitContactSupport(
                                    name: _nameController.text.trim(),
                                    email: _emailController.text.trim(),
                                    subject: _subjectController.text.trim(),
                                    message: _messageController.text.trim(),
                                    priority: _selectedPriority,
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Direct Contact Info Card
                    GlassCard(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.8), size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                AppStrings.helpSupportDirectContactTitle,
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.mail_outline, color: Colors.white.withOpacity(0.6), size: 18),
                              const SizedBox(width: 10),
                              const SelectableText(
                                AppStrings.helpSupportEmailAddress,
                                style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.language_rounded, color: Colors.white.withOpacity(0.6), size: 18),
                              const SizedBox(width: 10),
                              const SelectableText(
                                AppStrings.helpSupportWebsite,
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

