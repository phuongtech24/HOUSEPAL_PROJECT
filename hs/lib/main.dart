import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart'; // Import Firebase
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'dart:io' show Platform;
// import 'firebase_options.dart'; // Bỏ comment dòng này sau khi chạy 'flutterfire configure'

// Import các file giao diện và màu sắc bạn đã tạo
import 'core/constants/app_colors.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/expenses/presentation/pages/expenses_page.dart';

void main() async {
  // Đảm bảo Flutter binding được khởi tạo trước khi gọi code native (như Firebase)
  WidgetsFlutterBinding.ensureInitialized();

  // --- PHẦN KẾT NỐI FIREBASE ---
  // Sẽ được kích hoạt sau khi cấu hình flutterfire configure
  // if (Platform.isAndroid || Platform.isIOS) {
  //   await Firebase.initializeApp();
  // }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt chữ DEBUG ở góc phải
      title: 'HousePal',
      
      // Thiết lập màu sắc chung cho cả app
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
          surfaceTintColor: Colors.white, // Tránh đổi màu khi scroll
        ),
      ),

      // --- ĐỊNH TUYẾN (NAVIGATION) ---
      // Màn hình đầu tiên khi mở app
      home: BlocProvider(
        create: (context) => AuthBloc(),
        child: const LoginPage(),
      ),

      // Định nghĩa các tên đường dẫn để chuyển trang dễ dàng
      routes: {
        '/login': (context) => BlocProvider(
          create: (context) => AuthBloc(),
          child: const LoginPage(),
        ),
        '/expenses': (context) => const ExpensesPage(),
      },
    );
  }
}