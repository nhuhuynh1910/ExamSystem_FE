using System.Security.Claims;
using JWT.DTOs.Users;
using JWT.Services.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JWT.Controllers
{
    [Route("api/profile")]
    [ApiController]
    [Authorize]
    public class ProfileController : ControllerBase
    {
        private readonly IUserService _userService;

        public ProfileController(IUserService userService)
        {
            _userService = userService;
        }

        [HttpGet]
        public async Task<IActionResult> GetProfile()
        {
            try
            {
                var userId = GetCurrentUserId();
                var profile = await _userService.GetProfileAsync(userId);
                return Ok(profile);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpPut]
        public async Task<IActionResult> UpdateProfile([FromForm] UpdateProfileRequest request)
        {
            try
            {
                var userId = GetCurrentUserId();
                var profile = await _userService.UpdateProfileAsync(userId, request);
                return Ok(profile);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Đổi mật khẩu. Nếu user có password cũ → phải nhập OldPassword.
        /// Nếu user Google-only (chưa có password) → chỉ cần NewPassword + ConfirmPassword.
        /// </summary>
        [HttpPost("change-password")]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
        {
            try
            {
                var userId = GetCurrentUserId();
                var message = await _userService.ChangePasswordAsync(userId, request);
                return Ok(new { message });
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        /// <summary>
        /// Upload avatar (placeholder — thiết kế sẵn endpoint, sau này chỉ cần thay service).
        /// </summary>
        [HttpPost("avatar")]
        public async Task<IActionResult> UploadAvatar(IFormFile file)
        {
            try
            {
                if (file == null || file.Length == 0)
                    return BadRequest(new { message = "Vui lòng chọn ảnh." });

                var userId = GetCurrentUserId();
                var updateRequest = new UpdateProfileRequest { ProfileImageUrl = file };
                var profile = await _userService.UpdateProfileAsync(userId, updateRequest);
                return Ok(profile);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Unauthorized(new { message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        private int GetCurrentUserId()
        {
            var userIdClaim = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (!int.TryParse(userIdClaim, out var userId))
                throw new UnauthorizedAccessException("User id not found in token.");

            return userId;
        }
    }
}

