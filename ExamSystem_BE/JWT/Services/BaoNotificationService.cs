using JWT.DTOs.BaoNotifications;
using JWT.Exceptions;
using JWT.Hubs;
using JWT.Models;
using JWT.Repositories.Contracts;
using JWT.Services.Contracts;
using Microsoft.AspNetCore.SignalR;

namespace JWT.Services
{
    public class BaoNotificationService : IBaoNotificationService
    {
        private readonly IBaoNotificationRepository _baoNotificationRepository;
        private readonly IHubContext<BaoNotificationHub> _hubContext;

        public BaoNotificationService(
            IBaoNotificationRepository baoNotificationRepository,
            IHubContext<BaoNotificationHub> hubContext)
        {
            _baoNotificationRepository = baoNotificationRepository;
            _hubContext = hubContext;
        }

        public async Task<BaoNotificationListResponseDto> GetNotificationsAsync(
            bool? isRead,
            string? currentUserId)
        {
            var userId = GetCurrentUserId(currentUserId);
            var notifications = await _baoNotificationRepository.GetUserNotificationsAsync(userId, isRead);
            var unreadCount = await _baoNotificationRepository.CountUnreadAsync(userId);

            return new BaoNotificationListResponseDto
            {
                TotalItems = notifications.Count,
                UnreadCount = unreadCount,
                Items = notifications.Select(MapToResponse).ToList()
            };
        }

        public async Task<BaoNotificationResponseDto> MarkAsReadAsync(
            int notificationId,
            string? currentUserId)
        {
            var userId = GetCurrentUserId(currentUserId);

            var notification = await _baoNotificationRepository.GetNotificationAsync(notificationId)
                ?? throw new NotFoundException("Không tìm thấy thông báo.");

            if (notification.UserId != userId)
            {
                throw new ForbiddenException("Notification không thuộc user hiện tại.");
            }

            if (!notification.IsRead)
            {
                notification.IsRead = true;
                notification = await _baoNotificationRepository.UpdateNotificationAsync(notification);
            }

            var response = MapToResponse(notification);
            var unreadCount = await _baoNotificationRepository.CountUnreadAsync(userId);
            var userKey = userId.ToString();

            await _hubContext.Clients.User(userKey)
                .SendAsync("NotificationRead", response);

            await _hubContext.Clients.User(userKey)
                .SendAsync("UnreadNotificationCountChanged", new { unreadCount });

            return response;
        }

        private static int GetCurrentUserId(string? currentUserId)
        {
            if (string.IsNullOrWhiteSpace(currentUserId) ||
                !int.TryParse(currentUserId, out var userId))
            {
                throw new UnauthorizedException("Không tìm thấy thông tin người dùng trong token.");
            }

            return userId;
        }

        private static BaoNotificationResponseDto MapToResponse(Notification notification)
        {
            return new BaoNotificationResponseDto
            {
                NotificationId = notification.NotificationId,
                UserId = notification.UserId,
                Title = notification.Title,
                Message = notification.Message,
                Type = notification.Type,
                IsRead = notification.IsRead,
                CreatedAt = notification.CreatedAt
            };
        }
    }
}
