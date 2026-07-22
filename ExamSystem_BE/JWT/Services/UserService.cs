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

        // 1. Lấy danh sách tất cả người dùng trong hệ thống
        public async Task<List<UserResponse>> GetAllAsync()
        {
            // Truy vấn lấy danh sách toàn bộ User từ Repository
            var users = await _userRepository.GetAllAsync();

            // Chuyển đổi (Map) từng User sang DTO UserResponse để trả về client
            return users.Select(MapToResponse).ToList();
        }

        // 2. Lấy thông tin chi tiết một User theo ID
        public async Task<UserResponse> GetByIdAsync(int id)
        {
            // Tìm User theo ID trong CSDL
            var user = await _userRepository.GetByIdAsync(id);

            // Không tìm thấy -> Ném ngoại lệ
            if (user == null)
                throw new Exception("Không tìm thấy user.");

            // Trả về DTO thông tin User
            return MapToResponse(user);
        }

        // 3. Lấy thông tin Profile cá nhân của người dùng đang đăng nhập
        public async Task<ProfileResponse> GetProfileAsync(int userId)
        {
            // Lấy thông tin User theo UserId
            var user = await _userRepository.GetByIdAsync(userId);

            if (user == null)
                throw new Exception("Không tìm thấy user.");

            // Trả về ProfileResponse (bao gồm định dạng Mã sinh viên/Mã giáo viên)
            return MapToProfileResponse(user);
        }

        // 4. Cập nhật thông tin User (Dành cho Admin quản lý User)
        public async Task<UserResponse> UpdateAsync(int id, UpdateUserRequest request)
        {
            // Tìm User cần cập nhật trong CSDL
            var user = await _userRepository.GetByIdAsync(id);

            if (user == null)
                throw new Exception("Không tìm thấy user.");

            // Chuẩn hóa Email và Username (viết thường, xóa khoảng trắng)
            var email = request.Email.Trim().ToLower();
            var username = request.Username.Trim();

            // Kiểm tra Email trùng lặp với người dùng khác
            if (await _userRepository.EmailExistsAsync(email, id))
                throw new Exception("Email đã tồn tại.");

            // Kiểm tra Username trùng lặp với người dùng khác
            if (await _userRepository.UsernameExistsAsync(username, id))
                throw new Exception("Username đã tồn tại.");

            // Kiểm tra RoleId có hợp lệ không
            if (!await _userRepository.RoleExistsAsync(request.RoleId))
                throw new Exception("Role không tồn tại.");

            // Cập nhật các thông tin cá nhân
            user.FullName = request.FullName.Trim();
            user.Email = email;
            user.Username = username;

            // Xử lý upload ảnh đại diện (avatar) nếu có gửi file ảnh mới
            var profileImageUrl = await SaveProfileImageAsync(request.ProfileImageUrl, id);
            if (!string.IsNullOrWhiteSpace(profileImageUrl))
            {
                user.AvatarUrl = profileImageUrl;
            }

            user.IsActive = request.IsActive;   // Cập nhật trạng thái Tài khoản (Hoạt động/Tạm khóa)
            user.RoleId = request.RoleId;       // Cập nhật Vai trò (Role)
            user.UpdatedAt = DateTime.UtcNow;     // Cập nhật thời điểm chỉnh sửa (UTC)

            // Nếu Admin có nhập mật khẩu mới -> Mã hóa mật khẩu bằng BCrypt
            if (!string.IsNullOrWhiteSpace(request.Password))
                user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

            // Lưu các thay đổi xuống CSDL
            await _userRepository.SaveChangesAsync();

            return MapToResponse(user);
        }

        // 5. Cập nhật Profile cá nhân của người dùng
        public async Task<ProfileResponse> UpdateProfileAsync(int userId, UpdateProfileRequest request)
        {
            var user = await _userRepository.GetByIdAsync(userId);

            if (user == null)
                throw new Exception("Không tìm thấy user.");

            // Nếu có cập nhật Họ và Tên
            if (request.FullName != null)
            {
                var fullName = request.FullName.Trim();

                if (string.IsNullOrWhiteSpace(fullName))
                    throw new Exception("FullName không được để trống.");

                user.FullName = fullName;
            }

            // Nếu có cập nhật Username
            if (request.Username != null)
            {
                var username = request.Username.Trim();

                if (string.IsNullOrWhiteSpace(username))
                    throw new Exception("Username không được để trống.");

                // Kiểm tra xem Username mới có bị đụng hàng không
                if (await _userRepository.UsernameExistsAsync(username, userId))
                    throw new Exception("Username đã tồn tại.");

                user.Username = username;
            }

            // Lưu file ảnh đại diện mới (nếu có)
            var profileImageUrl = await SaveProfileImageAsync(request.ProfileImageUrl, userId);
            if (!string.IsNullOrWhiteSpace(profileImageUrl))
            {
                user.AvatarUrl = profileImageUrl;
            }
            user.UpdatedAt = DateTime.UtcNow;

            // Lưu thay đổi xuống CSDL
            await _userRepository.SaveChangesAsync();

            return MapToProfileResponse(user);
        }

        // 6. Đổi mật khẩu tài khoản
        public async Task<string> ChangePasswordAsync(int userId, ChangePasswordRequest request)
        {
            var user = await _userRepository.GetByIdAsync(userId);

            if (user == null)
                throw new Exception("Không tìm thấy user.");

            // Kiểm tra user đã có mật khẩu chưa (Tài khoản tạo bằng Google có thể chưa có mật khẩu)
            var hasExistingPassword = !string.IsNullOrWhiteSpace(user.PasswordHash)
                && user.PasswordHash != "GOOGLE_NO_PASSWORD";

            if (hasExistingPassword)
            {
                // Nếu đã có mật khẩu -> Yêu cầu nhập đúng mật khẩu hiện tại
                if (string.IsNullOrWhiteSpace(request.OldPassword))
                    throw new Exception("Vui lòng nhập mật khẩu hiện tại.");

                // Kiểm tra mật khẩu cũ bằng BCrypt Verify
                if (!BCrypt.Net.BCrypt.Verify(request.OldPassword, user.PasswordHash))
                    throw new Exception("Mật khẩu hiện tại không đúng.");
            }

            // Kiểm tra độ dài mật khẩu mới (tối thiểu 6 ký tự)
            if (string.IsNullOrWhiteSpace(request.NewPassword) || request.NewPassword.Length < 6)
                throw new Exception("Mật khẩu mới phải có ít nhất 6 ký tự.");

            // Kiểm tra xác nhận mật khẩu có trùng khớp không
            if (request.NewPassword != request.ConfirmPassword)
                throw new Exception("Xác nhận mật khẩu không khớp.");

            // Mã hóa mật khẩu mới bằng BCrypt Hash và cập nhật
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
            user.UpdatedAt = DateTime.UtcNow;

            await _userRepository.SaveChangesAsync();

            return "Đổi mật khẩu thành công.";
        }

        // 7. Xóa mềm tài khoản User (Soft Delete)
        public async Task<string> SoftDeleteAsync(int id)
        {
            var user = await _userRepository.GetByIdAsync(id);

            if (user == null)
                throw new Exception("Không tìm thấy user.");

            // Đánh dấu xóa mềm IsDeleted = true
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
            var roleName = user.Role?.RoleName ?? "Student";

            // Format StudentId / TeacherId từ UserId (không cần field DB riêng)
            string? studentId = null;
            string? teacherId = null;

            if (roleName.Equals("Student", StringComparison.OrdinalIgnoreCase))
                studentId = $"HE{user.UserId:D6}";
            else if (roleName.Equals("Teacher", StringComparison.OrdinalIgnoreCase))
                teacherId = $"TE{user.UserId:D6}";

            // Kiểm tra user có password hay không (Google-only account)
            var hasPassword = !string.IsNullOrWhiteSpace(user.PasswordHash)
                && user.PasswordHash != "GOOGLE_NO_PASSWORD";

            return new ProfileResponse
            {
                UserId = user.UserId,
                FullName = user.FullName,
                Email = user.Email,
                Username = user.Username,
                Role = roleName,
                StudentId = studentId,
                TeacherId = teacherId,
                IsEmailVerified = user.IsEmailVerified,
                CreatedAt = user.CreatedAt,
                ProfileImageUrl = user.AvatarUrl,
                HasPassword = hasPassword,
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
