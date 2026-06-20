using JWT.Data;
using JWT.Models;
using JWT.Repositories.Contracts;
using Microsoft.EntityFrameworkCore;

namespace JWT.Repositories
{
    public class BaoNotificationRepository : IBaoNotificationRepository
    {
        private readonly ExamDb _context;

        public BaoNotificationRepository(ExamDb context)
        {
            _context = context;
        }

        public async Task<List<Notification>> GetUserNotificationsAsync(int userId, bool? isRead)
        {
            var query = _context.Notifications
                .AsNoTracking()
                .Where(notification => notification.UserId == userId);

            if (isRead.HasValue)
            {
                query = query.Where(notification => notification.IsRead == isRead.Value);
            }

            return await query
                .OrderByDescending(notification => notification.CreatedAt)
                .ToListAsync();
        }

        public async Task<int> CountUnreadAsync(int userId)
        {
            return await _context.Notifications
                .AsNoTracking()
                .CountAsync(notification =>
                    notification.UserId == userId &&
                    !notification.IsRead);
        }

        public async Task<Notification?> GetNotificationAsync(int notificationId)
        {
            return await _context.Notifications
                .FirstOrDefaultAsync(notification => notification.NotificationId == notificationId);
        }

        public async Task<Notification> UpdateNotificationAsync(Notification notification)
        {
            await _context.SaveChangesAsync();
            return notification;
        }
    }
}
