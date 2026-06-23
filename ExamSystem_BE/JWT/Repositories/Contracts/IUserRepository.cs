using JWT.Models;

namespace JWT.Repositories.Contracts
{
    public interface IUserRepository
    {
        Task<List<User>> GetAllAsync();
        Task<User?> GetByIdAsync(int id);
        Task<bool> EmailExistsAsync(string email, int? excludeUserId = null);
        Task<bool> UsernameExistsAsync(string username, int? excludeUserId = null);
        Task<bool> RoleExistsAsync(int roleId);
        Task SaveChangesAsync();
    }
}
