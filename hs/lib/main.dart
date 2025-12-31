import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hs/firebase_options.dart';
import 'core/constants/app_colors.dart';

// --- CHỈ GIỮ IMPORT CỦA BULLETIN BOARD ---
import 'features/bulletin_board/presentation/pages/bulletin_board_page.dart';
import 'features/bulletin_board/presentation/pages/add_bulletin_page.dart';

// Các import khác (Auth, Expenses, House Setup, Profile...) ĐÃ BỊ XÓA

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lưu ý: Đã xóa MultiBlocProvider chứa AuthBloc vì feature Auth không tồn tại ở nhánh này.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HousePal Bulletin',
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
      
      // --- THAY ĐỔI QUAN TRỌNG: Chạy thẳng vào Bảng Tin ---
      home: const BulletinBoardPage(), 

      // --- CHỈ GIỮ ROUTES CỦA BULLETIN BOARD ---
      routes: {
        '/bulletin_board': (context) => const BulletinBoardPage(),
        '/add_bulletin': (context) => const AddBulletinPage(),
      },
    );
  }
}