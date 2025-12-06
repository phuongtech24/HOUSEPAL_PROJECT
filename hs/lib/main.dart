import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import các file
import 'core/constants/app_colors.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/expenses/presentation/pages/expenses_page.dart';
// Import các trang mới tạo nếu cần dùng routes
import 'features/expenses/presentation/pages/add_expense_page.dart';
import 'features/expenses/presentation/pages/debt_optimization_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // if (Platform.isAndroid || Platform.isIOS) {
  //   await Firebase.initializeApp();
  // }
  runApp(const AppProvider());
}

// 1. Tạo lớp trung gian để Cung cấp Bloc cho toàn bộ App
class AppProvider extends StatelessWidget {
  const AppProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Khởi tạo AuthBloc ở cấp cao nhất
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HousePal',
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
      ),
      
      // 2. Home gọi trực tiếp LoginPage (Bloc đã có sẵn từ AppProvider bao ngoài)
      home: const LoginPage(),

      // 3. Định nghĩa Routes
      routes: {
        '/login': (context) => const LoginPage(),
        '/expenses': (context) => const ExpensesPage(),
        '/add_expense': (context) => const AddExpensePage(),
      },
    );
  }
}