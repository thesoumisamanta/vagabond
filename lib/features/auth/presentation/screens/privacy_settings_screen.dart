import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_event.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_state.dart';
import 'package:vagabond/core/widgets/custom_snackbar.dart';
import 'package:vagabond/core/widgets/glass_card.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  bool _isPrivate = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().currentUser;
    _isPrivate = user?.isPrivate ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUpdatePrivacySettingsSuccess) {
          CustomSnackBar.showSuccess(context, state.message);
          setState(() {
            _isPrivate = state.isPrivate;
          });
        } else if (state is AuthFailure) {
          CustomSnackBar.showError(context, state.error);
          // Revert state on failure
          final user = context.read<AuthBloc>().currentUser;
          setState(() {
            _isPrivate = user?.isPrivate ?? false;
          });
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
              AppStrings.privacySettingsTitle,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          extendBodyBehindAppBar: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.lock_outline, color: Color(0xFF6366F1)),
                                  SizedBox(width: 12),
                                  Text(
                                    AppStrings.privacySettingsPrivateAccount,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _isPrivate,
                                activeColor: const Color(0xFF6366F1),
                                onChanged: isLoading
                                    ? null
                                    : (value) {
                                        context.read<AuthBloc>().add(UpdatePrivacySettingsRequested(isPrivate: value));
                                      },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.privacySettingsSubtitle,
                            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6), height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    if (isLoading) ...[
                      const SizedBox(height: 24),
                      const Center(
                        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1))),
                      ),
                    ],
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
