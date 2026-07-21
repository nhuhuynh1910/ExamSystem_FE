using JWT.DTOs.Subjects;
using JWT.Exceptions;
using JWT.Services.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace JWT.Controllers
{
    [Route("api/subjects")]
    [ApiController]
    [Authorize]
    public class SubjectsController : ControllerBase
    {
        private readonly ISubjectService _subjectService;

        public SubjectsController(ISubjectService subjectService)
        {
            _subjectService = subjectService;
        }

        // GET: api/subjects - Lấy danh sách tất cả các môn học
        [HttpGet]
        public async Task<IActionResult> GetSubjects()
        {
            try
            {
                // Gọi Service lấy danh sách môn học dựa trên vai trò của User hiện tại
                var result = await _subjectService.GetSubjectsAsync(GetCurrentUserRole());
                return Ok(result); // Trả về HTTP 200 kèm danh sách
            }
            catch (Exception ex)
            {
                return HandleException(ex); // Xử lý ngoại lệ nếu có
            }
        }

        // GET: api/subjects/{id} - Xem chi tiết một môn học theo ID
        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetSubjectById(int id)
        {
            try
            {
                // Gọi Service lấy thông tin chi tiết môn học
                var result = await _subjectService.GetSubjectByIdAsync(id, GetCurrentUserRole());
                return Ok(result); // Trả về HTTP 200 kèm DTO môn học
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // POST: api/subjects - Admin tạo mới môn học
        [HttpPost]
        public async Task<IActionResult> CreateSubject(SubjectCreateDto request)
        {
            try
            {
                // Gọi Service thực hiện logic tạo môn học
                var result = await _subjectService.CreateSubjectAsync(
                    request,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                // Trả về HTTP 201 Created cùng URL truy cập môn học vừa tạo
                return CreatedAtAction(nameof(GetSubjectById), new { id = result.SubjectId }, result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // PUT: api/subjects/{id} - Admin cập nhật/chỉnh sửa thông tin môn học
        [HttpPut("{id:int}")]
        public async Task<IActionResult> UpdateSubject(int id, SubjectUpdateDto request)
        {
            try
            {
                // Gọi Service thực hiện cập nhật thông tin môn học
                var result = await _subjectService.UpdateSubjectAsync(
                    id,
                    request,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result); // Trả về HTTP 200 kèm thông tin môn học sau khi sửa
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // DELETE: api/subjects/{id} - Admin xóa mềm môn học
        [HttpDelete("{id:int}")]
        public async Task<IActionResult> DeleteSubject(int id)
        {
            try
            {
                // Gọi Service thực hiện xóa mềm môn học
                await _subjectService.DeleteSubjectAsync(
                    id,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return NoContent(); // Trả về HTTP 244 NoContent báo thành công
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // POST: api/subjects/{subjectId}/enroll - Sinh viên đăng ký môn học
        [HttpPost("{subjectId:int}/enroll")]
        public async Task<IActionResult> EnrollSubject(int subjectId)
        {
            try
            {
                // Gọi Service thực hiện đăng ký môn học cho Sinh viên
                var result = await _subjectService.EnrollSubjectAsync(
                    subjectId,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result); // Trả về HTTP 200 kèm thông tin đăng ký
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // GET: api/students/{studentId}/subjects - Xem danh sách các môn học Sinh viên đã đăng ký
        [HttpGet("/api/students/{studentId:int}/subjects")]
        public async Task<IActionResult> GetStudentSubjects(int studentId)
        {
            try
            {
                // Gọi Service lấy danh sách môn học của sinh viên
                var result = await _subjectService.GetStudentSubjectsAsync(
                    studentId,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // GET: api/subjects/{subjectId}/students - Xem danh sách Sinh viên đã đăng ký môn học này
        [HttpGet("{subjectId:int}/students")]
        public async Task<IActionResult> GetSubjectStudents(int subjectId)
        {
            try
            {
                // Gọi Service lấy danh sách các sinh viên đã enroll môn học
                var result = await _subjectService.GetSubjectStudentsAsync(
                    subjectId,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // DELETE: api/subjects/{subjectId}/unenroll - Sinh viên hủy đăng ký môn học
        [HttpDelete("{subjectId:int}/unenroll")]
        public async Task<IActionResult> UnenrollSubject(int subjectId)
        {
            try
            {
                // Gọi Service thực hiện hủy đăng ký
                await _subjectService.UnenrollSubjectAsync(
                    subjectId,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return NoContent(); // Trả về HTTP 204 NoContent thành công
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // GET /api/subjects/assigned — Giáo viên lấy danh sách môn học được phân công giảng dạy
        [HttpGet("assigned")]
        [Authorize(Roles = "Teacher,Admin")]
        public async Task<IActionResult> GetAssignedSubjects()
        {
            try
            {
                var result = await _subjectService.GetTeacherSubjectsAsync(
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // GET /api/subjects/{subjectId}/teachers — Xem danh sách giáo viên được phân công môn học này
        [HttpGet("{subjectId:int}/teachers")]
        [Authorize(Roles = "Admin,Teacher")]
        public async Task<IActionResult> GetSubjectTeachers(int subjectId)
        {
            try
            {
                var result = await _subjectService.GetSubjectTeachersAsync(
                    subjectId,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // POST /api/subjects/{subjectId}/assign-teacher/{teacherId} — Admin gán giáo viên vào môn học
        [HttpPost("{subjectId:int}/assign-teacher/{teacherId:int}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> AssignTeacher(int subjectId, int teacherId)
        {
            try
            {
                var result = await _subjectService.AssignTeacherAsync(
                    subjectId,
                    teacherId,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // DELETE /api/subjects/{subjectId}/unassign-teacher/{teacherId} — Admin gỡ giáo viên khỏi môn học
        [HttpDelete("{subjectId:int}/unassign-teacher/{teacherId:int}")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> UnassignTeacher(int subjectId, int teacherId)
        {
            try
            {
                await _subjectService.UnassignTeacherAsync(
                    subjectId,
                    teacherId,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return NoContent();
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // Đọc User ID từ Claim NameIdentifier trong Token JWT
        private string? GetCurrentUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier);
        }

        // Đọc Role từ Claim Role trong Token JWT
        private string? GetCurrentUserRole()
        {
            return User.FindFirstValue(ClaimTypes.Role);
        }

        // Hàm tập trung xử lý các Exception và chuyển đổi thành HTTP Status Code tương ứng
        private IActionResult HandleException(Exception ex)
        {
            return ex switch
            {
                UnauthorizedException => Unauthorized(new { message = ex.Message }),
                BadRequestException => BadRequest(new { message = ex.Message }),
                ForbiddenException => StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message }),
                NotFoundException => NotFound(new { message = ex.Message }),
                ConflictException => Conflict(new { message = ex.Message }),
                _ => StatusCode(StatusCodes.Status500InternalServerError, new { message = ex.Message })
            };
        }
    }
}