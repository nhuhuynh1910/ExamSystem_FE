namespace JWT.DTOs.Auth
{
    /// <summary>
    /// Request body cho endpoint POST /api/auth/google-login.
    /// 
    /// Hỗ trợ 2 luồng xác thực linh hoạt:
    ///   1. IdToken (native/mobile) → verify bằng GoogleJsonWebSignature.
    ///   2. AccessToken (web) → gọi Google UserInfo API lấy email.
    /// Ít nhất 1 trong 2 phải có giá trị.
    /// </summary>
    public class GoogleLoginRequest
    {
        /// <summary>
        /// Google ID Token (JWT) — từ Google Sign-In SDK (native/mobile).
        /// Nullable trên Flutter Web vì plugin không trả về idToken.
        /// </summary>
        public string? IdToken { get; set; }

        /// <summary>
        /// Google Access Token — từ Google Sign-In SDK (web).
        /// Dùng khi IdToken null, BE gọi Google UserInfo API để lấy email.
        /// </summary>
        public string? AccessToken { get; set; }
    }
}
