using System.ComponentModel.DataAnnotations;

namespace JWT.DTOs.Subjects
{
    public class SubjectUpdateDto
    {
        [Required]
        [MaxLength(150)]
        public string SubjectName { get; set; } = string.Empty;

        public string? Description { get; set; }

        public bool IsActive { get; set; } = true;
    }
}