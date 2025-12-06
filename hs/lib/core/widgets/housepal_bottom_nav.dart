// lib/core/widgets/housepal_bottom_nav.dart
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class HousePalBottomNav extends StatelessWidget {
  const HousePalBottomNav({super.key, required this.currentIndex});

  final int
  currentIndex; // 0: Trang chủ, 1: Việc nhà, 2: Quỹ chung, 3: Bảng tin, 4: Hồ sơ

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/chores');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/expenses');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/bulletin_board');
        break;
      case 4:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primary, // item đang chọn: xanh
      unselectedItemColor: Colors.grey, // item còn lại: xám
      showUnselectedLabels: true,
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.cleaning_services_outlined),
          label: 'Việc nhà',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Quỹ chung',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: 'Bảng tin',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Hồ sơ',
        ),
      ],
    );
  }
}
