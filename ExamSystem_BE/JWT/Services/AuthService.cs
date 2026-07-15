using JWT.DTOs.Auth;
using JWT.Models;
using JWT.Repositories.Contracts;
using JWT.Services.Contracts;
using Google.Apis.Auth;
using System.Security.Cryptography;

namespace JWT.Services
{
    public class AuthService: IAuthService
    {
        private readonly IAuthRepository _authRepository;
        private readonly IJwtService _jwtService;
        private readonly IEmailService _emailService;
        private readonly IConfiguration _configuration;

        public AuthService(
            IAuthRepository authRepository,
            IJwtService jwtService,
            IEmailService emailService,
            IConfiguration configuration)
        {
            _authRepository = authRepository;
            _jwtService = jwtService;
            _emailService = emailService;
            _configuration = configuration;
        }

        public async Task<string> RegisterAsync(RegisterRequest request)
        {
            var email = request.Email.Trim().ToLower();
            var username = request.Username.Trim();

            var existingUserByEmail = await _authRepository.GetByEmailAsync(email);

            if (existingUserByEmail != null)
            {
                if (!existingUserByEmail.IsEmailVerified)
                    throw new Exception("Email đã được đăng ký nhưng chưa xác nhận. Vui lòng gửi lại email xác nhận.");

                throw new Exception("Email đã tồn tại.");
            }

            if (await _authRepository.EmailExistsAsync(email))
                throw new Exception("Email đã tồn tại.");

            if (await _authRepository.UsernameExistsAsync(username))
                throw new Exception("Username đã tồn tại.");

            // Map role string → RoleId (1=Admin, 2=Teacher, 3=Student)
            var roleName = (request.Role ?? "Student").Trim();
            int roleId;
            switch (roleName.ToLower())
            {
                case "teacher":
                    roleId = 2;
                    break;
                case "student":
                    roleId = 3;
                    break;
                default:
                    throw new Exception("Role không hợp lệ. Chỉ chấp nhận Student hoặc Teacher.");
            }

            var verifyToken = Convert.ToHexString(RandomNumberGenerator.GetBytes(32));

            var user = new User
            {
                FullName = request.FullName.Trim(),
                Email = email,
                Username = username,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                RoleId = roleId,
                IsEmailVerified = false,
                EmailVerificationToken = verifyToken,
                EmailVerificationTokenExpiresAt = DateTime.UtcNow.AddHours(24),
                AvatarUrl = string.IsNullOrWhiteSpace(request.AvatarUrl) ? "default.png" : request.AvatarUrl,
                IsActive = true,
                IsDeleted = false,
                CreatedAt = DateTime.UtcNow
            };

            await _authRepository.AddUserAsync(user);
            await _authRepository.SaveChangesAsync();

            var clientUrl = _configuration["App:ClientUrl"];
            var verifyLink = $"{clientUrl}/verify-email?token={verifyToken}";

            await _emailService.SendVerifyEmailAsync(user.Email, user.FullName, verifyLink);

            return "Đăng ký thành công. Vui lòng kiểm tra email để xác nhận tài khoản.";
        }

        public async Task<string> ResendVerificationEmailAsync(string email)
        {
            var user = await _authRepository.GetByEmailAsync(email.Trim().ToLower());

            if (user == null)
                throw new Exception("Email chưa được đăng ký.");

            if (user.IsEmailVerified)
                throw new Exception("Email đã được xác nhận.");

            var verifyToken = Convert.ToHexString(RandomNumberGenerator.GetBytes(32));

            user.EmailVerificationToken = verifyToken;
            user.EmailVerificationTokenExpiresAt = DateTime.UtcNow.AddHours(24);
            user.UpdatedAt = DateTime.UtcNow;

            await _authRepository.SaveChangesAsync();

            var clientUrl = _configuration["App:ClientUrl"];
            var verifyLink = $"{clientUrl}/verify-email?token={verifyToken}";

            await _emailService.SendVerifyEmailAsync(user.Email, user.FullName, verifyLink);

            return "Đã gửi lại email xác nhận. Vui lòng kiểm tra hộp thư.";
        }

