using JWT.Models;

namespace JWT.Repositories.Contracts
{
    public interface IBaoNotificationRepository
    {
        Task<List<Notification>> GetUserNotificationsAsync(int userId, bool? isRead);

        Task<int> CountUnreadAsync(int userId);

        Task<Notification?> GetNotificationAsync(int notificationId);

        Task<Notification> UpdateNotificationAsync(Notification notification);
    }
}
