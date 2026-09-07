import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_providers.dart';
import '../../data/datasources/apple_iap_remote_data_source.dart';
import '../../data/repositories/apple_iap_repository_impl.dart';
import '../../domain/repositories/apple_iap_repository.dart';
import '../../domain/usecases/get_apple_account_token_usecase.dart';
import '../../domain/usecases/submit_apple_iap_purchase_usecase.dart';
import '../../domain/usecases/verify_apple_purchase_usecase.dart';

final appleIapRemoteDataSourceProvider = Provider<AppleIapRemoteDataSource>(
  (ref) => AppleIapRemoteDataSource(ref.watch(dioProvider)),
);

final appleIapRepositoryProvider = Provider<AppleIapRepository>(
  (ref) => AppleIapRepositoryImpl(
    remote: ref.watch(appleIapRemoteDataSourceProvider),
  ),
);

final getAppleAccountTokenUsecaseProvider = Provider(
  (ref) => GetAppleAccountTokenUsecase(ref.watch(appleIapRepositoryProvider)),
);

final verifyApplePurchaseUsecaseProvider = Provider(
  (ref) => VerifyApplePurchaseUsecase(ref.watch(appleIapRepositoryProvider)),
);

final submitAppleIapPurchaseUsecaseProvider = Provider(
  (ref) =>
      SubmitAppleIapPurchaseUsecase(ref.watch(appleIapRepositoryProvider)),
);
