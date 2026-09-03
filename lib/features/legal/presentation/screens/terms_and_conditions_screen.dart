import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/core/di/injection_container.dart';
import 'package:vagabond/features/legal/presentation/cubit/legal_cubit.dart';
import 'package:vagabond/features/legal/presentation/cubit/legal_state.dart';
import 'package:vagabond/features/legal/presentation/widgets/legal_header_info.dart';
import 'package:vagabond/features/legal/presentation/widgets/legal_list_section.dart';
import 'package:vagabond/features/legal/presentation/widgets/legal_text_section.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<LegalCubit>()..getTermsAndConditions(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: BlocBuilder<LegalCubit, LegalState>(
            builder: (context, state) {
              if (state is TermsAndConditionsLoaded) {
                return Text(
                  state.termsAndConditions.title,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              }
              return const Text(
                AppStrings.legalTermsConditionsTitle,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
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
            child: BlocBuilder<LegalCubit, LegalState>(
              builder: (context, state) {
                if (state is LegalLoading) {
                  return const Center(
                    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1))),
                  );
                } else if (state is LegalError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () => context.read<LegalCubit>().getTermsAndConditions(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              AppStrings.legalRetry,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is TermsAndConditionsLoaded) {
                  final terms = state.termsAndConditions;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LegalHeaderInfo(version: terms.version, effectiveDate: terms.effectiveDate),
                        const SizedBox(height: 20),
                        LegalTextSection(
                          title: AppStrings.legalIntroduction,
                          icon: Icons.info_outline,
                          text: terms.content.introduction,
                        ),
                        const SizedBox(height: 20),
                        LegalListSection(
                          title: AppStrings.legalUserAccounts,
                          icon: Icons.person_outline,
                          items: terms.content.userAccounts,
                        ),
                        const SizedBox(height: 20),
                        LegalListSection(
                          title: AppStrings.legalContentGuidelines,
                          icon: Icons.image_outlined,
                          items: terms.content.contentGuidelines,
                        ),
                        const SizedBox(height: 20),
                        LegalTextSection(
                          title: AppStrings.legalTermination,
                          icon: Icons.cancel_outlined,
                          text: terms.content.termination,
                        ),
                        const SizedBox(height: 20),
                        LegalTextSection(
                          title: AppStrings.legalGoverningLaw,
                          icon: Icons.gavel_outlined,
                          text: terms.content.governingLaw,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
