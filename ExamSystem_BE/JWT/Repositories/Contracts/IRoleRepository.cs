using JWT.Models;

namespace JWT.Repositories.Contracts
{
    public interface IRoleRepository
    {
        Task<List<Role>> GetAllAsync();
    }
}
