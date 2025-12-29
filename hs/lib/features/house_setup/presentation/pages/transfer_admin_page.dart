import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs/features/house_setup/data/datasources/house_service.dart';

class TransferAdminPage extends StatelessWidget {
  final String houseId;

  const TransferAdminPage({super.key, required this.houseId});

  @override
  Widget build(BuildContext context) {
    final HouseService houseService = HouseService();
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Chuyển quyền Admin", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Chọn thành viên mới để bàn giao quyền quản lý nhà.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: houseService.getHouseMembersStream(houseId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                // Lọc bỏ chính mình ra khỏi danh sách (Admin không tự chuyển cho mình)
                final members = snapshot.data!.docs.where((doc) => doc.id != currentUserId).toList();

                if (members.isEmpty) {
                  return const Center(child: Text("Không có thành viên nào khác để chuyển quyền."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final memberData = members[index].data() as Map<String, dynamic>;
                    final String memberId = members[index].id;
                    final String name = memberData['name'] ?? 'Thành viên';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[50],
                          child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U'),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () => _confirmTransfer(context, houseService, memberId, name),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _confirmTransfer(BuildContext context, HouseService service, String newAdminId, String newAdminName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận chuyển quyền"),
        content: Text("Bạn sẽ chuyển quyền Admin cho $newAdminName và trở thành thành viên thường?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx); // Đóng dialog
              
              // --- SỬA Ở ĐÂY: Lấy ID admin hiện tại và truyền vào service ---
              final currentAdminId = FirebaseAuth.instance.currentUser!.uid;
              await service.transferAdmin(houseId, currentAdminId, newAdminId);
              
              if (context.mounted) {
                Navigator.pop(context); // Quay về trang trước vì mình không còn là Admin nữa
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Đã chuyển quyền cho $newAdminName")),
                );
              }
            },
            child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}