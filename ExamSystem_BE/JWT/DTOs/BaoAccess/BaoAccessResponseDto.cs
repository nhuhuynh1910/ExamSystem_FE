namespace JWT.DTOs.BaoAccess
{
    public class BaoAccessResponseDto
    {
        public bool CanAccess { get; set; }

        public int AttemptsUsed { get; set; }

        public int MaxAttempts { get; set; }

        public int RemainingAttempts { get; set; }

        public DateTime CheckedAt { get; set; }
    }
}
