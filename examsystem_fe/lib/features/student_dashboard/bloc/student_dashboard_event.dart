/// Events cho StudentDashboardBloc.
abstract class StudentDashboardEvent {
  const StudentDashboardEvent();
}

/// Load dữ liệu dashboard (gọi khi màn hình khởi tạo hoặc pull-to-refresh).
class StudentDashboardLoadRequested extends StudentDashboardEvent {
  const StudentDashboardLoadRequested();
}
