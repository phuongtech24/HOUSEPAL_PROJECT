import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String avatarUrl;
  final String role; // 'admin' hoặc 'member'

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundImage: (avatarUrl.isNotEmpty) ? NetworkImage(avatarUrl) : null,
          backgroundColor: Colors.grey[300],
          child: (avatarUrl.isEmpty) ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isAdmin ? const Color(0xFFD1FADF) : const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isAdmin ? 'Admin' : 'Thành viên',
                style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold,
                  color: isAdmin ? const Color(0xFF039855) : const Color(0xFF0288D1)
                ),
              ),
            ),
          ],
        ),
        Text(email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }
}