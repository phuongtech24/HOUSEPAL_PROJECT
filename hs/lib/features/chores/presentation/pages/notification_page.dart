import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('toUid', isEqualTo: uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;


          docs.sort((a, b) {
            final t1 = (a.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            final t2 = (b.data() as Map<String, dynamic>)['createdAt'] as Timestamp?;
            if (t1 == null && t2 == null) return 0;
            if (t1 == null) return 1;
            if (t2 == null) return -1;
            return t2.compareTo(t1);
          });

          if (docs.isEmpty) {
            return const Center(child: Text('Không có thông báo'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5F8ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: Color(0xFF00D26A)),
                ),
                title: Text(data['title'] ?? 'Thông báo'),
                subtitle: Text(data['body'] ?? ''),
                trailing: data['isRead'] == true
                    ? null
                    : const Icon(Icons.circle, size: 10, color: Color(0xFF00D26A)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: const Border(bottom: BorderSide(color: Color(0xFFF2F4F7))),
                onTap: () {
                  docs[i].reference.update({'isRead': true});
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Auto-generated tweak