        public async Task<string> VerifyEmailAsync(string token)
        {
            var user = await _authRepository.GetByVerificationTokenAsync(token);

            if (user == null)
                throw new Exception("Token xác nhận không hợp lệ.");

            if (user.EmailVerificationTokenExpiresAt < DateTime.UtcNow)
                throw new Exception("Token xác nhận đã hết hạn.");

            user.IsEmailVerified = true;
            user.EmailVerifiedAt = DateTime.UtcNow;
            user.EmailVerificationToken = null;
            user.EmailVerificationTokenExpiresAt = null;
            user.UpdatedAt = DateTime.UtcNow;

            await _authRepository.SaveChangesAsync();

            return "Xác nhận email thành công. Bạn có thể đăng nhập.";
        }

        public async Task<AuthResponse> LoginAsync(LoginRequest request)
        {
            var user = await _authRepository.GetByEmailOrUsernameAsync(request.EmailOrUsername);

            if (user == null)
                throw new Exception("Tài khoản không tồn tại.");

            if (!user.IsActive || user.IsDeleted)
                throw new Exception("Tài khoản đã bị khóa hoặc bị xóa.");

            if (!user.IsEmailVerified)
                throw new Exception("Vui lòng xác nhận email trước khi đăng nhập.");

            var isPasswordValid = BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash);

            if (!isPasswordValid)
                throw new Exception("Mật khẩu không đúng.");

            var accessToken = _jwtService.GenerateAccessToken(user);
            var refreshToken = _jwtService.GenerateRefreshToken();

            refreshToken.UserId = user.UserId;

            user.RefreshTokens.Add(refreshToken);

            await _authRepository.SaveChangesAsync();

            return new AuthResponse
            {
                UserId = user.UserId,
                FullName = user.FullName,
                Email = user.Email,
                Username = user.Username,
                Role = user.Role?.RoleName ?? "Student",
                AccessToken = accessToken,
                RefreshToken = refreshToken.Token
            };
        }

        /// <summary>
        /// Đăng nhập bằng Google — hỗ trợ 2 luồng xác thực linh hoạt.
        /// 
        /// Flow:
        ///   1. Xác thực Google token (idToken HOẶC accessToken).
        ///   2. Lấy email từ token đã xác thực.
        ///   3. Tìm user theo email trong Database.
        ///   4. KHÔNG tạo user mới nếu chưa tồn tại.
        ///   5. Kiểm tra IsActive, IsDeleted, IsEmailVerified.
        ///   6. Tạo JWT + RefreshToken (tái sử dụng _jwtService).
        ///   7. Trả AuthResponse (giống email login).
        /// </summary>
        public async Task<AuthResponse> GoogleLoginAsync(GoogleLoginRequest request)
        {
            // ── Bước 1: Xác thực Google token (idToken hoặc accessToken) ────
            var (email, picture) = await GetEmailFromGoogleAsync(request);

            // ── Bước 2: Tìm user theo email (TÁI SỬ DỤNG repository) ───────
            var user = await _authRepository.GetByEmailAsync(email);

            // ── Bước 3: User KHÔNG tồn tại → trả lỗi, KHÔNG tạo mới ────────
            if (user == null)
                throw new Exception("Tài khoản không tồn tại trong hệ thống. Vui lòng đăng ký trước.");

            // ── Bước 4: Kiểm tra trạng thái tài khoản ───────────────────────
            if (!user.IsActive || user.IsDeleted)
                throw new Exception("Tài khoản đã bị khóa hoặc bị xóa.");

            if (!user.IsEmailVerified)
                throw new Exception("Vui lòng xác nhận email trước khi đăng nhập.");

            // ── Bước 4.5: Cập nhật Google Avatar nếu cần ────────────────────
            if (!string.IsNullOrWhiteSpace(picture) && 
                (string.IsNullOrWhiteSpace(user.AvatarUrl) || user.AvatarUrl == "default.png"))
            {
                user.AvatarUrl = picture;
            }

            // ── Bước 5: Tạo JWT + RefreshToken (TÁI SỬ DỤNG _jwtService) ───
            var accessToken = _jwtService.GenerateAccessToken(user);
            var refreshToken = _jwtService.GenerateRefreshToken();

            refreshToken.UserId = user.UserId;
            user.RefreshTokens.Add(refreshToken);

            await _authRepository.SaveChangesAsync();

            // ── Bước 6: Trả AuthResponse (GIỐNG email login 100%) ───────────
            return new AuthResponse
            {
                UserId = user.UserId,
                FullName = user.FullName,
                Email = user.Email,
                Username = user.Username,
                Role = user.Role?.RoleName ?? "Student",
                AccessToken = accessToken,
                RefreshToken = refreshToken.Token
            };
        }

