import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import '../../data/datasources/payment_remote_data_source.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/get_subscription_history_usecase.dart';
import '../../domain/usecases/get_subscription_status_usecase.dart';
import '../../domain/usecases/initiate_subscription_usecase.dart';

final paymentRemoteDataSourceProvider = Provider<PaymentRemoteDataSource>(
  (ref) => PaymentRemoteDataSource(ref.watch(dioProvider)),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) =>
      PaymentRepositoryImpl(remote: ref.watch(paymentRemoteDataSourceProvider)),
);

final initiateSubscriptionUsecaseProvider = Provider(
  (ref) => InitiateSubscriptionUsecase(ref.watch(paymentRepositoryProvider)),
);

final getSubscriptionStatusUsecaseProvider = Provider(
  (ref) => GetSubscriptionStatusUsecase(ref.watch(paymentRepositoryProvider)),
);

final getSubscriptionHistoryUsecaseProvider = Provider(
  (ref) => GetSubscriptionHistoryUsecase(ref.watch(paymentRepositoryProvider)),
);
