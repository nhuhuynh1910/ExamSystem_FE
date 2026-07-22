import '../../../core/utils/storage_manager.dart';
import '../models/login_request.dart';
import 'auth_api.dart';

class AuthRepository {
  final AuthApi _api = AuthApi();

  Future<void> login(LoginRequest request) async {
    final response = await _api.login(request);
    
    // Lưu vào StorageManager để dùng cho toàn app
    await StorageManager.saveAuthData(
      userId: response.userId,
      fullName: response.fullName,
      email: response.email,
      username: response.username,
      role: response.role,
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );
  }
}
