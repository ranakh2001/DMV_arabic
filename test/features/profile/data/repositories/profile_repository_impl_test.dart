import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:dmv/core/constants/api_constants.dart';
import 'package:dmv/core/errors/failure.dart';
import 'package:dmv/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:dmv/features/profile/data/repositories/profile_repository_impl.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late ProfileRepositoryImpl repository;

  setUp(() {
    dio = _MockDio();
    repository = ProfileRepositoryImpl(
      remote: ProfileRemoteDataSource(dio),
    );
  });

  Response<Map<String, dynamic>> jsonResponse(
    Map<String, dynamic> data, {
    int statusCode = 200,
  }) => Response<Map<String, dynamic>>(
    requestOptions: RequestOptions(path: ApiConstants.deleteAccount),
    statusCode: statusCode,
    data: data,
  );

  group('deleteAccount', () {
    test('returns success when the API confirms deletion', () async {
      when(
        () => dio.delete<Map<String, dynamic>>(ApiConstants.deleteAccount),
      ).thenAnswer(
        (_) async => jsonResponse({
          'success': true,
          'message': 'تم حذف الحساب بنجاح',
          'data': null,
        }),
      );

      final result = await repository.deleteAccount();

      expect(result.isSuccess, isTrue);
      verify(
        () => dio.delete<Map<String, dynamic>>(ApiConstants.deleteAccount),
      ).called(1);
    });

    test(
      'returns an ApiFailure with the server message when the envelope reports failure',
      () async {
        when(
          () => dio.delete<Map<String, dynamic>>(ApiConstants.deleteAccount),
        ).thenAnswer(
          (_) async => jsonResponse({
            'success': false,
            'message': 'تعذر حذف الحساب. حاول مرة أخرى.',
          }),
        );

        final result = await repository.deleteAccount();

        expect(result.isFailure, isTrue);
        final failure = result.failureOrNull;
        expect(failure, isA<ApiFailure>());
        expect(failure!.messageAr, 'تعذر حذف الحساب. حاول مرة أخرى.');
      },
    );

    test(
      'returns an ApiFailure carrying the status code on a DioException (e.g. 401)',
      () async {
        when(
          () => dio.delete<Map<String, dynamic>>(ApiConstants.deleteAccount),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ApiConstants.deleteAccount),
            type: DioExceptionType.badResponse,
            response: jsonResponse({
              'success': false,
              'message': 'انتهت صلاحية الجلسة',
            }, statusCode: 401),
          ),
        );

        final result = await repository.deleteAccount();

        expect(result.isFailure, isTrue);
        final failure = result.failureOrNull as ApiFailure;
        expect(failure.messageAr, 'انتهت صلاحية الجلسة');
        expect(failure.statusCode, 401);
      },
    );

    test(
      'falls back to a generic message when a connection error carries no response body',
      () async {
        when(
          () => dio.delete<Map<String, dynamic>>(ApiConstants.deleteAccount),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: ApiConstants.deleteAccount),
            type: DioExceptionType.connectionError,
          ),
        );

        final result = await repository.deleteAccount();

        expect(result.isFailure, isTrue);
        final failure = result.failureOrNull as ApiFailure;
        expect(failure.messageAr, 'حدث خطأ. يرجى المحاولة مرة أخرى.');
        expect(failure.statusCode, isNull);
      },
    );
  });
}
