import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum MenuType { switchType, arrow, dropdown }

class ProfileMenuOption extends StatelessWidget {
  final String title;
  final MenuType type;
  final bool? switchValue;
  final String? dropdownValue;
  final VoidCallback? onTap;

  const ProfileMenuOption({
    super.key, 
    required this.title, 
    required this.type,
    this.switchValue,
    this.dropdownValue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0), // Padding rộng hơn cho thoáng
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          if (type == MenuType.switchType)
            SizedBox(
              height: 24,
              child: Switch(
                value: switchValue ?? false,
                activeColor: AppColors.primary,
                onChanged: (val) {}, // Xử lý callback sau
              ),
            ),
          if (type == MenuType.dropdown)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(dropdownValue ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ),
          if (type == MenuType.arrow)
             const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}