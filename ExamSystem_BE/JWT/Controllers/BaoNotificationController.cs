using JWT.DTOs.BaoNotifications;
using JWT.Exceptions;
using JWT.Services.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace JWT.Controllers
{
    /// <summary>
    /// Bao - quan ly notification cua user hien tai.
    /// </summary>
    [Route("api/notifications")]
    [ApiController]
    [Authorize]
    public class BaoNotificationController : ControllerBase
    {
        private readonly IBaoNotificationService _baoNotificationService;

        public BaoNotificationController(IBaoNotificationService baoNotificationService)
        {
            _baoNotificationService = baoNotificationService;
        }

        /// <summary>
        /// User xem danh sach thong bao cua minh.
        /// </summary>
        /// <remarks>
        /// User chi xem notification cua chinh minh.
        /// Sort CreatedAt DESC. Co the filter IsRead.
        /// </remarks>
        /// <response code="200">Tra ve danh sach thong bao.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        [HttpGet]
        [ProducesResponseType(typeof(BaoNotificationListResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        public async Task<IActionResult> GetNotifications([FromQuery] bool? isRead)
        {
            try
            {
                var result = await _baoNotificationService.GetNotificationsAsync(
                    isRead,
                    GetCurrentUserId());

                return Ok(result);
            }
            catch (Exception ex)
            {
                return HandleException(ex);
            }
        }

        /// <summary>
        /// Danh dau thong bao da doc.
        /// </summary>
        /// <remarks>
        /// Notification phai ton tai va thuoc user hien tai.
        /// Sau khi read se push SignalR event NotificationRead va UnreadNotificationCountChanged.
        /// </remarks>
        /// <response code="200">Danh dau da doc thanh cong.</response>
        /// <response code="401">Token khong hop le hoac thieu thong tin user.</response>
        /// <response code="403">Notification khong thuoc user hien tai.</response>
        /// <response code="404">Khong tim thay notification.</response>
        [HttpPut("{id:int}/read")]
        [ProducesResponseType(typeof(BaoNotificationResponseDto), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status401Unauthorized)]
        [ProducesResponseType(StatusCodes.Status403Forbidden)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<IActionResult> MarkAsRead(int id)
        {
            try
            {
                var result = await _baoNotificationService.MarkAsReadAsync(
                    id,
                    GetCurrentUserId());

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

        private IActionResult HandleException(Exception ex)
        {
            return ex switch
            {
                UnauthorizedException => Unauthorized(new { message = ex.Message }),
                ForbiddenException => StatusCode(StatusCodes.Status403Forbidden, new { message = ex.Message }),
                NotFoundException => NotFound(new { message = ex.Message }),
                _ => StatusCode(StatusCodes.Status500InternalServerError, new { message = ex.Message })
            };
        }
    }
}
