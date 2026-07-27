import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/us_state_model.dart';

/// Performs the raw HTTP call for the (public, no-auth) `/states` list.
class StatesRemoteDataSource {
  const StatesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<UsStateModel>> getStates() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(ApiConstants.states);
      final json = response.data ?? {};
      if (json['success'] != true) {
        throw ServerException(messageAr: json['message'] as String? ?? 'تعذر جلب الولايات.');
      }
      final list = json['data'] as List<dynamic>? ?? [];
      return list.map((e) => UsStateModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final body = e.response?.data;
      final message = body is Map<String, dynamic> ? body['message'] as String? : null;
      throw ServerException(
        messageAr: message ?? 'تعذر جلب الولايات. يرجى المحاولة مرة أخرى.',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
