import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hs/features/house_setup/data/datasources/house_service.dart';

class HouseMembersPage extends StatelessWidget {
  final String houseId;
  final String adminId;

  const HouseMembersPage({
    super.key,
    required this.houseId,
    required this.adminId,
  });

  @override
  Widget build(BuildContext context) {
    final HouseService houseService = HouseService();
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final bool amIAdmin = currentUserId == adminId;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Thành viên", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: houseService.getHouseMembersStream(houseId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Lỗi tải dữ liệu"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final members = snapshot.data!.docs;

          if (members.isEmpty) {
            return const Center(child: Text("Chưa có thành viên nào."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final memberData = members[index].data() as Map<String, dynamic>;
              final String memberId = members[index].id;
              final String name = memberData['name'] ?? 'Không tên';
              
              final bool isMemberAdmin = memberId == adminId;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isMemberAdmin ? Colors.amber[100] : Colors.blue[100],
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: isMemberAdmin ? Colors.amber[800] : Colors.blue[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    isMemberAdmin ? "Quản trị viên" : "Thành viên",
                    style: TextStyle(color: isMemberAdmin ? Colors.amber : Colors.grey),
                  ),
                  trailing: (amIAdmin && !isMemberAdmin)
                      ? IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                             _confirmRemoveMember(context, houseService, memberId, name);
                          },
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmRemoveMember(BuildContext context, HouseService service, String uid, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa thành viên"),
        content: Text("Bạn chắc chắn muốn mời $name ra khỏi nhà?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              // --- SỬA Ở ĐÂY: Truyền thêm houseId vào hàm service ---
              await service.removeMember(houseId, uid); 
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Đã xóa $name")));
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}