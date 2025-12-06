import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hs/features/authentication/presentation/pages/register_page.dart' show RegisterPage;
import 'package:hs/features/house_setup/presentation/pages/create_house_page.dart' show CreateHousePage;
import 'package:hs/features/house_setup/presentation/pages/house_management_page.dart' show HouseManagementPage;
import 'package:hs/features/house_setup/presentation/pages/join_house_page.dart' show JoinHousePage;
import 'package:hs/features/house_setup/presentation/pages/welcome_page.dart' show WelcomePage;

// Import các file
import 'core/constants/app_colors.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/expenses/presentation/pages/expenses_page.dart';
// Import các trang mới tạo nếu cần dùng routes
import 'features/expenses/presentation/pages/add_expense_page.dart';
import 'features/expenses/presentation/pages/debt_optimization_page.dart';
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
        // Auth
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(), // <-- Đã thêm route này

        // Expenses
        '/expenses': (context) => const ExpensesPage(),
        '/add_expense': (context) => const AddExpensePage(),
        '/debt_optimization': (context) => const DebtOptimizationPage(),
        
        

        // Profile & House Setup
        '/welcome': (context) => const WelcomePage(),
        '/join_house': (context) => const JoinHousePage(),
        
        '/house_management': (context) => const HouseManagementPage(),
        '/create_house': (context) => const CreateHousePage(),
      },
    );
  }
}