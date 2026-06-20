using JWT.DTOs.Auth;

namespace JWT.Services.Contracts
{
    public interface IAuthService
    {
        Task<string> RegisterAsync(RegisterRequest request);
        Task<string> ResendVerificationEmailAsync(string email);
        Task<string> VerifyEmailAsync(string token);
        Task<AuthResponse> LoginAsync(LoginRequest request);
        Task<AuthResponse> RefreshTokenAsync(string refreshToken);
        Task<string> LogoutAsync(string refreshToken);
    }
}
