import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationApi {
  final Dio _dio = DioClient.instance;

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _dio.get(ApiConstants.notifications);
    final List data = response.data is List ? response.data : (response.data['items'] ?? []);
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markAsRead(int id) async {
    await _dio.put('${ApiConstants.notifications}/$id/read');
  }

  Future<void> sendNotification(Map<String, dynamic> data) async {
    await _dio.post(ApiConstants.notifications, data: data);
  }
}
