using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JWT.Models
{
    public class TeacherSubject
    {
        [Key]
        public int TeacherSubjectId { get; set; }

        [Required]
        public int TeacherId { get; set; }

        [Required]
        public int SubjectId { get; set; }

        public DateTime AssignedAt { get; set; } = DateTime.Now;

        public bool IsActive { get; set; } = true;

        // Navigation property
        [ForeignKey(nameof(TeacherId))]
        public User Teacher { get; set; } = null!;

        [ForeignKey(nameof(SubjectId))]
        public Subject Subject { get; set; } = null!;
    }
}
