import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/core/di/injection_container.dart';
import 'package:vagabond/features/dashboard/presentation/menu/screens/menu_screen.dart';
import 'package:vagabond/features/story/presentation/bloc/story_bloc.dart';
import 'package:vagabond/features/story/presentation/bloc/story_event.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/dashboard/presentation/widgets/dashboard_placeholder.dart';
import 'package:vagabond/features/dashboard/presentation/widgets/dashboard_nav_item.dart';
import 'package:vagabond/features/dashboard/presentation/widgets/home_tab.dart';
import 'package:vagabond/features/chat/presentation/screens/inbox_screen.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_event.dart';
import 'package:vagabond/core/services/storage_service.dart';
import 'package:vagabond/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:vagabond/features/notification/presentation/bloc/notification_event.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  Widget _buildContent(int index) {
    switch (index) {
      case 0:
        return const HomeTab();
      case 1:
        return const DashboardPlaceholder(
          icon: Icons.play_circle_outline,
          title: AppStrings.dashboardReelsTitle,
          subtitle: AppStrings.dashboardReelsSubtitle,
        );
      case 2:
        return const InboxScreen();
      case 3:
        return const MenuScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildAddPostNavItem() {
    return GestureDetector(
      onTap: () => context.push('/add-post'),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.add_box_outlined, color: Colors.white.withOpacity(0.5), size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.dashboardAddPostLabel,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    sl<StorageService>().getAccessToken().then((token) {
      if (token != null && mounted) {
        context.read<ChatBloc>().add(ConnectSocketRequested(token: token));
        context.read<NotificationBloc>().add(const GetNotificationsRequested());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return BlocProvider<StoryBloc>(
      create: (context) => sl<StoryBloc>()..add(const GetFollowingStoriesRequested()),
      child: Scaffold(
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
            bottom: false,
            child: Stack(
              children: [
                // Content Body
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 70.0 + bottomPadding), // Space for bottom navigation bar
                    child: _buildContent(_selectedIndex),
                  ),
                ),

                // Custom Glassmorphic Bottom Navigation Bar
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: EdgeInsets.only(top: 12, bottom: 12 + bottomPadding, left: 16, right: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            DashboardNavItem(
                              isSelected: _selectedIndex == 0,
                              icon: Icons.home_outlined,
                              label: AppStrings.dashboardHomeLabel,
                              onTap: () => setState(() => _selectedIndex = 0),
                            ),
                            DashboardNavItem(
                              isSelected: _selectedIndex == 1,
                              icon: Icons.play_circle_outline,
                              label: AppStrings.dashboardReelsLabel,
                              onTap: () => setState(() => _selectedIndex = 1),
                            ),
                            _buildAddPostNavItem(),
                            DashboardNavItem(
                              isSelected: _selectedIndex == 2,
                              icon: Icons.chat_bubble_outline,
                              label: AppStrings.dashboardChatsLabel,
                              onTap: () => setState(() => _selectedIndex = 2),
                            ),
                            DashboardNavItem(
                              isSelected: _selectedIndex == 3,
                              icon: Icons.menu,
                              label: AppStrings.dashboardMenuLabel,
                              onTap: () => setState(() => _selectedIndex = 3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
