using JWT.DTOs.Users;
using JWT.Services.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JWT.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Admin")]
    public class UsersController : ControllerBase
    {
        private readonly IUserService _userService;

        public UsersController(IUserService userService)
        {
            _userService = userService;
        }

        // GET: api/users - Admin lấy danh sách tất cả các User trong hệ thống
        [HttpGet]
        public async Task<IActionResult> GetUsers()
        {
            // Gọi Service lấy tất cả User và trả về HTTP 200 kèm danh sách User
            var users = await _userService.GetAllAsync();
            return Ok(users);
        }

        // GET: api/users/{id} - Admin lấy thông tin chi tiết một User theo ID
        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetUser(int id)
        {
            try
            {
                // Gọi Service lấy thông tin User
                var user = await _userService.GetByIdAsync(id);
                return Ok(user);
            }
            catch (Exception ex)
            {
                // Trả về HTTP 404 nếu không tìm thấy User
                return NotFound(new { message = ex.Message });
            }
        }

        // PUT: api/users/{id} - Admin cập nhật thông tin User (Tên, Email, Role, Avatar, Mật khẩu...)
        [HttpPut("{id:int}")]
        public async Task<IActionResult> UpdateUser(int id, [FromForm] UpdateUserRequest request)
        {
            try
            {
                // Gọi Service thực hiện cập nhật thông tin User
                var user = await _userService.UpdateAsync(id, request);
                return Ok(user);
            }
            catch (Exception ex)
            {
                // Trả về HTTP 400 BadRequest nếu dữ liệu không hợp lệ hoặc bị trùng Email/Username
                return BadRequest(new { message = ex.Message });
            }
        }

        // DELETE: api/users/{id} - Admin thực hiện xóa mềm User (IsDeleted = true)
        [HttpDelete("{id:int}")]
        public async Task<IActionResult> DeleteUser(int id)
        {
            try
            {
                // Gọi Service thực hiện xóa mềm
                var result = await _userService.SoftDeleteAsync(id);
                return Ok(new { message = result });
            }
            catch (Exception ex)
            {
                // Trả về HTTP 404 Not Found nếu không tìm thấy User
                return NotFound(new { message = ex.Message });
            }
        }
    }
}
