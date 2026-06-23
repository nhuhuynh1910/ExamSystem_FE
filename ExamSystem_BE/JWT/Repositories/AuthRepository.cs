using JWT.Data;
using JWT.Models;
using JWT.Repositories.Contracts;
using Microsoft.EntityFrameworkCore;
using System.Reflection.Metadata.Ecma335;

namespace JWT.Repositories
{
    public class AuthRepository : IAuthRepository
    {
        private readonly ExamDb _context;

        public AuthRepository(ExamDb context)
        {
            _context = context;
        }

        public async Task<bool> EmailExistsAsync(string email)
        {
            return await _context.Users.AnyAsync(u => u.Email == email);
        }

        public async Task<User?> GetByUsernameAsync(string username)
        {
            return await _context.Users
                .Include(u => u.Role)
                .Include(u => u.RefreshTokens)
                .FirstOrDefaultAsync(u => u.Username == username && !u.IsDeleted);
        }

        public async Task<User?> GetByEmailAsync(string email)
        {
            return await _context.Users
                .Include(u => u.Role)
                .Include(u => u.RefreshTokens)
                .FirstOrDefaultAsync(u => u.Email == email && !u.IsDeleted);
        }


        public async Task<User?> GetByEmailOrUsernameAsync(string emailOrUsername)
        {
            return await _context.Users
                .Include(u => u.Role)
                .Include(u => u.RefreshTokens)
                .FirstOrDefaultAsync(u => (u.Email == emailOrUsername || u.Username == emailOrUsername) && !u.IsDeleted);
        }

        public async Task<User?> GetByRefreshTokenAsync(string refreshToken)
        {
            return await _context.Users
                .Include(u => u.Role)
                .Include(u => u.RefreshTokens)
                .FirstOrDefaultAsync(u => u.RefreshTokens.Any(rt => rt.Token == refreshToken) && !u.IsDeleted);
        }


        public async Task<User?> GetByVerificationTokenAsync(string token)
        {
            return await _context.Users
                .FirstOrDefaultAsync(u =>
                u.EmailVerificationToken == token &&
                    !u.IsDeleted);
        }

        public async Task AddUserAsync(User user)
        {
            await _context.Users.AddAsync(user);
        }

        public Task SaveChangesAsync()
        {
            return _context.SaveChangesAsync();
        }

        public Task<bool> UsernameExistsAsync(string username)
        {
            return _context.Users.AnyAsync(u => u.Username == username);
        }
    }
}
