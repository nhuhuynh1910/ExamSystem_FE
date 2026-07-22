namespace JWT.DTOs.BaoNotifications
{
    public class BaoNotificationResponseDto
    {
        public int NotificationId { get; set; }

        public int UserId { get; set; }

        public string Title { get; set; } = string.Empty;

        public string? Message { get; set; }

        public string? Type { get; set; }

        public bool IsRead { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
