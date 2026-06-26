import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/storage_providers.dart';
import 'dio_client.dart';
import 'interceptors/auth_interceptor.dart';

/// Provider that exposes the fully-configured [Dio] instance.
final dioProvider = Provider<Dio>((ref) => createDio());

/// Adds the [AuthInterceptor] to the [Dio] instance.
/// Called from bootstrap after the container is ready.
void attachAuthInterceptor(
  ProviderContainer container,
  Dio dio,
  Future<void> Function() onLogout,
) {
  dio.interceptors.add(
    AuthInterceptor(
      secureStorage: container.read(secureStorageProvider),
      dio: dio,
      onLogout: onLogout,
    ),
  );
}
