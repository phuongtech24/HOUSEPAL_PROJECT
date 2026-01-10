import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/chore_model.dart';
import '../../../authentication/data/models/user_model.dart';
import '../widgets/chore_widgets.dart';
import '../../data/datasources/chore_service.dart';
import 'create_chore_page.dart';

class ChoreDetailPage extends StatefulWidget {
  final ChoreModel chore;

  const ChoreDetailPage({
    super.key,
    required this.chore,
  });

  @override
  State<ChoreDetailPage> createState() => _ChoreDetailPageState();
}

class _ChoreDetailPageState extends State<ChoreDetailPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _choreService = ChoreService();

  Map<String, UserModel> _userMap = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHouseMembers();
  }

  Future<void> _loadHouseMembers() async {
    final uid = _auth.currentUser!.uid;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final houseId = userDoc['houseId'];

    _firestore
        .collection('users')
        .where('houseId', isEqualTo: houseId)
        .snapshots()
        .listen((snapshot) {
      final map = <String, UserModel>{};
      for (final doc in snapshot.docs) {
        final user = UserModel.fromMap(doc.data());
        map[user.uid] = user;
      }

      setState(() {
        _userMap = map;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final chore = widget.chore;
    final currentUserUid = _auth.currentUser!.uid;

    final bool isCompleted = chore.status == 'completed';
    final bool isMyTurn = chore.currentGroupId == currentUserUid;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentIndex =
        chore.groupOrder.indexOf(chore.currentGroupId);

    final String currentUid = chore.currentGroupId;
    final String? prevUid =
        currentIndex > 0 ? chore.groupOrder[currentIndex - 1] : null;
    final String? nextUid =
        currentIndex < chore.groupOrder.length - 1
            ? chore.groupOrder[currentIndex + 1]
            : null;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Chi tiết việc nhà',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsBottomSheet(context, chore),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          _MainHeader(chore: chore),
          const SizedBox(height: 16),


          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chu kỳ xoay vòng',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (prevUid != null && _userMap[prevUid] != null) ...[
                       _RotationAvatar(
                        user: _userMap[prevUid]!,
                        label: 'Lượt trước',
                        highlight: false,
                         isNext: false,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                    ],
                    _RotationAvatar(
                      user: _userMap[currentUid]!,
                      label: 'Lượt hiện tại',
                      highlight: true,
                       isNext: false,
                    ),
                    if (nextUid != null && _userMap[nextUid] != null) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      _RotationAvatar(
                        user: _userMap[nextUid]!,
                        label: 'Tiếp theo',
                        highlight: false,
                         isNext: true,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _InfoRow(
            icon: Icons.schedule,
            title: 'Thời gian đề xuất',
            value: '09:00 - 18:00',
          ),
          const SizedBox(height: 12),

          _InfoRow(
            icon: Icons.calendar_month,
            title: 'Hạn chót & tần suất',
            value: '28 Thg 11, 2025 · Hàng tháng',
          ),
          const SizedBox(height: 12),

          _InfoRow(
            icon: Icons.description,
            title: 'Mô tả',
            value:
                chore.description.isEmpty ? 'Không có mô tả' : chore.description,
          ),
        ],
      ),

      /// ===== BOTTOM ACTION =====
      bottomNavigationBar: _buildBottomAction(
        isMyTurn: isMyTurn,
        isCompleted: isCompleted,
        chore: chore,
        currentUid: currentUid,
      ),
    );
  }

  Widget? _buildBottomAction({
    required bool isMyTurn,
    required bool isCompleted,
    required ChoreModel chore,
    required String currentUid,
  }) {
    if (isCompleted) return null;

    if (isMyTurn) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () async {
                await _choreService.completeChore(chore);
                if (mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Hoàn thành việc',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () async {
              await _choreService.sendReminder(
                toUid: currentUid,
                choreId: chore.id,
                choreTitle: chore.title,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã gửi nhắc nhở')),
                );
              }
            },
            icon: const Icon(Icons.notifications_active, color: Colors.white),
            label: Text(
              'Nhắc ${_userMap[currentUid]!.name}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context, ChoreModel chore) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tùy Chọn Việc Nhà',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Quản lý công việc "${chore.title}"',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // EDIT BUTTON
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateChorePage(chore: chore),
                    ),
                  ).then((_) {
                     Navigator.pop(context);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.edit, color: kPrimaryGreen, size: 20),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Chỉnh sửa',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Cập nhật thông tin, thời gian',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // DELETE BUTTON
              InkWell(
                onTap: () {
                  // Showing delete for now
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content: const Text(
                          'Bạn có chắc chắn muốn xóa công việc này không?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Hủy')),
                        TextButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                            await _choreService.deleteChore(chore.id);
                            if (mounted) Navigator.pop(context);
                          },
                          child: const Text('Xóa',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Xóa việc nhà này',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // CLOSE
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



class _MainHeader extends StatelessWidget {
  final ChoreModel chore;

  const _MainHeader({required this.chore});

  @override
  Widget build(BuildContext context) {
    final done = chore.status == 'completed';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5F8ED),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.cleaning_services_outlined,
                    color: kPrimaryGreen, size: 28),
              ),
              _Chip(
                text: done ? 'Đã hoàn thành' : 'Đến hạn hôm nay',
                color: done ? const Color(0xFFE5F8ED) : const Color(0xFFFFF0E6),
                textColor: done ? kPrimaryGreen : const Color(0xFFFF6E2E),
                 icon: done ? Icons.check_circle : Icons.warning_amber_rounded,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  chore.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _Chip(
                text: '+${chore.points} Điểm',
                color: kPrimaryGreen,
                textColor: Colors.white,
                 fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}



class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final IconData? icon;
  final FontWeight? fontWeight;

  const _Chip({
    required this.text,
    required this.color,
    required this.textColor,
    this.icon,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: fontWeight ?? FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RotationAvatar extends StatelessWidget {
  final UserModel user;
  final String label;
  final bool highlight;
  final bool isNext;

  const _RotationAvatar({
    required this.user,
    required this.label,
    required this.highlight,
    required this.isNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: highlight
                    ? Border.all(color: kPrimaryGreen, width: 2)
                    : null,
              ),
              child: CircleAvatar(
                radius: highlight ? 32 : 24,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? AssetImage(user.avatarUrl)
                    : const AssetImage('lib/core/assets/avatars/meo3.jpg'),
              ),
            ),
            if (highlight)
              Positioned(
                bottom: -10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: kPrimaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Lượt hiện tại',
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          user.name,
          style: TextStyle(
            fontSize: 14, 
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
            color: Colors.black
          ),
        ),
        if (highlight)
          const Text(
            'Chưa hoàn thành',
            style: TextStyle(fontSize: 12, color: Colors.deepOrange),
          )
        else
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F7),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF5E6C84), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kGreyText,
                        letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Formatting fix
