import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final String avatarUrl;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Hồ sơ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        
        // Avatar
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt, color: Colors.grey, size: 20),
              ),
            )
          ],
        ),
        const SizedBox(height: 12),
        
        // Tên & Role
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.creditGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(role, style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
            )
          ],
        ),
        const SizedBox(height: 4),
        Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text("Tham gia từ 20/11/2025", style: TextStyle(color: Colors.grey.shade400, fontSize: 10)),
        
        const SizedBox(height: 16),
        
        // Nút chỉnh sửa
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit, size: 16, color: Colors.green),
          label: const Text("Chỉnh sửa thông tin", style: TextStyle(color: Colors.green)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.creditGreen.withOpacity(0.2),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        )
      ],
    );
  }
}