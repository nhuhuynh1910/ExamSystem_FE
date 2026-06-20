using System.Text.Json.Serialization;

namespace JWT.DTOs.Questions.Responses
{
    public class QuestionOptionResponse
    {
        public int OptionId { get; set; }

        public int QuestionId { get; set; }

        public string OptionText { get; set; } = string.Empty;

        [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
        public bool? IsCorrect { get; set; }

        public int OptionOrder { get; set; }

        public byte[]? RowVersion { get; set; }
    }
}
