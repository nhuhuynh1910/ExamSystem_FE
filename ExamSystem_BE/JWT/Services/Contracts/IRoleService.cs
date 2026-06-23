using JWT.DTOs.Roles;

namespace JWT.Services.Contracts
{
    public interface IRoleService
    {
        Task<List<RoleResponse>> GetAllAsync();
    }
}
