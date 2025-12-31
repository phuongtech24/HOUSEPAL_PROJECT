import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hs/firebase_options.dart';
import 'core/constants/app_colors.dart';

// --- CHỈ GIỮ LẠI IMPORT CỦA HOUSE SETUP ---
import 'features/house_setup/presentation/pages/welcome_page.dart';
import 'features/house_setup/presentation/pages/join_house_page.dart';
import 'features/house_setup/presentation/pages/create_house_page.dart';
import 'features/house_setup/presentation/pages/house_management_page.dart';

// Các import khác (Auth, Expenses, Chores...) ĐÃ BỊ XÓA

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lưu ý: Đã xóa MultiBlocProvider chứa AuthBloc vì feature Auth không tồn tại ở nhánh này.
  // Nếu màn hình của bạn cần Bloc, bạn cần mock hoặc xử lý riêng trong từng màn hình.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HousePal Setup',
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
      
      // --- THAY ĐỔI QUAN TRỌNG: Chạy thẳng vào màn hình Welcome ---
      home: const WelcomePage(), 

      // --- CHỈ GIỮ ROUTES CỦA HOUSE SETUP ---
      routes: {
        '/welcome': (context) => const WelcomePage(),
        '/join_house': (context) => const JoinHousePage(),
        '/create_house': (context) => const CreateHousePage(),
        '/house_management': (context) => const HouseManagementPage(),
      },
    );
  }
}