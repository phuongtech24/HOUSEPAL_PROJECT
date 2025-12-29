import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs/features/authentication/data/models/user_model.dart';

import '../widgets/chore_widgets.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';
import 'create_chore_success_page.dart';
import '../../data/datasources/chore_service.dart';

enum RepeatFrequency { none, daily, monthly, yearly }

class CreateChorePage extends StatefulWidget {
  const CreateChorePage({super.key});

  @override
  State<CreateChorePage> createState() => _CreateChorePageState();
}

class _CreateChorePageState extends State<CreateChorePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _choreService = ChoreService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pointsController =
      TextEditingController(text: '0');

  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(hours: 1));

  RepeatFrequency _frequency = RepeatFrequency.none;
  int _points = 0;
  bool _autoRotate = false;

  /// ===== MEMBERS (REALTIME) =====
  List<UserModel> _houseMembers = [];
  Map<String, bool> _selectedMembers = {};
  String? _assignedMemberUid;

  bool _loadingMembers = true;

  @override
  void initState() {
    super.initState();
    _loadHouseMembers();
  }

  /* ================= LOAD MEMBERS ================= */

  Future<void> _loadHouseMembers() async {
    final uid = _auth.currentUser!.uid;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    final houseId = userDoc['houseId'];

    _firestore
        .collection('users')
        .where('houseId', isEqualTo: houseId)
        .snapshots()
        .listen((snapshot) {
      final users =
          snapshot.docs.map((e) => UserModel.fromMap(e.data())).toList();

      setState(() {
        _houseMembers = users;
        _loadingMembers = false;
        for (final u in users) {
          _selectedMembers.putIfAbsent(u.uid, () => true);
        }
      });
    });
  }

  /* ================= HELPERS ================= */

  String _frequencyLabel(RepeatFrequency f) {
    switch (f) {
      case RepeatFrequency.none:
        return 'Không lặp lại';
      case RepeatFrequency.daily:
        return 'Hàng ngày';
      case RepeatFrequency.monthly:
        return 'Hàng tháng';
      case RepeatFrequency.yearly:
        return 'Hàng năm';
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _formatTime(DateTime s, DateTime e) =>
      '${s.hour}:${s.minute.toString().padLeft(2, '0')} → ${e.hour}:${e.minute.toString().padLeft(2, '0')}';

  void _changePoints(int delta) {
    setState(() {
      _points = (_points + delta).clamp(0, 999);
      _pointsController.text = _points.toString();
    });
  }

  String _buildOrderText() {
    final order = _houseMembers
        .where((u) => _selectedMembers[u.uid] == true)
        .map((u) => u.name)
        .toList();
    return order.isEmpty ? 'Chưa chọn thành viên' : order.join(' ➝ ');
  }

  /* ================= CREATE ================= */

  Future<void> _createChore() async {
    final selectedUids = _autoRotate
        ? _houseMembers
            .where((u) => _selectedMembers[u.uid] == true)
            .map((u) => u.uid)
            .toList()
        : [_assignedMemberUid!];

    if (selectedUids.isEmpty) return;

    await _choreService.createChore(
      title: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      repeatType: _frequency.name,
      points: _points,
      groupOrder: selectedUids,
      startDate: _start,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CreateChoreSuccessPage()),
      );
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    final orderText = _buildOrderText();

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
          'Tạo việc nhà mới',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: _loadingMembers
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                _InputCard(
                  label: 'Tên việc nhà',
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Ví dụ: Vệ sinh tủ lạnh',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _InputCard(
                  label: 'Mô tả (Tùy chọn)',
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration:
                        const InputDecoration(border: InputBorder.none),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _InputCard(
                        label: 'Ngày thực hiện',
                        child: InkWell(
                          onTap: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: _start,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (d != null) {
                              setState(() {
                                _start = DateTime(d.year, d.month, d.day,
                                    _start.hour, _start.minute);
                                _end = DateTime(d.year, d.month, d.day,
                                    _end.hour, _end.minute);
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(child: Text(_formatDate(_start))),
                              const Icon(Icons.calendar_today_outlined,
                                  size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InputCard(
                        label: 'Khung giờ làm việc',
                        child: InkWell(
                          onTap: () async {
                            final s = await showTimePicker(
                                context: context,
                                initialTime:
                                    TimeOfDay.fromDateTime(_start));
                            final e = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(_end));
                            if (s != null && e != null) {
                              setState(() {
                                _start = DateTime(_start.year, _start.month,
                                    _start.day, s.hour, s.minute);
                                _end = DateTime(_end.year, _end.month,
                                    _end.day, e.hour, e.minute);
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Expanded(child: Text(_formatTime(_start, _end))),
                              const Icon(Icons.access_time, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                _InputCard(
                  label: 'Tần suất lặp lại',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<RepeatFrequency>(
                      value: _frequency,
                      isExpanded: true,
                      items: RepeatFrequency.values
                          .map((f) => DropdownMenuItem(
                                value: f,
                                child: Text(_frequencyLabel(f)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _frequency = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _InputCard(
                  label: 'Điểm',
                  child: Row(
                    children: [
                      _StepButton(
                          icon: Icons.remove,
                          onTap: () => _changePoints(-1)),
                      Expanded(
                        child: TextField(
                          controller: _pointsController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      _StepButton(
                          icon: Icons.add,
                          onTap: () => _changePoints(1)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                /// AUTO ROTATE
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAFBF3),
                    borderRadius: kCardRadius,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sync, color: kPrimaryGreen),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Tự động xoay vòng',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          ),
                          Switch(
                              value: _autoRotate,
                              onChanged: (v) =>
                                  setState(() => _autoRotate = v)),
                        ],
                      ),
                      if (_autoRotate) ...[
                        const SizedBox(height: 12),
                        ..._houseMembers.map((u) {
                          return CheckboxListTile(
                            value: _selectedMembers[u.uid],
                            title: Text(u.name),
                            onChanged: (v) =>
                                setState(() => _selectedMembers[u.uid] = v!),
                            controlAffinity:
                                ListTileControlAffinity.leading,
                          );
                        }),
                        Text('Thứ tự xoay vòng: $orderText'),
                      ]
                    ],
                  ),
                ),

                if (!_autoRotate) ...[
                  const SizedBox(height: 12),
                  _InputCard(
                    label: 'Phân công cho',
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _assignedMemberUid,
                        hint: const Text('Chọn thành viên'),
                        isExpanded: true,
                        items: _houseMembers
                            .map((u) => DropdownMenuItem(
                                  value: u.uid,
                                  child: Text(u.name),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _assignedMemberUid = v),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _createChore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Tạo việc nhà',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black, 
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 1),
    );
  }
}

/* ================= UI HELPERS ================= */

class _InputCard extends StatelessWidget {
  const _InputCard({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kCardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE3E5EA)),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: Color(0xFFE7F1E9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: kPrimaryGreen),
      ),
    );
  }
}
