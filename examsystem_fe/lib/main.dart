import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routes/app_router.dart';
import 'features/exam/bloc/exam_bloc.dart';
import 'features/exam/data/exam_repository.dart';
import 'features/exam/domain/exam_service.dart';
import 'features/attempt/bloc/attempt_bloc.dart';
import 'features/attempt/data/attempt_repository.dart';
import 'features/question/bloc/question_bloc.dart';
import 'features/question/data/question_repository.dart';
import 'features/question/domain/question_service.dart';

import 'features/notification/bloc/notification_bloc.dart';
import 'features/notification/data/notification_repository.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const ExamSystemApp());
}

class ExamSystemApp extends StatelessWidget {
  const ExamSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ExamBloc(ExamService(ExamRepository())),
        ),
        BlocProvider(
          create: (context) => QuestionBloc(QuestionService(QuestionRepository())),
        ),
        BlocProvider(
          create: (context) => AttemptBloc(AttemptRepository()),
        ),
        BlocProvider(
          create: (context) => NotificationBloc(NotificationRepository()),
        ),
      ],
      child: MaterialApp.router(
        // ── Thông tin app ──────────────────────────────────────────────────────
        title: 'FPT ExamHub',

        // ── Ẩn badge "DEBUG" ở góc trên phải khi chạy debug mode ──────────────
        debugShowCheckedModeBanner: false,

        // ── Theme — màu sắc và font đồng bộ với thiết kế HTML ────────────────
        theme: _buildTheme(),

        // ── Kết nối với GoRouter từ AppRouter ─────────────────────────────────
        routerConfig: AppRouter.router,
      ),
    );
  }

  /// Xây dựng ThemeData đồng bộ với thiết kế HTML/Figma.
  ///
  /// Màu sắc lấy từ Tailwind config trong Splash & Onboarding.txt:
  ///   primary: #F15A22
  ///   background: #ffffff
  ///   on-background: #0b1c30
  ///   surface-container: #e5eeff
  ///   secondary: #485f84
  ThemeData _buildTheme() {
    // Dùng ColorScheme.fromSeed với seedColor là FPT Orange.
    // Material 3 tự tính toán toàn bộ bảng màu từ seed color.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFF15A22), // FPT Orange — primary từ HTML
      brightness: Brightness.light,
    ).copyWith(
      // Override các màu cần khớp chính xác với HTML design:
      primary: const Color(0xFFF15A22),        // primary: #F15A22
      surface: const Color(0xFFF8F9FF),         // surface: #f8f9ff
      surfaceContainerLowest: Colors.white,     // surface-container-lowest: #ffffff
      onSurface: const Color(0xFF0B1C30),       // on-surface: #0b1c30
      secondary: const Color(0xFF485F84),       // secondary: #485f84
      error: const Color(0xFFBA1A1A),           // error: #ba1a1a
      outline: const Color(0xFF8E7067),         // outline: #8e7067
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ),
      scaffoldBackgroundColor: AppTheme.lightBg,
    );
  }
}
