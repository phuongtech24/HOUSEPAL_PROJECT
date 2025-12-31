import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hs/firebase_options.dart';
import 'core/constants/app_colors.dart';

// --- CHỈ GIỮ IMPORT CỦA PROFILE ---
import 'features/profile/presentation/pages/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HousePal Profile',
      theme: ThemeData( 
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
      ),
      
      // Chạy thẳng vào trang Profile
      home: const ProfilePage(), 

      routes: {
        '/profile': (context) => const ProfilePage(),
      },
    );
  }
}