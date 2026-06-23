using JWT.Models;

namespace JWT.Services.Contracts
{
    public interface IJwtService
    {
        string GenerateAccessToken(User user);
        RefreshToken GenerateRefreshToken();
    }
}
