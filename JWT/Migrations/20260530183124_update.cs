using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace JWT.Migrations
{
    /// <inheritdoc />
    public partial class update : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Enrollment_Subject_SubjectId",
                table: "Enrollment");

            migrationBuilder.DropForeignKey(
                name: "FK_Enrollment_Users_StudentId",
                table: "Enrollment");

            migrationBuilder.DropForeignKey(
                name: "FK_ExamQuestion_Exams_ExamId",
                table: "ExamQuestion");

            migrationBuilder.DropForeignKey(
                name: "FK_ExamQuestion_Questions_QuestionId",
                table: "ExamQuestion");

            migrationBuilder.DropForeignKey(
                name: "FK_Exams_Subject_SubjectId",
                table: "Exams");

            migrationBuilder.DropForeignKey(
                name: "FK_Questions_Subject_SubjectId",
                table: "Questions");

            migrationBuilder.DropForeignKey(
                name: "FK_RefreshToken_Users_UserId",
                table: "RefreshToken");

            migrationBuilder.DropForeignKey(
                name: "FK_Subject_Users_CreatedBy",
                table: "Subject");

            migrationBuilder.DropForeignKey(
                name: "FK_Subject_Users_UpdatedBy",
                table: "Subject");

            migrationBuilder.DropForeignKey(
                name: "FK_TeacherRequest_Users_ReviewedBy",
                table: "TeacherRequest");

            migrationBuilder.DropForeignKey(
                name: "FK_TeacherRequest_Users_StudentId",
                table: "TeacherRequest");

            migrationBuilder.DropForeignKey(
                name: "FK_TeacherSubjects_Subject_SubjectId",
                table: "TeacherSubjects");

            migrationBuilder.DropForeignKey(
                name: "FK_TeacherSubjects_Users_TeacherId",
                table: "TeacherSubjects");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_Role_RoleId",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_TeacherSubjects_TeacherId",
                table: "TeacherSubjects");

            migrationBuilder.DropPrimaryKey(
                name: "PK_TeacherRequest",
                table: "TeacherRequest");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Subject",
                table: "Subject");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Role",
                table: "Role");

            migrationBuilder.DropPrimaryKey(
                name: "PK_RefreshToken",
                table: "RefreshToken");

            migrationBuilder.DropPrimaryKey(
                name: "PK_ExamQuestion",
                table: "ExamQuestion");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Enrollment",
                table: "Enrollment");

            migrationBuilder.RenameTable(
                name: "TeacherRequest",
                newName: "TeacherRequests");

            migrationBuilder.RenameTable(
                name: "Subject",
                newName: "Subjects");

            migrationBuilder.RenameTable(
                name: "Role",
                newName: "Roles");

            migrationBuilder.RenameTable(
                name: "RefreshToken",
                newName: "RefreshTokens");

            migrationBuilder.RenameTable(
                name: "ExamQuestion",
                newName: "ExamQuestions");

            migrationBuilder.RenameTable(
                name: "Enrollment",
                newName: "Enrollments");

            migrationBuilder.RenameIndex(
                name: "IX_TeacherRequest_StudentId",
                table: "TeacherRequests",
                newName: "IX_TeacherRequests_StudentId");

            migrationBuilder.RenameIndex(
                name: "IX_TeacherRequest_ReviewedBy",
                table: "TeacherRequests",
                newName: "IX_TeacherRequests_ReviewedBy");

            migrationBuilder.RenameIndex(
                name: "IX_Subject_UpdatedBy",
                table: "Subjects",
                newName: "IX_Subjects_UpdatedBy");

            migrationBuilder.RenameIndex(
                name: "IX_Subject_CreatedBy",
                table: "Subjects",
                newName: "IX_Subjects_CreatedBy");

            migrationBuilder.RenameIndex(
                name: "IX_Role_RoleName",
                table: "Roles",
                newName: "IX_Roles_RoleName");

            migrationBuilder.RenameIndex(
                name: "IX_RefreshToken_UserId",
                table: "RefreshTokens",
                newName: "IX_RefreshTokens_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_ExamQuestion_QuestionId",
                table: "ExamQuestions",
                newName: "IX_ExamQuestions_QuestionId");

            migrationBuilder.RenameIndex(
                name: "IX_ExamQuestion_ExamId_QuestionId",
                table: "ExamQuestions",
                newName: "IX_ExamQuestions_ExamId_QuestionId");

            migrationBuilder.RenameIndex(
                name: "IX_Enrollment_SubjectId",
                table: "Enrollments",
                newName: "IX_Enrollments_SubjectId");

            migrationBuilder.RenameIndex(
                name: "IX_Enrollment_StudentId_SubjectId",
                table: "Enrollments",
                newName: "IX_Enrollments_StudentId_SubjectId");

            migrationBuilder.AddColumn<int>(
                name: "SubjectId1",
                table: "TeacherSubjects",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "UserId",
                table: "TeacherSubjects",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "SubjectId",
                table: "TeacherRequests",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddPrimaryKey(
                name: "PK_TeacherRequests",
                table: "TeacherRequests",
                column: "TeacherRequestId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Subjects",
                table: "Subjects",
                column: "SubjectId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Roles",
                table: "Roles",
                column: "RoleId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_RefreshTokens",
                table: "RefreshTokens",
                column: "RefreshTokenId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_ExamQuestions",
                table: "ExamQuestions",
                column: "ExamQuestionId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Enrollments",
                table: "Enrollments",
                column: "EnrollmentId");

            migrationBuilder.CreateIndex(
                name: "IX_TeacherSubjects_SubjectId1",
                table: "TeacherSubjects",
                column: "SubjectId1");

            migrationBuilder.CreateIndex(
                name: "IX_TeacherSubjects_TeacherId_SubjectId",
                table: "TeacherSubjects",
                columns: new[] { "TeacherId", "SubjectId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_TeacherSubjects_UserId",
                table: "TeacherSubjects",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_TeacherRequests_SubjectId",
                table: "TeacherRequests",
                column: "SubjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_Enrollments_Subjects_SubjectId",
                table: "Enrollments",
                column: "SubjectId",
                principalTable: "Subjects",
                principalColumn: "SubjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_Enrollments_Users_StudentId",
                table: "Enrollments",
                column: "StudentId",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_ExamQuestions_Exams_ExamId",
                table: "ExamQuestions",
                column: "ExamId",
                principalTable: "Exams",
                principalColumn: "ExamId");

            migrationBuilder.AddForeignKey(
                name: "FK_ExamQuestions_Questions_QuestionId",
                table: "ExamQuestions",
                column: "QuestionId",
                principalTable: "Questions",
                principalColumn: "QuestionId");

            migrationBuilder.AddForeignKey(
                name: "FK_Exams_Subjects_SubjectId",
                table: "Exams",
                column: "SubjectId",
                principalTable: "Subjects",
                principalColumn: "SubjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_Questions_Subjects_SubjectId",
                table: "Questions",
                column: "SubjectId",
                principalTable: "Subjects",
                principalColumn: "SubjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_RefreshTokens_Users_UserId",
                table: "RefreshTokens",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_Subjects_Users_CreatedBy",
                table: "Subjects",
                column: "CreatedBy",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_Subjects_Users_UpdatedBy",
                table: "Subjects",
                column: "UpdatedBy",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_TeacherRequests_Subjects_SubjectId",
                table: "TeacherRequests",
                column: "SubjectId",
                principalTable: "Subjects",
                principalColumn: "SubjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_TeacherRequests_Users_ReviewedBy",
                table: "TeacherRequests",
                column: "ReviewedBy",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_TeacherRequests_Users_StudentId",
                table: "TeacherRequests",
                column: "StudentId",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_TeacherSubjects_Subjects_SubjectId",
                table: "TeacherSubjects",
                column: "SubjectId",
                principalTable: "Subjects",
                principalColumn: "SubjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_TeacherSubjects_Subjects_SubjectId1",
                table: "TeacherSubjects",
                column: "SubjectId1",
                principalTable: "Subjects",
                principalColumn: "SubjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_TeacherSubjects_Users_TeacherId",
                table: "TeacherSubjects",
                column: "TeacherId",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_TeacherSubjects_Users_UserId",
                table: "TeacherSubjects",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Roles_RoleId",
                table: "Users",
                column: "RoleId",
                principalTable: "Roles",
                principalColumn: "RoleId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Enrollments_Subjects_SubjectId",
                table: "Enrollments");

            migrationBuilder.DropForeignKey(
                name: "FK_Enrollments_Users_StudentId",
                table: "Enrollments");

            migrationBuilder.DropForeignKey(
                name: "FK_ExamQuestions_Exams_ExamId",
                table: "ExamQuestions");

            migrationBuilder.DropForeignKey(
                name: "FK_ExamQuestions_Questions_QuestionId",
                table: "ExamQuestions");

            migrationBuilder.DropForeignKey(
                name: "FK_Exams_Subjects_SubjectId",
                table: "Exams");

            migrationBuilder.DropForeignKey(
                name: "FK_Questions_Subjects_SubjectId",
                table: "Questions");

            migrationBuilder.DropForeignKey(
                name: "FK_RefreshTokens_Users_UserId",
                table: "RefreshTokens");

            migrationBuilder.DropForeignKey(
                name: "FK_Subjects_Users_CreatedBy",
                table: "Subjects");

            migrationBuilder.DropForeignKey(
                name: "FK_Subjects_Users_UpdatedBy",
                table: "Subjects");

            migrationBuilder.DropForeignKey(
                name: "FK_TeacherRequests_Subjects_SubjectId",
                table: "TeacherRequests");

            migrationBuilder.DropForeignKey(
                name: "FK_TeacherRequests_Users_ReviewedBy",
                table: "TeacherRequests");

            migrationBuilder.DropForeignKey(
                name: "FK_TeacherRequests_Users_StudentId",
                table: "TeacherRequests");

            migrationBuilder.DropForeignKey(
                name: "FK_TeacherSubjects_Subjects_SubjectId",
                table: "TeacherSubjects");

            migrationBuilder.DropForeignKey(
                name: "FK_TeacherSubjects_Subjects_SubjectId1",
                table: "TeacherSubjects");

            migrationBuilder.DropForeignKey(
                name: "FK_TeacherSubjects_Users_TeacherId",
                table: "TeacherSubjects");

            migrationBuilder.DropForeignKey(
                name: "FK_TeacherSubjects_Users_UserId",
                table: "TeacherSubjects");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_Roles_RoleId",
                table: "Users");

            migrationBuilder.DropIndex(
                name: "IX_TeacherSubjects_SubjectId1",
                table: "TeacherSubjects");

            migrationBuilder.DropIndex(
                name: "IX_TeacherSubjects_TeacherId_SubjectId",
                table: "TeacherSubjects");

            migrationBuilder.DropIndex(
                name: "IX_TeacherSubjects_UserId",
                table: "TeacherSubjects");

            migrationBuilder.DropPrimaryKey(
                name: "PK_TeacherRequests",
                table: "TeacherRequests");

            migrationBuilder.DropIndex(
                name: "IX_TeacherRequests_SubjectId",
                table: "TeacherRequests");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Subjects",
                table: "Subjects");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Roles",
                table: "Roles");

            migrationBuilder.DropPrimaryKey(
                name: "PK_RefreshTokens",
                table: "RefreshTokens");

            migrationBuilder.DropPrimaryKey(
                name: "PK_ExamQuestions",
                table: "ExamQuestions");

            migrationBuilder.DropPrimaryKey(
                name: "PK_Enrollments",
                table: "Enrollments");

            migrationBuilder.DropColumn(
                name: "SubjectId1",
                table: "TeacherSubjects");

            migrationBuilder.DropColumn(
                name: "UserId",
                table: "TeacherSubjects");

            migrationBuilder.DropColumn(
                name: "SubjectId",
                table: "TeacherRequests");

            migrationBuilder.RenameTable(
                name: "TeacherRequests",
                newName: "TeacherRequest");

            migrationBuilder.RenameTable(
                name: "Subjects",
                newName: "Subject");

            migrationBuilder.RenameTable(
                name: "Roles",
                newName: "Role");

            migrationBuilder.RenameTable(
                name: "RefreshTokens",
                newName: "RefreshToken");

            migrationBuilder.RenameTable(
                name: "ExamQuestions",
                newName: "ExamQuestion");

            migrationBuilder.RenameTable(
                name: "Enrollments",
                newName: "Enrollment");

            migrationBuilder.RenameIndex(
                name: "IX_TeacherRequests_StudentId",
                table: "TeacherRequest",
                newName: "IX_TeacherRequest_StudentId");

            migrationBuilder.RenameIndex(
                name: "IX_TeacherRequests_ReviewedBy",
                table: "TeacherRequest",
                newName: "IX_TeacherRequest_ReviewedBy");

            migrationBuilder.RenameIndex(
                name: "IX_Subjects_UpdatedBy",
                table: "Subject",
                newName: "IX_Subject_UpdatedBy");

            migrationBuilder.RenameIndex(
                name: "IX_Subjects_CreatedBy",
                table: "Subject",
                newName: "IX_Subject_CreatedBy");

            migrationBuilder.RenameIndex(
                name: "IX_Roles_RoleName",
                table: "Role",
                newName: "IX_Role_RoleName");

            migrationBuilder.RenameIndex(
                name: "IX_RefreshTokens_UserId",
                table: "RefreshToken",
                newName: "IX_RefreshToken_UserId");

            migrationBuilder.RenameIndex(
                name: "IX_ExamQuestions_QuestionId",
                table: "ExamQuestion",
                newName: "IX_ExamQuestion_QuestionId");

            migrationBuilder.RenameIndex(
                name: "IX_ExamQuestions_ExamId_QuestionId",
                table: "ExamQuestion",
                newName: "IX_ExamQuestion_ExamId_QuestionId");

            migrationBuilder.RenameIndex(
                name: "IX_Enrollments_SubjectId",
                table: "Enrollment",
                newName: "IX_Enrollment_SubjectId");

            migrationBuilder.RenameIndex(
                name: "IX_Enrollments_StudentId_SubjectId",
                table: "Enrollment",
                newName: "IX_Enrollment_StudentId_SubjectId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_TeacherRequest",
                table: "TeacherRequest",
                column: "TeacherRequestId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Subject",
                table: "Subject",
                column: "SubjectId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Role",
                table: "Role",
                column: "RoleId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_RefreshToken",
                table: "RefreshToken",
                column: "RefreshTokenId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_ExamQuestion",
                table: "ExamQuestion",
                column: "ExamQuestionId");

            migrationBuilder.AddPrimaryKey(
                name: "PK_Enrollment",
                table: "Enrollment",
                column: "EnrollmentId");

            migrationBuilder.CreateIndex(
                name: "IX_TeacherSubjects_TeacherId",
                table: "TeacherSubjects",
                column: "TeacherId");

            migrationBuilder.AddForeignKey(
                name: "FK_Enrollment_Subject_SubjectId",
                table: "Enrollment",
                column: "SubjectId",
                principalTable: "Subject",
                principalColumn: "SubjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_Enrollment_Users_StudentId",
                table: "Enrollment",
                column: "StudentId",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_ExamQuestion_Exams_ExamId",
                table: "ExamQuestion",
                column: "ExamId",
                principalTable: "Exams",
                principalColumn: "ExamId");

            migrationBuilder.AddForeignKey(
                name: "FK_ExamQuestion_Questions_QuestionId",
                table: "ExamQuestion",
                column: "QuestionId",
                principalTable: "Questions",
                principalColumn: "QuestionId");

            migrationBuilder.AddForeignKey(
                name: "FK_Exams_Subject_SubjectId",
                table: "Exams",
                column: "SubjectId",
                principalTable: "Subject",
                principalColumn: "SubjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_Questions_Subject_SubjectId",
                table: "Questions",
                column: "SubjectId",
                principalTable: "Subject",
                principalColumn: "SubjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_RefreshToken_Users_UserId",
                table: "RefreshToken",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_Subject_Users_CreatedBy",
                table: "Subject",
                column: "CreatedBy",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_Subject_Users_UpdatedBy",
                table: "Subject",
                column: "UpdatedBy",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_TeacherRequest_Users_ReviewedBy",
                table: "TeacherRequest",
                column: "ReviewedBy",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_TeacherRequest_Users_StudentId",
                table: "TeacherRequest",
                column: "StudentId",
                principalTable: "Users",
                principalColumn: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_TeacherSubjects_Subject_SubjectId",
                table: "TeacherSubjects",
                column: "SubjectId",
                principalTable: "Subject",
                principalColumn: "SubjectId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_TeacherSubjects_Users_TeacherId",
                table: "TeacherSubjects",
                column: "TeacherId",
                principalTable: "Users",
                principalColumn: "UserId",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Role_RoleId",
                table: "Users",
                column: "RoleId",
                principalTable: "Role",
                principalColumn: "RoleId",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
