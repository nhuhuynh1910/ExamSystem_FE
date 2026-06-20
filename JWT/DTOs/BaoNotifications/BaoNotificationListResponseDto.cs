namespace JWT.DTOs.BaoNotifications
{
    public class BaoNotificationListResponseDto
    {
        public int TotalItems { get; set; }

        public int UnreadCount { get; set; }

        public List<BaoNotificationResponseDto> Items { get; set; } = new();
    }
}
