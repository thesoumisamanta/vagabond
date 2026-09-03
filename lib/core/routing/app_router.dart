import 'package:firebase_analytics/observer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vagabond/features/splash/presentation/screens/splash_screen.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/auth/presentation/screens/login_screen.dart';
import 'package:vagabond/features/auth/presentation/screens/register_screen.dart';
import 'package:vagabond/features/auth/presentation/screens/otp_screen.dart';
import 'package:vagabond/features/auth/presentation/screens/delete_account_screen.dart';
import 'package:vagabond/features/auth/presentation/screens/change_password_screen.dart';
import 'package:vagabond/features/auth/presentation/screens/settings_screen.dart';
import 'package:vagabond/features/auth/presentation/screens/privacy_settings_screen.dart';
import 'package:vagabond/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:vagabond/features/legal/presentation/screens/privacy_policy_screen.dart';
import 'package:vagabond/features/legal/presentation/screens/terms_and_conditions_screen.dart';
import 'package:vagabond/features/post/presentation/screens/add_post_screen.dart';
import 'package:vagabond/features/post/presentation/screens/post_details_screen.dart';
import 'package:vagabond/features/post/presentation/bloc/post_bloc.dart';
import 'package:vagabond/features/search/presentation/bloc/search_bloc.dart';
import 'package:vagabond/features/search/presentation/screens/search_screen.dart';
import 'package:vagabond/features/search/presentation/screens/user_profile_screen.dart';
import 'package:vagabond/features/search/presentation/screens/user_list_screen.dart';
import 'package:vagabond/features/story/presentation/screens/create_story_screen.dart';
import 'package:vagabond/core/di/injection_container.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/presentation/screens/chat_screen.dart';
import 'package:vagabond/features/notification/presentation/screens/notification_screen.dart';

GoRouter appRouter(FirebaseAnalyticsObserver observer) => GoRouter(
  initialLocation: '/',
  observers: [observer],
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return OtpScreen(email: email);
      },
    ),
    GoRoute(path: '/dashboard', builder: (context, state) => const DashboardScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        final user = context.read<AuthBloc>().currentUser;
        final userId = user?.id ?? '';
        return BlocProvider<SearchBloc>(
          create: (context) => sl<SearchBloc>(),
          child: UserProfileScreen(userId: userId),
        );
      },
    ),
    GoRoute(path: '/delete-account', builder: (context, state) => const DeleteAccountScreen()),
    GoRoute(path: '/change-password', builder: (context, state) => const ChangePasswordScreen()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/privacy-settings', builder: (context, state) => const PrivacySettingsScreen()),
    GoRoute(path: '/privacy-policy', builder: (context, state) => const PrivacyPolicyScreen()),
    GoRoute(path: '/terms-and-conditions', builder: (context, state) => const TermsAndConditionsScreen()),
    GoRoute(path: '/add-post', builder: (context, state) => const AddPostScreen()),
    GoRoute(path: '/create-story', builder: (context, state) => const CreateStoryScreen()),
    GoRoute(
      path: '/search',
      builder: (context, state) =>
          BlocProvider<SearchBloc>(create: (context) => sl<SearchBloc>(), child: const SearchScreen()),
    ),
    GoRoute(
      path: '/profile/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return BlocProvider<SearchBloc>(
          create: (context) => sl<SearchBloc>(),
          child: UserProfileScreen(userId: id),
        );
      },
    ),
    GoRoute(
      path: '/profile/:id/users-list',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final type = state.uri.queryParameters['type'] ?? 'followers';
        return BlocProvider<SearchBloc>(
          create: (context) => sl<SearchBloc>(),
          child: UserListScreen(userId: id, type: type),
        );
      },
    ),
    GoRoute(
      path: '/post/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return BlocProvider<PostBloc>(
          create: (context) => sl<PostBloc>(),
          child: PostDetailsScreen(postId: id),
        );
      },
    ),
    GoRoute(
      path: '/chat/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId'];
        final chat = state.extra as Chat?;
        return ChatScreen(chatId: chatId, chat: chat);
      },
    ),
    GoRoute(
      path: '/chat/user/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId'];
        return ChatScreen(userId: userId);
      },
    ),
    GoRoute(path: '/notifications', builder: (context, state) => const NotificationScreen()),
  ],
);
