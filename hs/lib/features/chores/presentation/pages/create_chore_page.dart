import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hs/features/authentication/data/models/user_model.dart';

import '../widgets/chore_widgets.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';
import 'create_chore_success_page.dart';
import '../../data/datasources/chore_service.dart';
import '../../data/models/chore_model.dart';

enum RepeatFrequency { none, daily, monthly, yearly }

class CreateChorePage extends StatefulWidget {
  final ChoreModel? chore;

  const CreateChorePage({super.key, this.chore});

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

  List<String> _rotationOrder = [];
  
  bool _autoRotate = false;
  List<UserModel> _houseMembers = [];
  Map<String, bool> _selectedMembers = {};
  String? _assignedMemberUid;
  bool _loadingMembers = true;

  @override
  void initState() {
    super.initState();
    _loadHouseMembers();

    if (widget.chore != null) {
      final c = widget.chore!;
      _nameController.text = c.title;
      _descriptionController.text = c.description;
      _points = c.points;
      _pointsController.text = _points.toString();
      _start = c.startDate;
      _end = c.startDate.add(const Duration(hours: 1)); 
      _frequency = RepeatFrequency.values.firstWhere(
        (e) => e.name == c.repeatType,
        orElse: () => RepeatFrequency.none,
      );
      _autoRotate = c.groupOrder.length > 1;
      _rotationOrder = List.from(c.groupOrder); 
    }
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
      final users =
          snapshot.docs.map((e) => UserModel.fromMap(e.data())).toList();

      if (!mounted) return;

      setState(() {
        _houseMembers = users;
        _loadingMembers = false;

        final isEdit = widget.chore != null;
        final chore = widget.chore;


        if (isEdit) {
           // Sync selectedMembers with rotationOrder
           for (var u in users) {
             _selectedMembers[u.uid] = _rotationOrder.contains(u.uid);
           }
           if (!_autoRotate && chore!.groupOrder.isNotEmpty) {
             _assignedMemberUid = chore.groupOrder.first;
           }
        } else {

          for (var u in users) {
            _selectedMembers[u.uid] = true;
            if (!_rotationOrder.contains(u.uid)) {
              _rotationOrder.add(u.uid);
            }
          }

           if (users.isNotEmpty) _assignedMemberUid = users.first.uid;
        }
      });
    });
  }


  void _toggleMember(String uid, bool? selected) {
    setState(() {
      _selectedMembers[uid] = selected ?? false;
      if (selected == true) {
        if (!_rotationOrder.contains(uid)) {
          _rotationOrder.add(uid);
        }
      } else {
        _rotationOrder.remove(uid);
      }
    });
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

  Future<void> _createChore() async {

    List<String> finalGroupOrder = [];
    
    if (_autoRotate) {
      if (_rotationOrder.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ít nhất 1 thành viên')));
        return;
      }
      finalGroupOrder = _rotationOrder;
    } else {
      if (_assignedMemberUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng phân công cho 1 thành viên')));
        return;
      }
      finalGroupOrder = [_assignedMemberUid!];
    }

    if (_nameController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên việc nhà')));
       return;
    }


    if (widget.chore != null) {
      await _choreService.updateChore(
        choreId: widget.chore!.id,
        title: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        repeatType: _frequency.name,
        points: _points,
        groupOrder: finalGroupOrder,
        startDate: _start,
        currentGroupId: !_autoRotate ? finalGroupOrder.first : null,
      );
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật việc nhà!')));
         Navigator.pop(context);
      }
    } else {
      await _choreService.createChore(
        title: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        repeatType: _frequency.name,
        points: _points,
        groupOrder: finalGroupOrder,
        startDate: _start,
      );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CreateChoreSuccessPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,


      appBar: AppBar(
        title: const Text('Tạo việc nhà mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _loadingMembers
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Tên việc nhà'),
                  _buildTextField(
                    controller: _nameController, 
                    hint: 'Ví dụ: Rửa bát, Đổ rác,...'
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Mô tả (Tùy chọn)'),
                  _buildTextField(
                    controller: _descriptionController, 
                    hint: 'Ví dụ: Rửa sạch bát đũa sau bữa tối...',
                    maxLines: 3
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Ngày thực hiện'),
                            _buildDatePicker(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Khung giờ làm việc'),
                            _buildTimePicker(),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Tần suất lặp lại'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<RepeatFrequency>(
                        value: _frequency,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: RepeatFrequency.values
                            .map((f) => DropdownMenuItem(
                                  value: f,
                                  child: Text(_frequencyLabel(f), style: const TextStyle(fontWeight: FontWeight.w600)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _frequency = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Điểm'),
                  _buildPointsStepper(),
                  const SizedBox(height: 24),


                  _buildRotationSection(),
                  
                  const SizedBox(height: 16),
                  

                  if (!_autoRotate) ...[
                     _buildLabel('Phân công cho'),
                     Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _assignedMemberUid,
                            hint: const Text('Chọn thành viên'),
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: _houseMembers
                                .map((u) => DropdownMenuItem(
                                      value: u.uid,
                                      child: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _assignedMemberUid = v),
                          ),
                        ),
                      ),
                  ],

                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _createChore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.chore != null ? 'Lưu thay đổi' : 'Tạo việc nhà',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF5E6C84))),
    );
  }

  Widget _buildTextField({required TextEditingController controller, String? hint, int maxLines = 1}) {
    return  TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryGreen),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: _start,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (d != null) {
          setState(() {
            _start = DateTime(d.year, d.month, d.day, _start.hour, _start.minute);
            _end = DateTime(d.year, d.month, d.day, _end.hour, _end.minute);
          });
        }
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDate(_start), style: const TextStyle(fontWeight: FontWeight.w600)),
            const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final s = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_start));
        final e = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_end));
        if (s != null && e != null) {
           setState(() {
              _start = DateTime(_start.year, _start.month, _start.day, s.hour, s.minute);
              _end = DateTime(_end.year, _end.month, _end.day, e.hour, e.minute);
           });
        }
      },
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_start.hour}:${_start.minute.toString().padLeft(2,'0')} → ${_end.hour}:${_end.minute.toString().padLeft(2,'0')}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const Icon(Icons.access_time, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepButton(icon: Icons.remove, onTap: () => _changePoints(-1)),
          Text(_points.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          _StepButton(icon: Icons.add, onTap: () => _changePoints(1)),
        ],
      ),
    );
  }

  Widget _buildRotationSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F8ED),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                 child: const Icon(Icons.sync, color: kPrimaryGreen),
               ),
               const SizedBox(width: 12),
               const Expanded(
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text('Tự động xoay vòng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Tự động phân công cho người tiếp theo', style: TextStyle(fontSize: 12, color: kPrimaryGreen)),
                   ],
                 ),
               ),
               Switch(
                 value: _autoRotate,
                 onChanged: (v) => setState(() => _autoRotate = v),
                 activeColor: Colors.black,
                 activeTrackColor: Colors.white,
               ),
            ],
          ),
          
          if (_autoRotate) ...[
            const SizedBox(height: 20),
            const Text('Chọn thành viên tham gia xoay vòng', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            

            ..._houseMembers.map((u) {
              final isChecked = _selectedMembers[u.uid] == true;
              return InkWell(
                onTap: () => _toggleMember(u.uid, !isChecked),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        isChecked ? Icons.check_box : Icons.check_box_outline_blank,
                        color: isChecked ? const Color(0xFF00E676) : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Text(u.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Thứ tự xoay vòng:', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_rotationOrder.length > 1)
                  const Text('(Kéo để sắp xếp)', style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic)),
              ],
            ),
            const SizedBox(height: 8),
            

            if (_rotationOrder.isNotEmpty)
              Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(12),
                 ),
                 child: ReorderableListView(
                   physics: const NeverScrollableScrollPhysics(),
                   shrinkWrap: true,
                   onReorder: (oldIndex, newIndex) {
                     setState(() {
                       if (oldIndex < newIndex) {
                         newIndex -= 1;
                       }
                       final item = _rotationOrder.removeAt(oldIndex);
                       _rotationOrder.insert(newIndex, item);
                     });
                   },
                   children: _rotationOrder.map((uid) {
                     final user = _houseMembers.firstWhere((u) => u.uid == uid, orElse: () => UserModel(
                            uid: uid,
                            name: 'Unknown',
                            email: '',
                            phoneNumber: '',
                            avatarUrl: '',
                            createdAt: DateTime.now(),
                          ));
                     return ListTile(
                       key: ValueKey(uid),
                       leading: CircleAvatar(
                          backgroundImage: user.avatarUrl.isNotEmpty ? AssetImage(user.avatarUrl) : const AssetImage('lib/core/assets/avatars/meo3.jpg') as ImageProvider,
                          radius: 16,
                       ),
                       title: Text(user.name),
                       trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                       dense: true,
                       contentPadding: EdgeInsets.zero,
                     );
                   }).toList(),
                 ),
              ),
              
            const SizedBox(height: 8),
            if (_rotationOrder.isNotEmpty)
               Wrap(
                 spacing: 4,
                 crossAxisAlignment: WrapCrossAlignment.center,
                  children: _rotationOrder.asMap().entries.map((entry) {
                     final uid = entry.value;
                     final isLast = entry.key == _rotationOrder.length - 1;
                     final user = _houseMembers.firstWhere((u) => u.uid == uid, orElse: () => UserModel(
                             uid: uid,
                             name: '?',
                             email: '',
                             phoneNumber: '',
                             avatarUrl: '',
                             createdAt: DateTime.now(),
                           ));
                     return Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                         if (!isLast) const Icon(Icons.arrow_right_alt, size: 16, color: Colors.grey),
                       ],
                     );
                  }).toList(),
               ),
          ],
        ],
      ),
    );
  }

  String _frequencyLabel(RepeatFrequency f) {
    switch (f) {
      case RepeatFrequency.none: return 'Không lặp lại';
      case RepeatFrequency.daily: return 'Hàng ngày';
      case RepeatFrequency.monthly: return 'Hàng tháng';
      case RepeatFrequency.yearly: return 'Hàng năm';
    }
  }



}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFC8E6C9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: kPrimaryGreen),
      ),
    );
  }
}

// Code cleanup
