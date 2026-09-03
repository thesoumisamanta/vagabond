import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/core/widgets/glass_card.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/dashboard/presentation/menu/widgets/user_profile_card.dart';
import 'package:vagabond/features/dashboard/presentation/menu/widgets/menu_list_item.dart';
import 'package:vagabond/features/dashboard/presentation/menu/widgets/logout_confirmation_dialog.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Title
          const Text(
            AppStrings.menuTitle,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),

          // User Profile Card
          if (user != null) ...[UserProfileCard(user: user), const SizedBox(height: 24)],

          // Menu Items Group
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                MenuListItem(
                  icon: Icons.settings_outlined,
                  title: AppStrings.menuSettings,
                  onTap: () => context.push('/settings'),
                ),
                _buildDivider(),
                MenuListItem(
                  icon: Icons.help_outline_rounded,
                  title: AppStrings.menuHelpSupport,
                  onTap: () {
                    // Help action
                  },
                ),
                _buildDivider(),
                MenuListItem(
                  icon: Icons.privacy_tip_outlined,
                  title: AppStrings.menuPrivacyPolicy,
                  onTap: () => context.push('/privacy-policy'),
                ),
                _buildDivider(),
                MenuListItem(
                  icon: Icons.description_outlined,
                  title: AppStrings.menuTermsConditions,
                  onTap: () => context.push('/terms-and-conditions'),
                ),
                _buildDivider(),
                MenuListItem(
                  icon: Icons.logout_rounded,
                  title: AppStrings.menuLogout,
                  textColor: Colors.redAccent,
                  iconColor: Colors.redAccent,
                  onTap: () => _showLogoutConfirmation(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const LogoutConfirmationDialog();
      },
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.white.withOpacity(0.05), indent: 16, endIndent: 16);
  }
}
