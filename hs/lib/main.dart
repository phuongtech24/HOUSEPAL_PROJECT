import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hs/features/bulletin_board/presentation/pages/add_bulletin_page.dart';
import 'package:hs/features/bulletin_board/presentation/pages/bulletin_board_page.dart';
import 'package:hs/features/profile/presentation/pages/profile_page.dart';
// import 'package:hs/features/bulletin_board/presentation/pages/add_bulletin_page.dart';
// import 'package:hs/features/bulletin_board/presentation/pages/bulletin_board_page.dart';
// import 'package:hs/features/profile/presentation/pages/profile_page.dart';
import 'package:hs/firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart'; 

import 'core/constants/app_colors.dart';
import 'package:provider/provider.dart';

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

// 5. Chores and home
import 'features/homes/presentation/home_page.dart';
import 'features/chores/presentation/pages/chores_page.dart';
import 'features/chores/presentation/pages/create_chore_page.dart';
import 'features/chores/presentation/pages/chores_ranking_page.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // if (Platform.isAndroid || Platform.isIOS) {
  //   await Firebase.initializeApp();
  // }
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
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
        //'/expense_detail': (context) => const ExpenseDetailPage(), // Chi tiết chi tiêu
        
       
        '/house_management': (context) => const HouseManagementPage(),

        // --- Home ---
        '/home': (context) => const HomePage(),

        // --- Chores ---
        '/chores': (context) => const ChoresPage(),
        '/chores/new': (context) => const CreateChorePage(),
        '/chores/ranking': (context) => const ChoresRankingPage(),

        '/bulletin_board': (context) => const BulletinBoardPage(),
        '/profile': (context) => const ProfilePage(),
        '/add_bulletin': (context) => const AddBulletinPage(),
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