using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace JWT.Models
{
    public class Enrollment
    {
        [Key]
        public int EnrollmentId { get; set; }

        public int StudentId { get; set; }

        public int SubjectId { get; set; }

        public DateTime EnrolledAt { get; set; } = DateTime.Now;

        public bool IsDeleted { get; set; } = false;

        // Navigation
        [ForeignKey(nameof(StudentId))]
        public User? Student { get; set; }

        [ForeignKey(nameof(SubjectId))]
        public Subject? Subject { get; set; }
    }
}
