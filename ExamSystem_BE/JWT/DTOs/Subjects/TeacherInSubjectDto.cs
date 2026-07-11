namespace JWT.DTOs.Subjects
{
    /// <summary>
    /// DTO trả về thông tin Giáo viên đang được gán vào một Môn học.
    /// Dùng cho endpoint: GET /api/subjects/{subjectId}/teachers
    /// </summary>
    public class TeacherInSubjectDto
    {
        public int TeacherSubjectId { get; set; }
        public int TeacherId { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public DateTime AssignedAt { get; set; }
        public bool IsActive { get; set; }
    }
}
