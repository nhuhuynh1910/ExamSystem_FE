using JWT.DTOs.Auth;
using JWT.Models;
using JWT.Repositories.Contracts;
using JWT.Services.Contracts;
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

            var verifyToken = Convert.ToHexString(RandomNumberGenerator.GetBytes(32));

            var user = new User
            {
                FullName = request.FullName.Trim(),
                Email = email,
                Username = username,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                RoleId = 3,
                IsEmailVerified = false,
                EmailVerificationToken = verifyToken,
                EmailVerificationTokenExpiresAt = DateTime.UtcNow.AddHours(24),
                AvatarUrl = "default.png",
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
    }
}
