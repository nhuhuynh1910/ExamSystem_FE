namespace JWT.DTOs.BaoAccess
{
    public class BaoRankingResponseDto
    {
        public int ExamId { get; set; }

        public string ExamName { get; set; } = string.Empty;

        public int Top { get; set; }

        public List<BaoRankingItemDto> Items { get; set; } = new();
    }
}
