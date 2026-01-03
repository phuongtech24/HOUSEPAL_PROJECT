import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String avatarUrl;
  final String role;

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

    // LOGIC XỬ LÝ ẢNH AN TOÀN
    ImageProvider? backgroundImage;
    
    if (avatarUrl.isNotEmpty && avatarUrl.startsWith('http')) {
      // 1. Nếu là link online (Firebase Storage, v.v.)
      backgroundImage = NetworkImage(avatarUrl);
    } else {
      // 2. Nếu là đường dẫn cục bộ hoặc rỗng -> Dùng ảnh Mèo mặc định có sẵn trong máy
      // Lưu ý: Đường dẫn phải khớp chính xác với khai báo trong pubspec.yaml
      backgroundImage = const AssetImage('lib/core/assets/avatars/meo.jpg');
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundImage: backgroundImage,
          backgroundColor: Colors.grey[200],
          // Thêm handler để nếu ảnh lỗi vẫn hiện icon
          onBackgroundImageError: (_, __) {
            // Log lỗi nếu cần
          },
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

// [Refactor] Code optimization pass 7
