using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace JWT.Migrations
{
    /// <inheritdoc />
    public partial class FixTeacherSubjectRelation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_TeacherSubjects_Subjects_SubjectId1",
                table: "TeacherSubjects");

            migrationBuilder.DropForeignKey(
                name: "FK_TeacherSubjects_Users_UserId",
                table: "TeacherSubjects");

            migrationBuilder.DropIndex(
                name: "IX_TeacherSubjects_SubjectId1",
                table: "TeacherSubjects");

            migrationBuilder.DropIndex(
                name: "IX_TeacherSubjects_UserId",
                table: "TeacherSubjects");

            migrationBuilder.DropColumn(
                name: "SubjectId1",
                table: "TeacherSubjects");

            migrationBuilder.DropColumn(
                name: "UserId",
                table: "TeacherSubjects");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
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

            migrationBuilder.CreateIndex(
                name: "IX_TeacherSubjects_SubjectId1",
                table: "TeacherSubjects",
                column: "SubjectId1");

            migrationBuilder.CreateIndex(
                name: "IX_TeacherSubjects_UserId",
                table: "TeacherSubjects",
                column: "UserId");

            migrationBuilder.AddForeignKey(
                name: "FK_TeacherSubjects_Subjects_SubjectId1",
                table: "TeacherSubjects",
                column: "SubjectId1",
                principalTable: "Subjects",
                principalColumn: "SubjectId");

            migrationBuilder.AddForeignKey(
                name: "FK_TeacherSubjects_Users_UserId",
                table: "TeacherSubjects",
                column: "UserId",
                principalTable: "Users",
                principalColumn: "UserId");
        }
    }
}
