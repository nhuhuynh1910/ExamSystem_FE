import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// ════════════════════════════════════════════════════════════════════════════
/// GoogleUserProfile — Dữ liệu profile lấy từ Google Sign-In.
///
/// Tách riêng DTO này để không phụ thuộc trực tiếp vào GoogleSignInAccount
/// trong các layer khác (BLoC, UI).
/// ════════════════════════════════════════════════════════════════════════════
class GoogleUserProfile {
  final String fullName;
  final String email;
  final String? photoUrl;

  const GoogleUserProfile({
    required this.fullName,
    required this.email,
    this.photoUrl,
  });
}

/// ════════════════════════════════════════════════════════════════════════════
/// GoogleAuthService — Wrap Google Sign-In SDK.
///
/// Cách dùng:
///   final service = GoogleAuthService();
///   final profile = await service.signIn();
///   if (profile != null) { /* navigate to Complete Registration */ }
///
/// Tách riêng class này để:
///   1. Dễ mock khi viết unit test.
///   2. Không trộn logic Google SDK vào AuthRemoteDataSource.
///   3. Tuân thủ Single Responsibility Principle.
///
/// LƯU Ý CẤU HÌNH:
///   - Android: Cần file google-services.json từ Firebase Console.
///   - iOS: Cần GoogleService-Info.plist + cấu hình URL scheme.
///   - Web: Cần clientId trong index.html.
/// ════════════════════════════════════════════════════════════════════════════
class GoogleAuthService {
  final GoogleSignIn _googleSignIn;

  GoogleAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              scopes: ['email', 'profile'],
            );

  /// Thực hiện Google Sign-In và trả về profile.
  ///
  /// Trả về [GoogleUserProfile] nếu user đồng ý đăng nhập.
  /// Trả về `null` nếu user hủy (nhấn nút Back trên popup Google).
  /// Bắn ra [Exception] nếu có lỗi kỹ thuật.
  Future<GoogleUserProfile?> signIn() async {
    try {
      final account = await _googleSignIn.signIn();

      // User hủy đăng nhập (nhấn Back trên popup Google)
      if (account == null) return null;

      return GoogleUserProfile(
        fullName: account.displayName ?? account.email.split('@').first,
        email: account.email,
        photoUrl: account.photoUrl,
      );
    } catch (e) {
      debugPrint('[GoogleAuthService] Sign-In error: $e');
      rethrow;
    }
  }

  /// Đăng xuất tài khoản Google (disconnect).
  ///
  /// Gọi khi user muốn đổi tài khoản Google khác hoặc khi cần reset.
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('[GoogleAuthService] Sign-Out error: $e');
    }
  }

  /// Thực hiện Google Sign-In và trả về tokens (idToken + profile).
  ///
  /// Khác với [signIn()] (chỉ trả profile cho Register):
  ///   - Method này lấy thêm **idToken** từ GoogleSignInAuthentication.
  ///   - idToken cần thiết để gửi lên BE verify (POST /api/auth/google-login).
  ///
  /// Trả về [GoogleSignInTokens] nếu thành công.
  /// Trả về `null` nếu user hủy.
  Future<GoogleSignInTokens?> signInWithTokens() async {
    try {
      final account = await _googleSignIn.signIn();

      // User hủy đăng nhập
      if (account == null) return null;

      // Lấy authentication tokens từ Google
      final authentication = await account.authentication;

      final profile = GoogleUserProfile(
        fullName: account.displayName ?? account.email.split('@').first,
        email: account.email,
        photoUrl: account.photoUrl,
      );

      return GoogleSignInTokens(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken,
        profile: profile,
      );
    } catch (e) {
      debugPrint('[GoogleAuthService] Sign-In with tokens error: $e');
      rethrow;
    }
  }
}

/// ════════════════════════════════════════════════════════════════════════════
/// GoogleSignInTokens — Kết quả Google Sign-In bao gồm tokens và profile.
///
/// Dùng cho luồng Google Login (cần idToken để gửi lên BE).
/// Khác với GoogleUserProfile (chỉ có profile, không có token).
/// ════════════════════════════════════════════════════════════════════════════
class GoogleSignInTokens {
  /// Google ID Token (JWT) — gửi lên BE để verify.
  final String? idToken;

  /// Google Access Token — dùng để gọi Google APIs (nếu cần).
  final String? accessToken;

  /// Profile thông tin user từ Google.
  final GoogleUserProfile profile;

  const GoogleSignInTokens({
    required this.idToken,
    required this.accessToken,
    required this.profile,
  });
}
