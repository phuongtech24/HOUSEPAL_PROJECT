import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hs/firebase_options.dart';
import 'core/constants/app_colors.dart';

// --- CHỈ GIỮ IMPORT CỦA EXPENSES ---
import 'features/expenses/presentation/pages/expenses_page.dart';
import 'features/expenses/presentation/pages/add_expense_page.dart';
import 'features/expenses/presentation/pages/debt_optimization_page.dart';
// import 'features/expenses/presentation/pages/expense_detail_page.dart'; // Mở nếu cần

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Lưu ý: Đã xóa MultiBlocProvider vì AuthBloc không tồn tại trong nhánh này
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HousePal Expenses',
      theme: ThemeData( 
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      
      // Chạy thẳng vào trang Chi tiêu để test
      home: const ExpensesPage(), 

      routes: {
        '/expenses': (context) => const ExpensesPage(),
        '/add_expense': (context) => const AddExpensePage(),
        '/debt_optimization': (context) => const DebtOptimizationPage(),
      },
    );
  }
}