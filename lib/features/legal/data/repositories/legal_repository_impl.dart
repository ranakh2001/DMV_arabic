import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/about_info.dart';
import '../../domain/entities/legal_content.dart';
import '../../domain/repositories/legal_repository.dart';
import '../datasources/legal_remote_data_source.dart';

class LegalRepositoryImpl implements LegalRepository {
  const LegalRepositoryImpl({required LegalRemoteDataSource remote})
    : _remote = remote;

  final LegalRemoteDataSource _remote;

  @override
  Future<Result<LegalContent>> getPrivacyPolicy() async {
    try {
      final model = await _remote.getPrivacyPolicy();
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(
        ApiFailure(
          messageAr: e.messageAr,
          messageEn: e.messageEn,
          statusCode: e.statusCode,
          errorCode: e.errorCode,
        ),
      );
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<LegalContent>> getTerms() async {
    try {
      final model = await _remote.getTerms();
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(
        ApiFailure(
          messageAr: e.messageAr,
          messageEn: e.messageEn,
          statusCode: e.statusCode,
          errorCode: e.errorCode,
        ),
      );
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<AboutInfo>> getAboutUs() async {
    try {
      final model = await _remote.getAboutUs();
      return Result.success(model.toEntity());
    } on ServerException catch (e) {
      return Result.failure(
        ApiFailure(
          messageAr: e.messageAr,
          messageEn: e.messageEn,
          statusCode: e.statusCode,
          errorCode: e.errorCode,
        ),
      );
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }

  @override
  Future<Result<String>> sendContactMessage(String message) async {
    try {
      final confirmation = await _remote.sendContactMessage(message);
      return Result.success(confirmation);
    } on ServerException catch (e) {
      return Result.failure(
        ApiFailure(
          messageAr: e.messageAr,
          messageEn: e.messageEn,
          statusCode: e.statusCode,
          errorCode: e.errorCode,
        ),
      );
    } catch (_) {
      return Result.failure(const NetworkFailure());
    }
  }
}
