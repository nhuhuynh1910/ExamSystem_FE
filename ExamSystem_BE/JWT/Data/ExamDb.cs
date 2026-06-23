using JWT.Models;
using Microsoft.EntityFrameworkCore;

namespace JWT.Data
{
    public class ExamDb : DbContext
    {
        public ExamDb(DbContextOptions<ExamDb> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<Role> Roles { get; set; }

        public DbSet<Subject> Subjects { get; set; }
        public DbSet<Enrollment> Enrollments { get; set; }

        public DbSet<TeacherRequest> TeacherRequests { get; set; }
        public DbSet<TeacherSubject> TeacherSubjects { get; set; }

        public DbSet<Exam> Exams { get; set; }
        public DbSet<ExamQuestion> ExamQuestions { get; set; }

        public DbSet<Question> Questions { get; set; }
        public DbSet<QuestionOption> QuestionOptions { get; set; }

        public DbSet<ExamAttempt> ExamAttempts { get; set; }
        public DbSet<AttemptQuestion> AttemptQuestions { get; set; }

        public DbSet<StudentAnswer> StudentAnswers { get; set; }
        public DbSet<StudentAnswerOption> StudentAnswerOptions { get; set; }

        public DbSet<Notification> Notifications { get; set; }
        public DbSet<RefreshToken> RefreshTokens { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // =========================
            // UNIQUE CONFIG
            // =========================

            modelBuilder.Entity<Role>()
                .HasIndex(r => r.RoleName)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            modelBuilder.Entity<User>()
                .HasIndex(u => u.Username)
                .IsUnique();

            modelBuilder.Entity<Enrollment>()
                .HasIndex(e => new { e.StudentId, e.SubjectId })
                .IsUnique();

            modelBuilder.Entity<TeacherSubject>()
                .HasIndex(ts => new { ts.TeacherId, ts.SubjectId })
                .IsUnique();

            modelBuilder.Entity<ExamQuestion>()
                .HasIndex(eq => new { eq.ExamId, eq.QuestionId })
                .IsUnique();

            modelBuilder.Entity<StudentAnswer>()
                .HasIndex(sa => new { sa.AttemptId, sa.QuestionId })
                .IsUnique();

            // =========================
            // USER - ROLE
            // =========================

            modelBuilder.Entity<User>()
                .HasOne(u => u.Role)
                .WithMany(r => r.Users)
                .HasForeignKey(u => u.RoleId)
                .OnDelete(DeleteBehavior.NoAction);

            // =========================
            // TEACHER REQUEST
            // Student gửi request xin làm teacher / xin dạy thêm môn
            // ReviewedBy là admin duyệt
            // SubjectId là môn user xin dạy
            // =========================

            modelBuilder.Entity<TeacherRequest>()
                .HasOne(tr => tr.Student)
                .WithMany(u => u.SentTeacherRequests)
                .HasForeignKey(tr => tr.StudentId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<TeacherRequest>()
                .HasOne(tr => tr.Reviewer)
                .WithMany(u => u.ReviewedTeacherRequests)
                .HasForeignKey(tr => tr.ReviewedBy)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<TeacherRequest>()
                .HasOne(tr => tr.Subject)
                .WithMany()
                .HasForeignKey(tr => tr.SubjectId)
                .OnDelete(DeleteBehavior.NoAction);

            // =========================
            // TEACHER SUBJECT
            // Lưu teacher được admin cho dạy subject nào
            // =========================
            modelBuilder.Entity<TeacherSubject>()
                .HasOne(ts => ts.Teacher)
                .WithMany(u => u.TeacherSubjects)
                .HasForeignKey(ts => ts.TeacherId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<TeacherSubject>()

                .HasOne(ts => ts.Subject)
                .WithMany(s => s.TeacherSubjects)
                .HasForeignKey(ts => ts.SubjectId)
                .OnDelete(DeleteBehavior.NoAction);

            // =========================
            // ENROLLMENT
            // Student tham gia subject
            // =========================

            modelBuilder.Entity<Enrollment>()
                .HasOne(e => e.Student)
                .WithMany(u => u.Enrollments)
                .HasForeignKey(e => e.StudentId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Enrollment>()
                .HasOne(e => e.Subject)
                .WithMany(s => s.Enrollments)
                .HasForeignKey(e => e.SubjectId)
                .OnDelete(DeleteBehavior.NoAction);

            // =========================
            // EXAM
            // =========================

            modelBuilder.Entity<Exam>()
                .HasOne(e => e.Teacher)
                .WithMany(u => u.Exams)
                .HasForeignKey(e => e.TeacherId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Exam>()
                .HasOne(e => e.Subject)
                .WithMany(s => s.Exams)
                .HasForeignKey(e => e.SubjectId)
                .OnDelete(DeleteBehavior.NoAction);

            // =========================
            // QUESTION
            // =========================

            modelBuilder.Entity<Question>()
                .HasOne(q => q.Teacher)
                .WithMany(u => u.Questions)
                .HasForeignKey(q => q.TeacherId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<Question>()
                .HasOne(q => q.Subject)
                .WithMany(s => s.Questions)
                .HasForeignKey(q => q.SubjectId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<QuestionOption>()
                .HasOne(qo => qo.Question)
                .WithMany(q => q.QuestionOptions)
                .HasForeignKey(qo => qo.QuestionId)
                .OnDelete(DeleteBehavior.NoAction);

            // =========================
            // EXAM QUESTION
            // =========================

            modelBuilder.Entity<ExamQuestion>()
                .HasOne(eq => eq.Exam)
                .WithMany(e => e.ExamQuestions)
                .HasForeignKey(eq => eq.ExamId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<ExamQuestion>()
                .HasOne(eq => eq.Question)
                .WithMany(q => q.ExamQuestions)
                .HasForeignKey(eq => eq.QuestionId)
                .OnDelete(DeleteBehavior.NoAction);

            // =========================
            // EXAM ATTEMPT
            // =========================

            modelBuilder.Entity<ExamAttempt>()
                .HasOne(ea => ea.Student)
                .WithMany(u => u.ExamAttempts)
                .HasForeignKey(ea => ea.StudentId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<ExamAttempt>()
                .HasOne(ea => ea.Exam)
                .WithMany(e => e.ExamAttempts)
                .HasForeignKey(ea => ea.ExamId)
                .OnDelete(DeleteBehavior.NoAction);

            // =========================
            // ATTEMPT QUESTION
            // =========================

            modelBuilder.Entity<AttemptQuestion>()
                .HasOne(aq => aq.ExamAttempt)
                .WithMany(ea => ea.AttemptQuestions)
                .HasForeignKey(aq => aq.AttemptId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<AttemptQuestion>()
                .HasOne(aq => aq.Question)
                .WithMany(q => q.AttemptQuestions)
                .HasForeignKey(aq => aq.QuestionId)
                .OnDelete(DeleteBehavior.NoAction);

            // =========================
            // STUDENT ANSWER
            // =========================

            modelBuilder.Entity<StudentAnswer>()
                .HasOne(sa => sa.ExamAttempt)
                .WithMany(ea => ea.StudentAnswers)
                .HasForeignKey(sa => sa.AttemptId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<StudentAnswer>()
                .HasOne(sa => sa.Question)
                .WithMany(q => q.StudentAnswers)
                .HasForeignKey(sa => sa.QuestionId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<StudentAnswerOption>()
                .HasOne(sao => sao.StudentAnswer)
                .WithMany(sa => sa.StudentAnswerOptions)
                .HasForeignKey(sao => sao.StudentAnswerId)
                .OnDelete(DeleteBehavior.NoAction);

            modelBuilder.Entity<StudentAnswerOption>()
                .HasOne(sao => sao.QuestionOption)
                .WithMany(qo => qo.StudentAnswerOptions)
                .HasForeignKey(sao => sao.OptionId)
                .OnDelete(DeleteBehavior.NoAction);

            // =========================
            // NOTIFICATION
            // =========================

            modelBuilder.Entity<Notification>()
                .HasOne(n => n.User)
                .WithMany(u => u.Notifications)
                .HasForeignKey(n => n.UserId)
                .OnDelete(DeleteBehavior.NoAction);

            // =========================
            // REFRESH TOKEN
            // =========================

            modelBuilder.Entity<RefreshToken>()
                .HasOne(rt => rt.User)
                .WithMany(u => u.RefreshTokens)
                .HasForeignKey(rt => rt.UserId)
                .OnDelete(DeleteBehavior.NoAction);

            // =========================
            // DECIMAL PRECISION
            // =========================

            modelBuilder.Entity<Question>()
                .Property(q => q.Score)
                .HasPrecision(5, 2);

            modelBuilder.Entity<Exam>()
                .Property(e => e.TotalScore)
                .HasPrecision(6, 2);

            modelBuilder.Entity<Exam>()
                .Property(e => e.PassingScore)
                .HasPrecision(6, 2);

            modelBuilder.Entity<ExamQuestion>()
                .Property(eq => eq.Score)
                .HasPrecision(5, 2);

            modelBuilder.Entity<ExamAttempt>()
                .Property(ea => ea.Score)
                .HasPrecision(6, 2);

            modelBuilder.Entity<AttemptQuestion>()
                .Property(aq => aq.Score)
                .HasPrecision(5, 2);

            modelBuilder.Entity<StudentAnswer>()
                .Property(sa => sa.ScoreAwarded)
                .HasPrecision(5, 2);

            // =========================
            // ROW VERSION
            // =========================

            modelBuilder.Entity<User>()
                .Property(u => u.RowVersion)
                .IsRowVersion();

            modelBuilder.Entity<Subject>()
                .Property(s => s.RowVersion)
                .IsRowVersion();

            modelBuilder.Entity<TeacherRequest>()
                .Property(t => t.RowVersion)
                .IsRowVersion();

            modelBuilder.Entity<Question>()
                .Property(q => q.RowVersion)
                .IsRowVersion();

            modelBuilder.Entity<QuestionOption>()
                .Property(qo => qo.RowVersion)
                .IsRowVersion();

            modelBuilder.Entity<Exam>()
                .Property(e => e.RowVersion)
                .IsRowVersion();

            modelBuilder.Entity<ExamAttempt>()
                .Property(ea => ea.RowVersion)
                .IsRowVersion();

            // =========================
            // SEED DATA
            // =========================

            modelBuilder.Entity<Role>().HasData(
                new Role { RoleId = 1, RoleName = "Admin" },
                new Role { RoleId = 2, RoleName = "Teacher" },
                new Role { RoleId = 3, RoleName = "Student" }
            );
        }
    }
}