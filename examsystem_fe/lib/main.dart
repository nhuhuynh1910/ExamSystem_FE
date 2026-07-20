import 'package:flutter/material.dart';
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
        title: 'ExamSystem',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
