using JWT.DTOs.BaoTecherRequests;
using JWT.DTOs.Exam;
using JWT.Exceptions;
using JWT.Services.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace JWT.Controllers
{
    /// <summary>
    /// Bao - user gui request tro thanh Teacher va Admin xem request.
    /// </summary>
    [ApiController]
    [Authorize]
    public class BaoTecherRequestController : ControllerBase
    {
        private readonly IBaoTecherRequestService _baoTecherRequestService;

        public BaoTecherRequestController(IBaoTecherRequestService baoTecherRequestService)
        {
            _baoTecherRequestService = baoTecherRequestService;
        }

        /// <summary>
        /// Student gui yeu cau tro thanh Teacher, Teacher gui yeu cau xin day them mon.
        /// </summary>
        /// <response code="201">Tao request thanh cong.</response>
        /// <response code="400">Du lieu khong hop le.</response>
        /// <response code="401">Token khong hop le.</response>
        /// <response code="403">Khong phai Student/Teacher hoac user la Admin.</response>
        /// <response code="404">Khong tim thay subject.</response>
        /// <response code="409">Dang co request Pending cho mon nay hoac Teacher da day mon nay.</response>
        [HttpPost("api/teacher-requests")]
        [ProducesResponseType(typeof(BaoTecherRequestResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> Create([FromForm] BaoTecherRequestCreateDto request)
        {
            try
            {
                var result = await _baoTecherRequestService.CreateAsync(
                    request,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return CreatedAtAction(
                    nameof(GetById),
                    new { id = result.TeacherRequestId },
                    result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        /// <summary>
        /// User xem danh sach subject con co the gui request.
        /// </summary>
        /// <response code="200">Tra ve danh sach subject con hoat dong.</response>
        /// <response code="401">Token khong hop le.</response>
        /// <response code="403">Admin khong can gui request.</response>
        [HttpGet("api/teacher-requests/available-subjects")]
        [ProducesResponseType(typeof(List<BaoTecherRequestAvailableSubjectDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> GetAvailableSubjects()
        {
            try
            {
                var result = await _baoTecherRequestService.GetAvailableSubjectsAsync(
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        /// <summary>
        /// User xem danh sach teacher request cua minh.
        /// </summary>
        /// <response code="200">Tra ve danh sach request cua user hien tai.</response>
        /// <response code="401">Token khong hop le.</response>
        [HttpGet("api/teacher-requests/my-requests")]
        [ProducesResponseType(typeof(List<BaoTecherRequestResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> GetMyRequests()
        {
            try
            {
                var result = await _baoTecherRequestService.GetMyRequestsAsync(
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        /// <summary>
        /// User huy teacher request Pending cua chinh minh.
        /// </summary>
        /// <response code="200">Huy request thanh cong.</response>
        /// <response code="400">Request khong con Pending.</response>
        /// <response code="401">Token khong hop le.</response>
        /// <response code="403">Admin khong the huy request cua user.</response>
        /// <response code="404">Khong tim thay request cua user hien tai.</response>
        [HttpPut("api/teacher-requests/{id:int}/cancel")]
        [ProducesResponseType(typeof(BaoTecherRequestResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Cancel(int id)
        {
            try
            {
                var result = await _baoTecherRequestService.CancelAsync(
                    id,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        /// <summary>
        /// Admin xem danh sach yeu cau tro thanh Teacher.
        /// </summary>
        /// <response code="200">Tra ve danh sach request.</response>
        /// <response code="400">Filter khong hop le.</response>
        /// <response code="401">Token khong hop le.</response>
        /// <response code="403">Khong phai Admin.</response>
        [HttpGet("api/admin/teacher-requests")]
        [ProducesResponseType(typeof(PagedResultDto<BaoTecherRequestResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> GetRequests([FromQuery] BaoTecherRequestFilterDto filter)
        {
            try
            {
                var result = await _baoTecherRequestService.GetRequestsAsync(
                    filter,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        /// <summary>
        /// Admin xem chi tiet request.
        /// </summary>
        /// <response code="200">Tra ve chi tiet request.</response>
        /// <response code="401">Token khong hop le.</response>
        /// <response code="403">Khong phai Admin.</response>
        /// <response code="404">Khong tim thay request.</response>
        [HttpGet("api/admin/teacher-requests/{id:int}")]
        [ProducesResponseType(typeof(BaoTecherRequestResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetById(int id)
        {
            try
            {
                var result = await _baoTecherRequestService.GetRequestByIdAsync(
                    id,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        /// <summary>
        /// Admin duyet yeu cau len Teacher.
        /// </summary>
        /// <response code="200">Duyet request thanh cong.</response>
        /// <response code="400">Request khong con Pending.</response>
        /// <response code="401">Token khong hop le.</response>
        /// <response code="403">Khong phai Admin hoac user da bi xoa.</response>
        /// <response code="404">Khong tim thay request/user/role.</response>
        [HttpPut("api/admin/teacher-requests/{id:int}/approve")]
        [ProducesResponseType(typeof(BaoTecherRequestResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Approve(int id)
        {
            try
            {
                var result = await _baoTecherRequestService.ApproveAsync(
                    id,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        /// <summary>
        /// Admin tu choi yeu cau len Teacher.
        /// </summary>
        /// <response code="200">Tu choi request thanh cong.</response>
        /// <response code="400">Request khong con Pending.</response>
        /// <response code="401">Token khong hop le.</response>
        /// <response code="403">Khong phai Admin hoac user da bi xoa.</response>
        /// <response code="404">Khong tim thay request/user.</response>
        [HttpPut("api/admin/teacher-requests/{id:int}/reject")]
        [ProducesResponseType(typeof(BaoTecherRequestResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Reject(
            int id,
            BaoTecherRequestRejectDto request)
        {
            try
            {
                var result = await _baoTecherRequestService.RejectAsync(
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
