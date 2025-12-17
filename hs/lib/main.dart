import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:firebase_core/firebase_core.dart'; 

import 'core/constants/app_colors.dart';

// --- 1. AUTHENTICATION (Xác thực) ---
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/authentication/presentation/pages/register_page.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';

// --- 2. HOUSE SETUP (Sảnh chờ & Tạo nhà) ---
import 'features/house_setup/presentation/pages/welcome_page.dart';
import 'features/house_setup/presentation/pages/join_house_page.dart';
import 'features/house_setup/presentation/pages/create_house_page.dart';
import 'features/house_setup/presentation/pages/house_management_page.dart';


// --- 4. EXPENSES (Quỹ chung) ---
import 'features/expenses/presentation/pages/expenses_page.dart';
import 'features/expenses/presentation/pages/add_expense_page.dart';
import 'features/expenses/presentation/pages/debt_optimization_page.dart';
import 'features/expenses/presentation/pages/expense_detail_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // if (Platform.isAndroid || Platform.isIOS) {
  //   await Firebase.initializeApp();
  // }

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
      ],
      child: const MyApp(),
    ),
  );
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
      
      // Màn hình khởi động đầu tiên
      home: const LoginPage(), 

      // --- DANH SÁCH ROUTES TOÀN BỘ DỰ ÁN ---
      routes: {
        // --- Auth ---
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),

        // --- Onboarding (Chưa có nhà) ---
        '/welcome': (context) => const WelcomePage(),
        '/join_house': (context) => const JoinHousePage(),
        '/create_house': (context) => const CreateHousePage(),

        
        
        // --- Expenses ---
        '/expenses': (context) => const ExpensesPage(),
        '/add_expense': (context) => const AddExpensePage(),
        '/debt_optimization': (context) => const DebtOptimizationPage(),
        '/expense_detail': (context) => const ExpenseDetailPage(), // Chi tiết chi tiêu
        
       
        '/house_management': (context) => const HouseManagementPage(),
      },
      
    // onGenerateRoute: (settings) => MaterialPageRoute(
    //     builder: (context) => Scaffold(
    //       body: Center(
    //         child: Text('No route defined for ${settings.name}'),
    //       ),
    //     ),
    //   ),
    );
  }
}