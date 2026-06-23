using System.Security.Claims;
using JWT.DTOs.Questions.Requests;
using JWT.Services.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace JWT.Controllers
{
    [Route("api/questions")]
    [ApiController]
    public class QuestionController : ControllerBase
    {
        private readonly IQuestionService _questionService;

        public QuestionController(IQuestionService questionService)
        {
            _questionService = questionService;
        }

        [HttpGet]
        [Authorize]
        public async Task<IActionResult> GetQuestions([FromQuery] QuestionFilterRequest request)
        {
            var result = await _questionService.GetQuestionsAsync(
                request,
                GetCurrentUserId(),
                GetCurrentUserRole());

            return Ok(result);
        }

        [HttpGet("{id:int}")]
        [Authorize]
        public async Task<IActionResult> GetQuestionById(int id)
        {
            try
            {
                var result = await _questionService.GetQuestionByIdAsync(
                    id,
                    GetCurrentUserId(),
                    GetCurrentUserRole());

                if (result == null)
                {
                    return NotFound(new { message = "Question not found." });
                }

                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(403, new
                {
                    message = ex.Message
                });
            }
        }

        [HttpPost]
        [Authorize(Roles = "Teacher")]
        public async Task<IActionResult> CreateQuestion([FromBody] CreateQuestionRequest request)
        {
            try
            {
                var teacherId = GetCurrentUserId();
                var result = await _questionService.CreateQuestionAsync(request, teacherId);

                return CreatedAtAction(
                    nameof(GetQuestionById),
                    new { id = result.QuestionId },
                    result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(403, new
                {
                    message = ex.Message
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id:int}")]
        [Authorize(Roles = "Teacher")]
        public async Task<IActionResult> UpdateQuestion(
            int id,
            [FromBody] UpdateQuestionRequest request)
        {
            try
            {
                var teacherId = GetCurrentUserId();

                var result = await _questionService.UpdateQuestionAsync(
                    id,
                    request,
                    teacherId);

                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(403, new
                {
                    message = ex.Message
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("{id:int}")]
        [Authorize(Roles = "Teacher")]
        public async Task<IActionResult> DeleteQuestion(int id)
        {
            try
            {
                var teacherId = GetCurrentUserId();

                await _questionService.DeleteQuestionAsync(
                    id,
                    teacherId);

                return Ok(new
                {
                    message = "Question deleted successfully."
                });
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(403, new
                {
                    message = ex.Message
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPost("{questionId:int}/options")]
        [Authorize(Roles = "Teacher")]
        public async Task<IActionResult> AddOption(
            int questionId,
            [FromBody] CreateQuestionOptionRequest request)
        {
            try
            {
                var teacherId = GetCurrentUserId();

                var result = await _questionService.AddOptionAsync(
                    questionId,
                    request,
                    teacherId);

                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(403, new
                {
                    message = ex.Message
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("options/{optionId:int}")]
        [Authorize(Roles = "Teacher")]
        public async Task<IActionResult> UpdateOption(
            int optionId,
            [FromBody] UpdateQuestionOptionRequest request)
        {
            try
            {
                var teacherId = GetCurrentUserId();

                var result = await _questionService.UpdateOptionAsync(
                    optionId,
                    request,
                    teacherId);

                return Ok(result);
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(403, new
                {
                    message = ex.Message
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("options/{optionId:int}")]
        [Authorize(Roles = "Teacher")]
        public async Task<IActionResult> DeleteOption(int optionId)
        {
            try
            {
                var teacherId = GetCurrentUserId();

                await _questionService.DeleteOptionAsync(
                    optionId,
                    teacherId);

                return Ok(new
                {
                    message = "Option deleted successfully."
                });
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(403, new
                {
                    message = ex.Message
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id:int}/publish")]
        [Authorize(Roles = "Teacher")]
        public async Task<IActionResult> PublishQuestion(int id)
        {
            try
            {
                var teacherId = GetCurrentUserId();

                await _questionService.PublishQuestionAsync(
                    id,
                    teacherId);

                return Ok(new
                {
                    message = "Question published successfully."
                });
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(403, new
                {
                    message = ex.Message
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpPut("{id:int}/draft")]
        [Authorize(Roles = "Teacher")]
        public async Task<IActionResult> DraftQuestion(int id)
        {
            try
            {
                var teacherId = GetCurrentUserId();

                await _questionService.DraftQuestionAsync(
                    id,
                    teacherId);

                return Ok(new
                {
                    message = "Question moved to draft successfully."
                });
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(403, new
                {
                    message = ex.Message
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        private int GetCurrentUserId()
        {
            var userIdClaim =
                User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                ?? User.FindFirst("UserId")?.Value
                ?? User.FindFirst("userId")?.Value;

            if (string.IsNullOrWhiteSpace(userIdClaim))
            {
                throw new UnauthorizedAccessException(
                    "User id not found in token.");
            }

            if (!int.TryParse(userIdClaim, out var userId))
            {
                throw new UnauthorizedAccessException(
                    "Invalid user id.");
            }

            return userId;
        }

        private string GetCurrentUserRole()
        {
            return User.FindFirst(ClaimTypes.Role)?.Value ?? string.Empty;
        }
    }
}   