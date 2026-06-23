namespace JWT.DTOs.BaoAccess
{
    public class BaoAttemptOptionDto
    {
        public int OptionId { get; set; }

        public string OptionText { get; set; } = string.Empty;

        public int OptionOrder { get; set; }

        public bool? IsCorrect { get; set; }

        public bool IsSelected { get; set; }
    }
}
