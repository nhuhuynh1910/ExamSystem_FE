namespace JWT.DTOs.BaoAccess
{
    public class BaoRankingItemDto
    {
        public int Rank { get; set; }

        public int StudentId { get; set; }

        public string StudentName { get; set; } = string.Empty;

        public string Username { get; set; } = string.Empty;

        public int AttemptId { get; set; }

        public int AttemptNumber { get; set; }

        public decimal Score { get; set; }

        public bool IsPassed { get; set; }

        public DateTime StartTime { get; set; }

        public DateTime SubmitTime { get; set; }

        public double SubmitDurationSeconds { get; set; }
    }
}
