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
      // [FIX] Thêm Provider cho Theme/Locale
      child: ChangeNotifierProvider(
        create: (_) => AppSettingsNotifier(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // [FIX] Lắng nghe thay đổi từ AppSettingsNotifier
    final settings = Provider.of<AppSettingsNotifier>(context);

    // Xử lý Locale (Fake)
    // Nếu app có hỗ trợ i18n thật thì dùng locale: settings.locale
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HousePal',
      
      // [FIX] Cập nhật ThemeMode dựa trên settings
      themeMode: settings.themeMode, 
      
      theme: ThemeData( 
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        brightness: Brightness.light, // Light theme chuẩn
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
      ),
      
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: const Color(0xFF121212), // Pure black background
        useMaterial3: true,
        // Define Card Color explicitly
        cardColor: const Color(0xFF1E1E1E), 
        canvasColor: const Color(0xFF1E1E1E), // For BottomSheets
        dialogBackgroundColor: const Color(0xFF1E1E1E),
        
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          brightness: Brightness.dark,
          surface: const Color(0xFF1E1E1E), // Dark grey surface
          onSurface: Colors.white,
          background: const Color(0xFF121212),
          onBackground: Colors.white,
          secondary: const Color(0xFF00BFA5), // Teal accent
        ),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212), // Match scaffold for seamless look
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
          elevation: 0, // Modern flat look
          shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.all(Radius.circular(16)),
             side: BorderSide(color: Color(0x1A9E9E9E)), // Colors.grey.withOpacity(0.1) replacement
          ),
        ),

        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFFEEEEEE)), // Slightly off-white
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Colors.white),
        ),
        
        dividerTheme: DividerThemeData(
          color: Colors.grey.withOpacity(0.15),
          thickness: 1,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
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

// [FIX] Class quản lý trạng thái Global cho Settings
class AppSettingsNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _language = "Tiếng Việt";

  ThemeMode get themeMode => _themeMode;
  String get language => _language;

  void setTheme(String mode) {
    if (mode == "Sáng") _themeMode = ThemeMode.light;
    else if (mode == "Tối") _themeMode = ThemeMode.dark;
    else _themeMode = ThemeMode.system;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
    // Ở đây bạn có thể gọi logic i18n nếu có
  }
}