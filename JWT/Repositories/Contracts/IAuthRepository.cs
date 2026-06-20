using JWT.Models;

namespace JWT.Repositories.Contracts
{
    public interface IAuthRepository
    {
        Task<User?> GetByEmailAsync(string email); // dùng cho login
        Task<User?> GetByUsernameAsync(string username); // dùng cho login
        Task<User?> GetByEmailOrUsernameAsync(string emailOrUsername); // dùng cho login
        Task<User?> GetByVerificationTokenAsync(string token); // dùng cho email verification
        Task<User?> GetByRefreshTokenAsync(string refreshToken); // dùng cho refresh token

        Task<bool> EmailExistsAsync(string email); // dùng cho register
        Task<bool> UsernameExistsAsync(string username); // dùng cho register

        Task AddUserAsync(User user); // dùng cho register
        Task SaveChangesAsync();
    }
}
