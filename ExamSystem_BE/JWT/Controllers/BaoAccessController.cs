using JWT.DTOs.BaoAccess;
using JWT.Exceptions;
using JWT.Services.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace JWT.Controllers
{
    /// <summary>
    /// Bao - kiem tra quyen truy cap truoc khi Student join bai thi.
    /// </summary>
    [Route("api/exams")]
    [ApiController]
    [Authorize]
    public class BaoAccessController : ControllerBase
    {
        private readonly IBaoAccessService _baoAccessService;

        public BaoAccessController(IBaoAccessService baoAccessService)
        {
            _baoAccessService = baoAccessService;
        }

        /// <summary>
        /// Kiem tra Student co du quyen join hay khong.
        /// </summary>
        /// <remarks>
        /// Chi Student duoc check de join.
        /// De thi phai ton tai, Published, dang trong thoi gian thi,
        /// Student da enroll subject, private thi AccessCode phai dung
        /// va Student chua vuot MaxAttempts.
        /// </remarks>
        /// <response code="200">Student duoc phep join.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong co quyen join.</response>
        /// <response code="404">Khong tim thay de thi.</response>
        /// <response code="409">Da vuot so lan lam bai toi da.</response>
        [HttpPost("{examId:int}/check-access")]
        [ProducesResponseType(typeof(BaoAccessResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> CheckAccess(
            int examId,
            BaoAccessRequestDto request)
        {
            try
            {
                // Gọi Service kiểm tra các điều kiện: Đã publish, còn thời gian, đã enroll môn, đúng AccessCode, chưa quá MaxAttempts
                var result = await _baoAccessService.CheckAccessAsync(
                    examId,
                    request,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result); // Trả về kết quả cho phép truy cập (CanAccess = true)
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // POST /api/exams/{examId}/start - Bắt đầu làm bài thi (Tạo attempt mới hoặc Resume attempt cũ)
        [HttpPost("{examId:int}/start")]
        [ProducesResponseType(typeof(BaoStartResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> Start(
            int examId,
            [FromBody] BaoAccessRequestDto? request)
        {
            try
            {
                // Gọi Service bắt đầu thi: trộn câu hỏi nếu ShuffleQuestions = true, tính số lượt thi
                var result = await _baoAccessService.StartAsync(
                    examId,
                    request ?? new BaoAccessRequestDto(),
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result); // Trả về thông tin AttemptId và danh sách câu hỏi
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // GET /api/attempts/{attemptId} - Lấy chi tiết thông tin một lần làm bài (Attempt)
        [HttpGet("/api/attempts/{attemptId:int}")]
        [ProducesResponseType(typeof(BaoAttemptDetailResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetAttempt(int attemptId)
        {
            try
            {
                // Gọi Service lấy thông tin lượt thi (có giấu đáp án đúng nếu đang thi)
                var result = await _baoAccessService.GetAttemptAsync(
                    attemptId,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // POST /api/attempts/{attemptId}/answers - Tự động lưu đáp án câu hỏi khi Sinh viên đang làm bài
        [HttpPost("/api/attempts/{attemptId:int}/answers")]
        [ProducesResponseType(typeof(BaoSaveAnswerResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> SaveAnswer(
            int attemptId,
            BaoSaveAnswerRequestDto request)
        {
            try
            {
                // Gọi Service lưu đáp án Sinh viên vừa chọn
                var result = await _baoAccessService.SaveAnswerAsync(
                    attemptId,
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

        // POST /api/attempts/{attemptId}/submit - Sinh viên nộp bài thi & Hệ thống chấm điểm tự động
        [HttpPost("/api/attempts/{attemptId:int}/submit")]
        [ProducesResponseType(typeof(BaoSubmitResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> Submit(
            int attemptId,
            BaoSubmitRequestDto request)
        {
            try
            {
                // Gọi Service nộp bài và chạy thuật toán chấm điểm tự động (GradeAttempt)
                var result = await _baoAccessService.SubmitAsync(
                    attemptId,
                    request,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result); // Trả về tổng điểm, điểm đậu/rớt
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // GET /api/exams/{examId}/result - Sinh viên xem lại kết quả bài thi và kiểm tra đáp án
        [HttpGet("{examId:int}/result")]
        [ProducesResponseType(typeof(BaoResultResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetResult(int examId)
        {
            try
            {
                // Gọi Service lấy kết quả thi của sinh viên hiện tại
                var result = await _baoAccessService.GetResultAsync(
                    examId,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        // GET /api/exams/{examId}/ranking - Xem bảng xếp hạng (Leaderboard) của đề thi
        [HttpGet("{examId:int}/ranking")]
        [ProducesResponseType(typeof(BaoRankingResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetRanking(int examId, [FromQuery] int top = 5)
        {
            try
            {
                // Gọi Service lấy danh sách Top cao điểm nhất và hoàn thành sớm nhất
                var result = await _baoAccessService.GetRankingAsync(examId, top);

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
