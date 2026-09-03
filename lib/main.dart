import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vagabond/core/di/injection_container.dart';
import 'package:vagabond/core/network/api_endpoints.dart';
import 'package:vagabond/core/routing/app_router.dart';
import 'package:vagabond/core/services/notification_service.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_event.dart';
import 'package:vagabond/features/post/presentation/bloc/post_bloc.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vagabond/core/constants/app_strings.dart';
import 'package:vagabond/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:vagabond/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDependencyInjection();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationService.initialize();

  // Pass all uncaught Flutter errors to Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  const MethodChannel channel = MethodChannel("app.vagabond.com/config");
  final String? baseUrl = await channel.invokeMethod("getBaseUrl");
  ApiEndpoints.baseUrl = baseUrl ?? '';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => sl<AuthBloc>()..add(const AppStarted())),
        BlocProvider<PostBloc>(create: (context) => sl<PostBloc>()),
        BlocProvider<ChatBloc>(create: (context) => sl<ChatBloc>()),
        BlocProvider<NotificationBloc>(create: (context) => sl<NotificationBloc>()),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: MaterialApp.router(
          title: AppStrings.appTitle,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
            ),
          ),
          routerConfig: appRouter(observer),
        ),
      ),
    );
  }
}
