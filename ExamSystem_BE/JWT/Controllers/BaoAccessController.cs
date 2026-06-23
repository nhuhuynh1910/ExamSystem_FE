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
                var result = await _baoAccessService.CheckAccessAsync(
                    examId,
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

        /// <summary>
        /// Student bat dau lam bai, tao attempt va attempt questions.
        /// </summary>
        /// <remarks>
        /// Neu Student da co attempt InProgress thi resume attempt do, khong tao moi.
        /// Neu ShuffleQuestions = true thi thu tu AttemptQuestions duoc random.
        /// </remarks>
        /// <response code="200">Bat dau hoac resume bai lam thanh cong.</response>
        /// <response code="400">De thi chua co cau hoi published.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong du dieu kien bat dau lam bai.</response>
        /// <response code="404">Khong tim thay de thi.</response>
        /// <response code="409">Da vuot so lan lam bai toi da.</response>
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
                var result = await _baoAccessService.StartAsync(
                    examId,
                    request ?? new BaoAccessRequestDto(),
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
        /// Lay thong tin mot lan lam bai de resume hoac xem lai.
        /// </summary>
        /// <remarks>
        /// Student chi xem attempt cua minh.
        /// Teacher chi xem attempt thuoc de thi cua minh.
        /// Admin xem duoc tat ca.
        /// Attempt InProgress khong tra dap an dung.
        /// Attempt Submitted chi tra ket qua khi ShowAnswerAfterSubmit = true.
        /// </remarks>
        /// <response code="200">Tra ve thong tin attempt.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong co quyen xem attempt.</response>
        /// <response code="404">Khong tim thay attempt.</response>
        [HttpGet("/api/attempts/{attemptId:int}")]
        [ProducesResponseType(typeof(BaoAttemptDetailResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetAttempt(int attemptId)
        {
            try
            {
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

        /// <summary>
        /// Luu cau tra loi trong qua trinh Student lam bai.
        /// </summary>
        /// <remarks>
        /// Attempt phai ton tai, thuoc Student hien tai, dang InProgress,
        /// chua qua thoi gian lam bai, question phai thuoc AttemptQuestions,
        /// option chon phai thuoc question do. Neu tra loi lai thi update answer cu.
        /// </remarks>
        /// <response code="200">Luu cau tra loi thanh cong.</response>
        /// <response code="400">Du lieu cau tra loi khong hop le.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong co quyen hoac da qua thoi gian lam bai.</response>
        /// <response code="404">Khong tim thay attempt.</response>
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

        /// <summary>
        /// Student nop bai, cham diem tu dong va tinh passed/failed.
        /// </summary>
        /// <remarks>
        /// Attempt phai ton tai, thuoc Student hien tai va dang InProgress.
        /// Multiple choice phai match exact moi duoc diem.
        /// Neu qua thoi gian thi Status = Expired va IsAutoSubmitted = true.
        /// </remarks>
        /// <response code="200">Nop bai va cham diem thanh cong.</response>
        /// <response code="400">Attempt khong con InProgress hoac da submit.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong co quyen nop attempt nay.</response>
        /// <response code="404">Khong tim thay attempt.</response>
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
                var result = await _baoAccessService.SubmitAsync(
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

        /// <summary>
        /// Student xem ket qua bai thi cua minh.
        /// </summary>
        /// <remarks>
        /// Student chi xem ket qua cua chinh minh.
        /// Attempt phai Submitted hoac Expired.
        /// Neu ShowAnswerAfterSubmit = true thi tra dap an/giai thich.
        /// Neu false thi khong tra dap an dung.
        /// </remarks>
        /// <response code="200">Tra ve ket qua bai thi.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong co quyen xem ket qua.</response>
        /// <response code="404">Khong tim thay exam hoac attempt da nop.</response>
        [HttpGet("{examId:int}/result")]
        [ProducesResponseType(typeof(BaoResultResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetResult(int examId)
        {
            try
            {
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

        /// <summary>
        /// Xem bang xep hang cua exam.
        /// </summary>
        /// <remarks>
        /// Chi lay attempt Submitted.
        /// Moi Student lay attempt co score cao nhat.
        /// Sort Score DESC, neu bang diem thi SubmitDuration ASC.
        /// Mac dinh Top 5.
        /// </remarks>
        /// <response code="200">Tra ve bang xep hang.</response>
        /// <response code="404">Khong tim thay exam.</response>
        [HttpGet("{examId:int}/ranking")]
        [ProducesResponseType(typeof(BaoRankingResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetRanking(int examId, [FromQuery] int top = 5)
        {
            try
            {
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
