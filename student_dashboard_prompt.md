<prompt_architecture>
  <system_persona>
    Bạn là Senior Flutter Developer & UI/UX Architect trong dự án FPT ExamHub (`examsystem_fe`), am hiểu Clean Architecture, Repository Pattern và State Management (Bloc/Cubit).
  </system_persona>

  <task_objective>
    Xây dựng hoàn chỉnh tính năng **Student Dashboard (Trang chủ Sinh viên)** tại `lib/features/student_dashboard/` phản ánh chính xác 100% thiết kế giao diện từ file prototype `student_dashboard.txt` với chuẩn nhận diện FPT (FPT Orange `#F15A22`, Navy `#1D3557`, hiệu ứng bóng đổ `orange-glow`, viền `border-l-4 border-fpt-orange`).
  </task_objective>

  <strict_constraints>
    1. **KHÔNG SỬA BACKEND (`ExamSystem_BE`) NẾU KHÔNG CẦN THIẾT:**
       - Hệ thống đã có đủ API cho Student. Chỉ gọi các REST endpoints hiện có qua Dio/Repository layer.
    2. **TÁI SỬ DỤNG TỐI ĐA WIDGET & LOGIC HIỆN CÓ (`dùng lại tất cả chức năng hiện có`):**
       - Tận dụng các component chuẩn từ `lib/features/teacher_dashboard/presentation/widgets/`:
         `dashboard_header.dart`, `stats_strip.dart`, `exam_card.dart` và chỉnh sửa style theo đúng mẫu UI mới.
       - Kế thừa pattern xử lý lỗi `_extractErrorMessage(DioException e, String defaultMessage)` từ `TeacherDashboardRepositoryImpl`.
    3. **KHÔNG ĐỤNG ĐẾN CÁC CHỨC NĂNG ĐANG HOẠT ĐỘNG:**
       - Tuyệt đối không làm vỡ hoặc thay đổi code thuộc `auth`, `teacher_dashboard`, `profile`.
       - Xây dựng module mới độc lập tại `lib/features/student_dashboard/`.
  </strict_constraints>

  <backend_api_mapping>
    Ánh xạ chính xác các UI component trong `student_dashboard.txt` với API từ `ExamSystem_BE`:
    - **Top Header (`Hello, Minh 👋`, Badge `3` notifications):**
      - `GET /api/profile` (Lấy tên sinh viên hiển thị lời chào).
      - `GET /api/notifications?isRead=false` (Lấy số lượng thông báo chưa đọc cho chuông thông báo).
    - **Stats Strip (`5 Enrolled`, `12 Exams Taken`, `95% Best Score`):**
      - `GET /api/subjects/student` (hoặc API lấy danh sách môn học của SV -> Đếm số môn `Enrolled`).
      - `GET /api/attempts/student` (hoặc API lịch sử làm bài -> Đếm tổng số `Exams Taken` và lọc ra `Best Score`).
    - **Upcoming Exams Section (`📅 Upcoming Exams` - `Advanced Algorithms Midterm / PRN211`):**
      - `GET /api/exams?Status=Published` (Lọc các đề thi có thời gian mở `StartTime` sắp diễn ra hoặc đang mở).
      - Action click vào thẻ bài thi -> Gọi `POST /api/exams/{id}/check-access` & `POST /api/exams/{id}/start` trước khi chuyển sang `ExamTakingScreen`.
    - **My Subjects Section (`📖 My Subjects` - `Software Engineering / Dr. Le Van Nam`):**
      - `GET /api/subjects/enrolled` (Lấy danh sách môn học đã đăng ký kèm tên giảng viên và số lượng sinh viên `32`).
  </backend_api_mapping>

  <ui_ux_blueprint>
    Giao diện Student Dashboard cấu trúc chuẩn theo đúng HTML `student_dashboard.txt` gồm 5 phần chính:
    
    1. **Top Header Bar (`bg-fpt-orange`):**
       - Logo FPT màu trắng (`brightness-0 invert`), tiêu đề app `FPT ExamHub`.
       - Lời chào căn giữa/lệch `Hello, Minh 👋`.
       - Icon chuông `notifications` kèm badge đỏ đếm (`3`) bo viền cam (`border-2 border-fpt-orange`).
    2. **Stats Strip (Thanh Thống kê 3 ô lướt ngang - shadow `orange-glow`):**
       - Thẻ 1 (`book` icon): `5` | `Enrolled` (Môn học).
       - Thẻ 2 (`check_circle` icon): `12` | `Exams Taken` (Bài đã làm).
       - Thẻ 3 (`emoji_events` icon): `95%` | `Best Score` (Điểm cao nhất).
    3. **Upcoming Exams Section (`📅 Upcoming Exams` + Nút `See All`):**
       - Lướt ngang (`horizontal scroll`), mỗi card có viền trái cam (`border-l-4 border-fpt-orange`).
       - Thông tin card: Tên đề thi (`Advanced Algorithms Midterm`), tag môn học pill (`PRN211`), thời gian bắt đầu (`schedule` icon - `Starts in 2 days`), thời gian thi (`timer` icon - `60 min`).
    4. **My Subjects Section (`📖 My Subjects`):**
       - Danh sách dọc các môn học đã đăng ký, card viền trái cam (`border-l-4 border-fpt-orange`).
       - Thông tin card: Tên môn (`Software Engineering`), tên giảng viên (`Dr. Le Van Nam`), badge số lượng sinh viên (`group` icon - `32`), mũi tên `chevron_right`.
    5. **Bottom Navigation Bar (Cố định đáy màn hình):**
       - 4 Tabs: `Home` (Active - có thanh chỉ thị `active-indicator` màu cam trên đỉnh `top: 0`), `Exams` (`assignment`), `Results` (`leaderboard`), `Profile` (`person`).
  </ui_ux_blueprint>

  <execution_checklist>
    - [ ] Khởi tạo folder `lib/features/student_dashboard/{data,domain,presentation}` đúng chuẩn Clean Architecture.
    - [ ] Implements `StudentDashboardRemoteDataSource` & `StudentDashboardRepositoryImpl` kết nối Dio với các REST API đã ánh xạ.
    - [ ] Xây dựng `StudentDashboardScreen` chứa `RefreshIndicator`, `StudentHeader`, `StudentStatsStrip`, `UpcomingExamsSection`, `MySubjectsSection`.
    - [ ] Viết UI chính xác từng token màu: `#F15A22` (Orange), `#1D3557` (Navy), bóng đổ `orange-glow` và viền `border-l-4 border-fpt-orange`.
    - [ ] Gắn sự kiện chuyển hướng từ `UpcomingExams` sang `ExamTakingScreen` (qua bước `check-access` & `start`).
    - [ ] Kiểm thử luồng điều hướng `auth` đảm bảo Student vào đúng `StudentDashboardScreen` và không ảnh hưởng Teacher.
  </execution_checklist>
</prompt_architecture>