        /// <summary>
        /// Lấy email từ Google token — hỗ trợ 2 phương thức:
        ///   1. idToken (ưu tiên) → verify bằng GoogleJsonWebSignature.
        ///   2. accessToken (fallback cho Web) → gọi Google UserInfo API.
        /// </summary>
        private async Task<(string Email, string? Picture)> GetEmailFromGoogleAsync(GoogleLoginRequest request)
        {
            // ── Ưu tiên 1: Verify idToken (native/mobile) ───────────────────
            if (!string.IsNullOrWhiteSpace(request.IdToken))
            {
                try
                {
                    var googleClientId = _configuration["Google:ClientId"];

                    var settings = new GoogleJsonWebSignature.ValidationSettings
                    {
                        Audience = string.IsNullOrWhiteSpace(googleClientId)
                            ? null
                            : new[] { googleClientId }
                    };

                    var payload = await GoogleJsonWebSignature.ValidateAsync(request.IdToken, settings);

                    var email = payload.Email?.Trim().ToLower();
                    if (string.IsNullOrWhiteSpace(email))
                        throw new Exception("Không thể lấy email từ tài khoản Google.");

                    return (email, payload.Picture);
                }
                catch (InvalidJwtException)
                {
                    throw new Exception("Google token không hợp lệ hoặc đã hết hạn.");
                }
            }

            // ── Fallback 2: Dùng accessToken gọi Google UserInfo API (web) ──
            if (!string.IsNullOrWhiteSpace(request.AccessToken))
            {
                try
                {
                    using var httpClient = new HttpClient();
                    httpClient.DefaultRequestHeaders.Authorization =
                        new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", request.AccessToken);

                    var response = await httpClient.GetAsync("https://www.googleapis.com/oauth2/v3/userinfo");

                    if (!response.IsSuccessStatusCode)
                        throw new Exception("Google access token không hợp lệ hoặc đã hết hạn.");

                    var json = await response.Content.ReadAsStringAsync();
                    var userInfo = System.Text.Json.JsonSerializer.Deserialize<GoogleUserInfoResponse>(json);

                    var email = userInfo?.Email?.Trim().ToLower();
                    if (string.IsNullOrWhiteSpace(email))
                        throw new Exception("Không thể lấy email từ tài khoản Google.");

                    return (email, userInfo?.Picture);
                }
                catch (HttpRequestException)
                {
                    throw new Exception("Không thể kết nối đến Google để xác thực. Vui lòng thử lại.");
                }
            }

            // ── Không có token nào ──────────────────────────────────────────
            throw new Exception("Cần cung cấp idToken hoặc accessToken từ Google.");
        }

        /// <summary>
        /// DTO nội bộ để deserialize response từ Google UserInfo API.
        /// Endpoint: https://www.googleapis.com/oauth2/v3/userinfo
        /// </summary>
        private class GoogleUserInfoResponse
        {
            [System.Text.Json.Serialization.JsonPropertyName("email")]
            public string? Email { get; set; }

            [System.Text.Json.Serialization.JsonPropertyName("email_verified")]
            public bool EmailVerified { get; set; }

            [System.Text.Json.Serialization.JsonPropertyName("name")]
            public string? Name { get; set; }

            [System.Text.Json.Serialization.JsonPropertyName("picture")]
            public string? Picture { get; set; }
        }

        public async Task<AuthResponse> RefreshTokenAsync(string refreshToken)
        {
            var user = await _authRepository.GetByRefreshTokenAsync(refreshToken);

            if (user == null)
                throw new Exception("Refresh token không hợp lệ.");

            var oldToken = user.RefreshTokens.FirstOrDefault(x => x.Token == refreshToken);

            if (oldToken == null || oldToken.IsRevoked || oldToken.ExpiresAt <= DateTime.UtcNow)
                throw new Exception("Refresh token đã hết hạn hoặc đã bị thu hồi.");

            var newRefreshToken = _jwtService.GenerateRefreshToken();
            newRefreshToken.UserId = user.UserId;

            oldToken.IsRevoked = true;
            oldToken.RevokedAt = DateTime.UtcNow;
            oldToken.ReplaceByToken = newRefreshToken.Token;

            user.RefreshTokens.Add(newRefreshToken);

            var newAccessToken = _jwtService.GenerateAccessToken(user);

            await _authRepository.SaveChangesAsync();

            return new AuthResponse
            {
                UserId = user.UserId,
                FullName = user.FullName,
                Email = user.Email,
                Username = user.Username,
                Role = user.Role?.RoleName ?? "Student",
                AccessToken = newAccessToken,
                RefreshToken = newRefreshToken.Token
            };
        }

