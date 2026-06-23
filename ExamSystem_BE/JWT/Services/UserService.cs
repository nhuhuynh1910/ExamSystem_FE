using JWT.DTOs.Users;
using JWT.Models;
using JWT.Repositories.Contracts;
using JWT.Services.Contracts;

namespace JWT.Services
{
    public class UserService : IUserService
    {
        private const long MaxProfileImageFileSize = 5 * 1024 * 1024;
        private static readonly HashSet<string> AllowedProfileImageExtensions = new(StringComparer.OrdinalIgnoreCase)
        {
            ".jpg",
            ".jpeg",
            ".png"
        };

        private readonly IUserRepository _userRepository;
        private readonly IWebHostEnvironment _environment;

        public UserService(
            IUserRepository userRepository,
            IWebHostEnvironment environment)
        {
            _userRepository = userRepository;
            _environment = environment;
        }

        public async Task<List<UserResponse>> GetAllAsync()
        {
            var users = await _userRepository.GetAllAsync();

            return users.Select(MapToResponse).ToList();
        }

        public async Task<UserResponse> GetByIdAsync(int id)
        {
            var user = await _userRepository.GetByIdAsync(id);

            if (user == null)
                throw new Exception("Không tìm thấy user.");

            return MapToResponse(user);
        }

        public async Task<ProfileResponse> GetProfileAsync(int userId)
        {
            var user = await _userRepository.GetByIdAsync(userId);

            if (user == null)
                throw new Exception("Không tìm thấy user.");

            return MapToProfileResponse(user);
        }

        public async Task<UserResponse> UpdateAsync(int id, UpdateUserRequest request)
        {
            var user = await _userRepository.GetByIdAsync(id);

            if (user == null)
                throw new Exception("Không tìm thấy user.");

            var email = request.Email.Trim().ToLower();
            var username = request.Username.Trim();

            if (await _userRepository.EmailExistsAsync(email, id))
                throw new Exception("Email đã tồn tại.");

            if (await _userRepository.UsernameExistsAsync(username, id))
                throw new Exception("Username đã tồn tại.");

            if (!await _userRepository.RoleExistsAsync(request.RoleId))
                throw new Exception("Role không tồn tại.");

            user.FullName = request.FullName.Trim();
            user.Email = email;
            user.Username = username;
            var profileImageUrl = await SaveProfileImageAsync(request.ProfileImageUrl, id);
            if (!string.IsNullOrWhiteSpace(profileImageUrl))
            {
                user.AvatarUrl = profileImageUrl;
            }
            user.IsActive = request.IsActive;
            user.RoleId = request.RoleId;
            user.UpdatedAt = DateTime.UtcNow;

            if (!string.IsNullOrWhiteSpace(request.Password))
                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

            await _userRepository.SaveChangesAsync();

            return MapToResponse(user);
        }

        public async Task<ProfileResponse> UpdateProfileAsync(int userId, UpdateProfileRequest request)
        {
            var user = await _userRepository.GetByIdAsync(userId);

            if (user == null)
                throw new Exception("Không tìm thấy user.");

            if (request.FullName != null)
            {
                var fullName = request.FullName.Trim();

                if (string.IsNullOrWhiteSpace(fullName))
                    throw new Exception("FullName không được để trống.");

                user.FullName = fullName;
            }

            if (request.Username != null)
            {
                var username = request.Username.Trim();

                if (string.IsNullOrWhiteSpace(username))
                    throw new Exception("Username không được để trống.");

                if (await _userRepository.UsernameExistsAsync(username, userId))
                    throw new Exception("Username đã tồn tại.");

                user.Username = username;
            }

            var profileImageUrl = await SaveProfileImageAsync(request.ProfileImageUrl, userId);
            if (!string.IsNullOrWhiteSpace(profileImageUrl))
            {
                user.AvatarUrl = profileImageUrl;
            }
            user.UpdatedAt = DateTime.UtcNow;

            await _userRepository.SaveChangesAsync();

            return MapToProfileResponse(user);
        }

        public async Task<string> SoftDeleteAsync(int id)
        {
            var user = await _userRepository.GetByIdAsync(id);

            if (user == null)
                throw new Exception("Không tìm thấy user.");

            user.IsDeleted = true;
            user.UpdatedAt = DateTime.UtcNow;

            await _userRepository.SaveChangesAsync();

            return "Xóa user thành công.";
        }

        private static UserResponse MapToResponse(User user)
        {
            return new UserResponse
            {
                UserId = user.UserId,
                FullName = user.FullName,
                Email = user.Email,
                Username = user.Username,
                ProfileImageUrl = user.AvatarUrl,
                IsActive = user.IsActive,
                IsEmailVerified = user.IsEmailVerified,
                RoleId = user.RoleId,
                Role = user.Role?.RoleName ?? string.Empty,
                CreatedAt = user.CreatedAt,
                UpdatedAt = user.UpdatedAt
            };
        }

        private static ProfileResponse MapToProfileResponse(User user)
        {
            return new ProfileResponse
            {
                UserId = user.UserId,
                FullName = user.FullName,
                Username = user.Username,
                ProfileImageUrl = user.AvatarUrl
            };
        }

        private async Task<string?> SaveProfileImageAsync(
            IFormFile? profileImageFile,
            int userId)
        {
            if (profileImageFile == null || profileImageFile.Length == 0)
            {
                return null;
            }

            if (profileImageFile.Length > MaxProfileImageFileSize)
            {
                throw new Exception("Profile image tối đa 5MB.");
            }

            var extension = Path.GetExtension(profileImageFile.FileName);

            if (string.IsNullOrWhiteSpace(extension) ||
                !AllowedProfileImageExtensions.Contains(extension))
            {
                throw new Exception("Profile image chỉ chấp nhận jpg, jpeg hoặc png.");
            }

            var webRootPath = _environment.WebRootPath;

            if (string.IsNullOrWhiteSpace(webRootPath))
            {
                webRootPath = Path.Combine(_environment.ContentRootPath, "wwwroot");
            }

            var relativeFolder = Path.Combine("uploads", "profile-images");
            var uploadFolder = Path.Combine(webRootPath, relativeFolder);
            Directory.CreateDirectory(uploadFolder);

            var safeFileName = $"{userId}_{DateTime.Now:yyyyMMddHHmmss}_{Guid.NewGuid():N}{extension.ToLowerInvariant()}";
            var filePath = Path.Combine(uploadFolder, safeFileName);

            await using var stream = new FileStream(filePath, FileMode.CreateNew);
            await profileImageFile.CopyToAsync(stream);

            return $"/uploads/profile-images/{safeFileName}";
        }
    }
}
