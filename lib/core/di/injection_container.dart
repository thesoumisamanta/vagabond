import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:vagabond/core/network/api_client.dart';
import 'package:vagabond/core/network/api_endpoints.dart';
import 'package:vagabond/core/services/storage_service.dart';
import 'package:vagabond/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:vagabond/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vagabond/features/auth/domain/repositories/auth_repository.dart';
import 'package:vagabond/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:vagabond/features/legal/data/datasources/legal_remote_datasource.dart';
import 'package:vagabond/features/legal/data/repositories/legal_repository_impl.dart';
import 'package:vagabond/features/legal/domain/repositories/legal_repository.dart';
import 'package:vagabond/features/legal/presentation/cubit/legal_cubit.dart';
import 'package:vagabond/features/comment/data/datasources/comment_remote_datasource.dart';
import 'package:vagabond/features/comment/data/repositories/comment_repository_impl.dart';
import 'package:vagabond/features/comment/domain/repositories/comment_repository.dart';
import 'package:vagabond/features/comment/presentation/bloc/comment_bloc.dart';
import 'package:vagabond/features/post/data/datasources/post_remote_datasource.dart';
import 'package:vagabond/features/post/data/repositories/post_repository_impl.dart';
import 'package:vagabond/features/post/domain/repositories/post_repository.dart';
import 'package:vagabond/features/post/presentation/bloc/post_bloc.dart';
import 'package:vagabond/features/search/data/datasources/search_remote_datasource.dart';
import 'package:vagabond/features/search/data/repositories/search_repository_impl.dart';
import 'package:vagabond/features/search/domain/repositories/search_repository.dart';
import 'package:vagabond/features/search/presentation/bloc/search_bloc.dart';
import 'package:vagabond/features/story/data/datasources/story_remote_datasource.dart';
import 'package:vagabond/features/story/data/repositories/story_repository_impl.dart';
import 'package:vagabond/features/story/domain/repositories/story_repository.dart';
import 'package:vagabond/features/story/presentation/bloc/story_bloc.dart';
import 'package:vagabond/core/services/socket_service.dart';
import 'package:vagabond/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:vagabond/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:vagabond/features/chat/domain/repositories/chat_repository.dart';
import 'package:vagabond/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:vagabond/features/notification/data/datasources/notification_remote_datasource.dart';
import 'package:vagabond/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:vagabond/features/notification/domain/repositories/notification_repository.dart';
import 'package:vagabond/features/notification/presentation/bloc/notification_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencyInjection() async {
  // Core - Storage
  sl.registerLazySingleton<FlutterSecureStorage>(() => const FlutterSecureStorage());
  sl.registerLazySingleton<StorageService>(() => StorageService(secureStorage: sl()));

  // Core - Dio
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: "${ApiEndpoints.baseUrl}/api/v1/",
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );

    return dio;
  });

  // Core - ApiClient
  sl.registerLazySingleton<ApiClient>(() => ApiClient(dio: sl(), storageService: sl()));

  // Features - Auth
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(apiClient: sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), storageService: sl()));

  // Blocs
  sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl(), storageService: sl()));

  // Features - Legal
  // Data sources
  sl.registerLazySingleton<LegalRemoteDataSource>(() => LegalRemoteDataSourceImpl(apiClient: sl()));

  // Repositories
  sl.registerLazySingleton<LegalRepository>(() => LegalRepositoryImpl(remoteDataSource: sl()));

  // Cubits
  sl.registerFactory<LegalCubit>(() => LegalCubit(legalRepository: sl()));

  // Features - Post
  // Data sources
  sl.registerLazySingleton<PostRemoteDataSource>(() => PostRemoteDataSourceImpl(apiClient: sl()));

  // Repositories
  sl.registerLazySingleton<PostRepository>(() => PostRepositoryImpl(remoteDataSource: sl()));

  // Blocs
  sl.registerFactory<PostBloc>(() => PostBloc(postRepository: sl()));

  // Features - Comment
  // Data sources
  sl.registerLazySingleton<CommentRemoteDataSource>(() => CommentRemoteDataSourceImpl(apiClient: sl()));

  // Repositories
  sl.registerLazySingleton<CommentRepository>(() => CommentRepositoryImpl(remoteDataSource: sl()));

  // Blocs
  sl.registerFactory<CommentBloc>(() => CommentBloc(commentRepository: sl()));

  // Features - Search
  // Data sources
  sl.registerLazySingleton<SearchRemoteDataSource>(() => SearchRemoteDataSourceImpl(apiClient: sl()));

  // Repositories
  sl.registerLazySingleton<SearchRepository>(() => SearchRepositoryImpl(remoteDataSource: sl()));

  // Blocs
  sl.registerFactory<SearchBloc>(() => SearchBloc(searchRepository: sl()));

  // Features - Story
  // Data sources
  sl.registerLazySingleton<StoryRemoteDataSource>(() => StoryRemoteDataSourceImpl(apiClient: sl()));

  // Repositories
  sl.registerLazySingleton<StoryRepository>(() => StoryRepositoryImpl(remoteDataSource: sl()));

  // Blocs
  sl.registerFactory<StoryBloc>(() => StoryBloc(storyRepository: sl()));

  // Features - Chat
  // Socket Service
  sl.registerLazySingleton<SocketService>(() => SocketService());

  // Data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(apiClient: sl()));

  // Repositories
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(remoteDataSource: sl()));

  // Blocs
  sl.registerFactory<ChatBloc>(() => ChatBloc(chatRepository: sl(), socketService: sl()));

  // Features - Notification
  // Data sources
  sl.registerLazySingleton<NotificationRemoteDataSource>(() => NotificationRemoteDataSourceImpl(apiClient: sl()));

  // Repositories
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepositoryImpl(remoteDataSource: sl()));

  // Blocs
  sl.registerFactory<NotificationBloc>(() => NotificationBloc(notificationRepository: sl()));
}
