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

        [HttpGet]
        public async Task<IActionResult> GetSubjects()
        {
            try
            {
                var result = await _subjectService.GetSubjectsAsync(GetCurrentUserRole());
                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetSubjectById(int id)
        {
            try
            {
                var result = await _subjectService.GetSubjectByIdAsync(id, GetCurrentUserRole());
                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        [HttpPost]
        public async Task<IActionResult> CreateSubject(SubjectCreateDto request)
        {
            try
            {
                var result = await _subjectService.CreateSubjectAsync(
                    request,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return CreatedAtAction(nameof(GetSubjectById), new { id = result.SubjectId }, result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        [HttpPut("{id:int}")]
        public async Task<IActionResult> UpdateSubject(int id, SubjectUpdateDto request)
        {
            try
            {
                var result = await _subjectService.UpdateSubjectAsync(
                    id,
                    request,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        [HttpDelete("{id:int}")]
        public async Task<IActionResult> DeleteSubject(int id)
        {
            try
            {
                await _subjectService.DeleteSubjectAsync(
                    id,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return NoContent();
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        [HttpPost("{subjectId:int}/enroll")]
        public async Task<IActionResult> EnrollSubject(int subjectId)
        {
            try
            {
                var result = await _subjectService.EnrollSubjectAsync(
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

        [HttpGet("/api/students/{studentId:int}/subjects")]
        public async Task<IActionResult> GetStudentSubjects(int studentId)
        {
            try
            {
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

        [HttpGet("{subjectId:int}/students")]
        public async Task<IActionResult> GetSubjectStudents(int subjectId)
        {
            try
            {
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

        [HttpDelete("{subjectId:int}/unenroll")]
        public async Task<IActionResult> UnenrollSubject(int subjectId)
        {
            try
            {
                await _subjectService.UnenrollSubjectAsync(
                    subjectId,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return NoContent();
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        private string? GetCurrentUserId()
        {
            return User.FindFirstValue(ClaimTypes.NameIdentifier);
        }

        private string? GetCurrentUserRole()
        {
            return User.FindFirstValue(ClaimTypes.Role);
        }

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