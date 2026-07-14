using JWT.DTOs.Users;

namespace JWT.Services.Contracts
{
    public interface IUserService
    {
        Task<List<UserResponse>> GetAllAsync();
        Task<UserResponse> GetByIdAsync(int id);
        Task<ProfileResponse> GetProfileAsync(int userId);
        Task<UserResponse> UpdateAsync(int id, UpdateUserRequest request);
        Task<ProfileResponse> UpdateProfileAsync(int userId, UpdateProfileRequest request);
        Task<string> ChangePasswordAsync(int userId, ChangePasswordRequest request);
        Task<string> SoftDeleteAsync(int id);
    }
}
