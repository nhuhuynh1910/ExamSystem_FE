using JWT.DTOs.BaoNotifications;

namespace JWT.Services.Contracts
{
    public interface IBaoNotificationService
    {
        Task<BaoNotificationListResponseDto> GetNotificationsAsync(
            bool? isRead,
            string? currentUserId);

        Task<BaoNotificationResponseDto> MarkAsReadAsync(
            int notificationId,
            string? currentUserId);
    }
}
