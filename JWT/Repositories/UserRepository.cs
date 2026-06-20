using JWT.Data;
using JWT.Models;
using JWT.Repositories.Contracts;
using Microsoft.EntityFrameworkCore;

namespace JWT.Repositories
{
    public class UserRepository : IUserRepository
    {
        private readonly ExamDb _context;

        public UserRepository(ExamDb context)
        {
            _context = context;
        }

        public Task<List<User>> GetAllAsync()
        {
            return _context.Users
                .Include(u => u.Role)
                .Where(u => !u.IsDeleted)
                .OrderByDescending(u => u.CreatedAt)
                .ToListAsync();
        }

        public Task<User?> GetByIdAsync(int id)
        {
            return _context.Users
                .Include(u => u.Role)
                .FirstOrDefaultAsync(u => u.UserId == id && !u.IsDeleted);
        }

        public Task<bool> EmailExistsAsync(string email, int? excludeUserId = null)
        {
            return _context.Users.AnyAsync(u =>
                u.Email == email &&
                (!excludeUserId.HasValue || u.UserId != excludeUserId.Value));
        }

        public Task<bool> UsernameExistsAsync(string username, int? excludeUserId = null)
        {
            return _context.Users.AnyAsync(u =>
                u.Username == username &&
                (!excludeUserId.HasValue || u.UserId != excludeUserId.Value));
        }

        public Task<bool> RoleExistsAsync(int roleId)
        {
            return _context.Roles.AnyAsync(r => r.RoleId == roleId);
        }

        public Task SaveChangesAsync()
        {
            return _context.SaveChangesAsync();
        }
    }
}
