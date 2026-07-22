using JWT.Data;
using JWT.Models;
using JWT.Repositories.Contracts;
using Microsoft.EntityFrameworkCore;

namespace JWT.Repositories
{
    public class RoleRepository : IRoleRepository
    {
        private readonly ExamDb _context;

        public RoleRepository(ExamDb context)
        {
            _context = context;
        }

        public Task<List<Role>> GetAllAsync()
        {
            return _context.Roles
                .OrderBy(r => r.RoleId)
                .ToListAsync();
        }
    }
}