        public async Task<string> LogoutAsync(string refreshToken)
        {
            var user = await _authRepository.GetByRefreshTokenAsync(refreshToken);

            if (user == null)
                throw new Exception("Refresh token không hợp lệ.");

            var token = user.RefreshTokens.FirstOrDefault(x => x.Token == refreshToken);

            if (token == null || token.IsRevoked)
                throw new Exception("Token đã bị thu hồi.");

            token.IsRevoked = true;
            token.RevokedAt = DateTime.UtcNow;

            await _authRepository.SaveChangesAsync();

            return "Đăng xuất thành công.";
        }

        /// <summary>
        /// Xử lý yêu cầu quên mật khẩu.
        /// 
        /// Flow:
        ///   1. Tìm user theo email.
        ///   2. Nếu user tồn tại và đã verify email → tạo reset token + gửi email.
        ///   3. Luôn trả về message thành công (email enumeration protection).
        /// </summary>
        public async Task<string> ForgotPasswordAsync(string email)
        {
            var normalizedEmail = email.Trim().ToLower();
            var user = await _authRepository.GetByEmailAsync(normalizedEmail);

            // Email enumeration protection: luôn trả về thông báo giống nhau
            // dù email có tồn tại hay không.
            if (user == null || !user.IsEmailVerified || !user.IsActive || user.IsDeleted)
            {
                return "Nếu email tồn tại trong hệ thống, chúng tôi đã gửi link đặt lại mật khẩu.";
            }

            // Tạo reset token (dùng cùng pattern với EmailVerificationToken)
            var resetToken = Convert.ToHexString(RandomNumberGenerator.GetBytes(32));

            user.PasswordResetToken = resetToken;
            user.PasswordResetTokenExpiresAt = DateTime.UtcNow.AddMinutes(15);
            user.UpdatedAt = DateTime.UtcNow;

            await _authRepository.SaveChangesAsync();

            // Tạo reset link trỏ đến Frontend
            var frontendUrl = _configuration["App:FrontendUrl"]?.TrimEnd('/');
            if (string.IsNullOrEmpty(frontendUrl))
            {
                frontendUrl = "http://localhost:3000"; // Fallback nếu quên cấu hình
            }

            var resetLink = $"{frontendUrl}/#/reset-password?token={resetToken}";

            await _emailService.SendPasswordResetEmailAsync(user.Email, user.FullName, resetLink);

            return "Nếu email tồn tại trong hệ thống, chúng tôi đã gửi link đặt lại mật khẩu.";
        }

        /// <summary>
        /// Đặt lại mật khẩu bằng token từ email.
        /// 
        /// Flow:
        ///   1. Tìm user theo PasswordResetToken.
        ///   2. Kiểm tra token chưa hết hạn.
        ///   3. Hash mật khẩu mới.
        ///   4. Xóa reset token (one-time use).
        ///   5. Thu hồi TẤT CẢ refresh token (bảo mật: buộc đăng nhập lại).
        /// </summary>
        public async Task<string> ResetPasswordAsync(string token, string newPassword)
        {
            var user = await _authRepository.GetByPasswordResetTokenAsync(token);

            if (user == null)
                throw new Exception("Token đặt lại mật khẩu không hợp lệ.");

            if (user.PasswordResetTokenExpiresAt < DateTime.UtcNow)
                throw new Exception("Token đặt lại mật khẩu đã hết hạn. Vui lòng yêu cầu lại.");

            // Cập nhật mật khẩu mới
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(newPassword);

            // Xóa reset token (one-time use)
            user.PasswordResetToken = null;
            user.PasswordResetTokenExpiresAt = null;
            user.UpdatedAt = DateTime.UtcNow;

            // Thu hồi TẤT CẢ refresh token → buộc user đăng nhập lại ở mọi thiết bị
            foreach (var rt in user.RefreshTokens.Where(rt => !rt.IsRevoked))
            {
                rt.IsRevoked = true;
                rt.RevokedAt = DateTime.UtcNow;
            }

            await _authRepository.SaveChangesAsync();

            return "Đặt lại mật khẩu thành công. Vui lòng đăng nhập bằng mật khẩu mới.";
        }
    }
}
