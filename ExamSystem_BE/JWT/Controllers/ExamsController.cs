using JWT.DTOs.Exam;
using JWT.Exceptions;
using JWT.Services.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace JWT.Controllers
{
    /// <summary>
    /// Quan ly de thi, cau hoi trong de thi, publish/close exam va exam public/private.
    /// </summary>
    [Route("api/exams")]
    [ApiController]
    [Authorize]
    public class ExamsController : ControllerBase
    {
        private readonly IExamService _examService;

        public ExamsController(IExamService examService)
        {
            _examService = examService;
        }

        /// <summary>
        /// Lay danh sach de thi co phan trang va loc theo mon hoc.
        /// </summary>
        /// <remarks>
        /// Student chi thay exam co Status = Published va khong nhan AccessCode.
        /// Teacher thay exam do minh tao hoac exam thuoc subject minh duoc gan.
        /// Admin thay tat ca exam chua bi xoa mem.
        /// </remarks>
        /// <response code="200">Tra ve danh sach de thi.</response>
        /// <response code="400">PageNumber hoac PageSize khong hop le.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Role khong co quyen truy cap.</response>
        [HttpGet]
        [ProducesResponseType(typeof(PagedResultDto<ExamResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> GetExams([FromQuery] ExamFilterRequestDto filter)
        {
            try
            {
                var result = await _examService.GetExamsAsync(
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
        /// Teacher lay danh sach de thi do chinh minh tao.
        /// </summary>
        /// <remarks>
        /// Ho tro loc theo SubjectId va Status = Draft, Published hoac Closed.
        /// Khong tra ve de thi da bi xoa mem.
        /// </remarks>
        /// <response code="200">Tra ve danh sach de thi cua teacher hien tai.</response>
        /// <response code="400">PageNumber/PageSize hoac Status khong hop le.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong phai Teacher.</response>
        [HttpGet("/api/teacher/exams")]
        [ProducesResponseType(typeof(PagedResultDto<ExamResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        public async Task<IActionResult> GetTeacherExams([FromQuery] TeacherExamFilterRequestDto filter)
        {
            try
            {
                var result = await _examService.GetTeacherExamsAsync(
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
        /// Lay chi tiet mot de thi theo id.
        /// </summary>
        /// <remarks>
        /// Neu exam khong ton tai hoac da bi xoa mem thi tra ve 404.
        /// Student chi xem duoc exam Published va AccessCode se bi an.
        /// Teacher chi xem duoc exam do minh tao hoac thuoc subject minh duoc gan.
        /// Admin xem duoc day du thong tin.
        /// </remarks>
        /// <response code="200">Tra ve chi tiet de thi.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong co quyen xem de thi.</response>
        /// <response code="404">Khong tim thay de thi.</response>
        [HttpGet("{id:int}")]
        [ProducesResponseType(typeof(ExamResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetExamById(int id)
        {
            try
            {
                var result = await _examService.GetExamByIdAsync(
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
        /// Teacher tao de thi moi cho subject minh duoc phan cong; Admin co the tao de thi bat ky.
        /// </summary>
        /// <remarks>
        /// Role Teacher hoac Admin duoc goi API nay.
        /// Exam moi mac dinh Status = Draft.
        /// StartTime phai nho hon EndTime, DurationMinutes phai lon hon 0,
        /// PassingScore khong duoc lon hon TotalScore.
        /// Private exam bat buoc co AccessCode.
        /// Exam co anh bia qua file ExamImage trong multipart/form-data.
        /// Ten de thi khong duoc trung voi de thi dang hoat dong.
        /// </remarks>
        /// <response code="201">Tao de thi thanh cong.</response>
        /// <response code="400">Du lieu tao de thi khong hop le.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong phai Teacher/Admin hoac Teacher chua duoc gan subject.</response>
        /// <response code="409">Ten de thi da ton tai.</response>
        [HttpPost]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(typeof(ExamResponseDto), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> CreateExam([FromForm] ExamCreateDto request)
        {
            try
            {
                var result = await _examService.CreateExamAsync(
                    request,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return CreatedAtAction(nameof(GetExamById), new { id = result.ExamId }, result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        /// <summary>
        /// Teacher cap nhat de thi do chinh minh tao; Admin cap nhat de thi bat ky.
        /// </summary>
        /// <remarks>
        /// Ap dung validate nhu tao exam.
        /// Teacher khong duoc sua exam cua nguoi khac.
        /// Neu gui ExamImage moi thi he thong upload va cap nhat ExamImageUrl; neu khong gui thi giu anh hien tai.
        /// Ten de thi khong duoc trung voi de thi dang hoat dong khac.
        /// </remarks>
        /// <response code="200">Cap nhat de thi thanh cong.</response>
        /// <response code="400">Du lieu cap nhat khong hop le.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong co quyen cap nhat de thi.</response>
        /// <response code="404">Khong tim thay de thi.</response>
        /// <response code="409">Ten de thi da ton tai.</response>
        [HttpPut("{id:int}")]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(typeof(ExamResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> UpdateExam(int id, [FromForm] ExamUpdateDto request)
        {
            try
            {
                var result = await _examService.UpdateExamAsync(
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

        /// <summary>
        /// Xoa mem de thi.
        /// </summary>
        /// <remarks>
        /// Teacher tao de thi hoac Admin duoc xoa.
        /// He thong set IsDeleted = true va Status = Closed.
        /// </remarks>
        /// <response code="204">Xoa mem thanh cong.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong co quyen xoa de thi.</response>
        /// <response code="404">Khong tim thay de thi.</response>
        [HttpDelete("{id:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> DeleteExam(int id)
        {
            try
            {
                await _examService.DeleteExamAsync(
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

        /// <summary>
        /// Teacher tao de thi hoac Admin cap nhat Status cua de thi.
        /// </summary>
        /// <remarks>
        /// Chon Status mong muon trong body: Draft, Published hoac Closed.
        /// Neu de thi dang bi xoa mem, API se set IsDeleted = false va cap nhat Status theo gia tri duoc chon.
        /// Khi chon Published, de thi phai co it nhat mot cau hoi.
        /// </remarks>
        /// <response code="200">Cap nhat trang thai de thi thanh cong.</response>
        /// <response code="400">Status khong hop le hoac de thi khong du dieu kien de cap nhat Status.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong phai Teacher/Admin hoac Teacher khong so huu de thi.</response>
        /// <response code="404">Khong tim thay de thi.</response>
        [HttpPut("{id:int}/status")]
        [ProducesResponseType(typeof(ExamResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> UpdateExamStatus(int id, ExamStatusUpdateDto request)
        {
            try
            {
                var result = await _examService.UpdateExamStatusAsync(
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

        /// <summary>
        /// Them cau hoi tu ngan hang vao de thi.
        /// </summary>
        /// <remarks>
        /// Teacher tao de thi hoac Admin duoc them cau hoi.
        /// Exam phai dang Draft.
        /// Question phai co Status = Published va khong bi xoa.
        /// Khong cho add trung question vao cung mot exam.
        /// Request dung form-data; ExamQuestionId tu tang nen khong can nhap.
        /// </remarks>
        /// <response code="200">Them cau hoi thanh cong.</response>
        /// <response code="400">Exam khong Draft, question chua Published, hoac du lieu khong hop le.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong co quyen them cau hoi.</response>
        /// <response code="404">Khong tim thay exam hoac question.</response>
        /// <response code="409">Question da ton tai trong exam.</response>
        [HttpPost("{examId:int}/questions")]
        [Consumes("multipart/form-data")]
        [ProducesResponseType(typeof(ExamQuestionResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        [ProducesResponseType(StatusCodes.Status409Conflict)]
        public async Task<IActionResult> AddQuestionToExam(
            int examId,
            [FromForm] AddExamQuestionDto request)
        {
            try
            {
                var result = await _examService.AddQuestionToExamAsync(
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
        /// Xoa cau hoi khoi de thi.
        /// </summary>
        /// <remarks>
        /// Teacher tao de thi hoac Admin duoc xoa cau hoi.
        /// Exam phai dang Draft.
        /// Neu khong tim thay lien ket ExamQuestions thi tra ve 404.
        /// </remarks>
        /// <response code="204">Xoa cau hoi khoi de thi thanh cong.</response>
        /// <response code="400">Exam khong o trang thai Draft.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong co quyen xoa cau hoi.</response>
        /// <response code="404">Khong tim thay exam hoac lien ket question trong exam.</response>
        [HttpDelete("{examId:int}/questions/{questionId:int}")]
        [ProducesResponseType(StatusCodes.Status204NoContent)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> RemoveQuestionFromExam(int examId, int questionId)
        {
            try
            {
                await _examService.RemoveQuestionFromExamAsync(
                    examId,
                    questionId,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                return NoContent();
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        /// <summary>
        /// Publish de thi de Student co the nhin thay va lam bai.
        /// </summary>
        /// <remarks>
        /// Chuyen Status tu Draft sang Published.
        /// Teacher chi publish exam cua minh; Admin co the publish exam bat ky.
        /// </remarks>
        /// <response code="200">Publish thanh cong.</response>
        /// <response code="400">Exam khong o trang thai Draft.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong co quyen publish de thi.</response>
        /// <response code="404">Khong tim thay de thi.</response>
        [HttpPut("{id:int}/publish")]
        [ProducesResponseType(typeof(ExamResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> PublishExam(int id)
        {
            try
            {
                var result = await _examService.PublishExamAsync(
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
        /// Dong de thi, khong cho Student tiep tuc join.
        /// </summary>
        /// <remarks>
        /// Chuyen Status cua exam sang Closed.
        /// Teacher chi close exam cua minh; Admin co the close exam bat ky.
        /// </remarks>
        /// <response code="200">Close thanh cong.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong co quyen close de thi.</response>
        /// <response code="404">Khong tim thay de thi.</response>
        [HttpPut("{id:int}/close")]
        [ProducesResponseType(typeof(ExamResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> CloseExam(int id)
        {
            try
            {
                var result = await _examService.CloseExamAsync(
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
        /// Lay danh sach cau hoi trong de thi.
        /// </summary>
        /// <remarks>
        /// Student chi duoc xem cau hoi cua exam Published trong thoi gian lam bai.
        /// Khi role la Student, he thong an hoan toan IsCorrect va Explanation de chong gian lan F12.
        /// Teacher xem duoc exam do minh tao hoac exam thuoc subject minh duoc gan.
        /// Admin xem duoc day du.
        /// </remarks>
        /// <response code="200">Tra ve danh sach cau hoi trong de thi.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Khong co quyen xem cau hoi trong de thi.</response>
        /// <response code="404">Khong tim thay de thi.</response>
        [HttpGet("{examId:int}/questions")]
        [ProducesResponseType(typeof(List<ExamQuestionResponseDto>), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> GetExamQuestions(int examId)
        {
            try
            {
                var result = await _examService.GetExamQuestionsAsync(
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
