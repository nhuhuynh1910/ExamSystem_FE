/// Events cho TeacherDashboardBloc.
abstract class TeacherDashboardEvent {
  const TeacherDashboardEvent();
}

/// Load dữ liệu dashboard (gọi khi màn hình khởi tạo).
class TeacherDashboardLoadRequested extends TeacherDashboardEvent {
  const TeacherDashboardLoadRequested();
}

/// Thay đổi filter tab (All / Draft / Published / Closed).
///
/// [status] = null nghĩa là "All" (hiển thị tất cả).
class TeacherDashboardFilterChanged extends TeacherDashboardEvent {
  final String? status;
  const TeacherDashboardFilterChanged(this.status);
}
