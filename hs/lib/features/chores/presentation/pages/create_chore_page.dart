import 'package:flutter/material.dart';
import '../widgets/chore_widgets.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';
import 'create_chore_success_page.dart';


enum RepeatFrequency { none, daily, monthly, yearly }

class CreateChorePage extends StatefulWidget {
  const CreateChorePage({super.key});

  @override
  State<CreateChorePage> createState() => _CreateChorePageState();
}

class _CreateChorePageState extends State<CreateChorePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController(
    text: '0',
  );

  DateTime _start = DateTime(2025, 11, 28, 9, 0);
  DateTime _end = DateTime(2025, 11, 28, 18, 0);

  RepeatFrequency _frequency = RepeatFrequency.none;
  int _points = 0;
  bool _autoRotate = false;

  final Map<String, bool> _members = {
    'Bạn': true,
    'Nam Phương': true,
    'Minh Tuấn': true,
  };

  String? _assignedMember;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  String _formatDateOnly(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatTimeOnly(DateTime start, DateTime end) {
    final s = '${start.hour}:${start.minute.toString().padLeft(2, '0')}';
    final e = '${end.hour}:${end.minute.toString().padLeft(2, '0')}';
    return '$s → $e';
  }

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

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    setState(() {
      _start = DateTime(
        date.year,
        date.month,
        date.day,
        _start.hour,
        _start.minute,
      );
      _end = DateTime(date.year, date.month, date.day, _end.hour, _end.minute);
    });
  }

  Future<void> _pickTimeRange() async {
    final startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (startTime == null) return;

    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_end),
    );
    if (endTime == null) return;

    setState(() {
      _start = DateTime(
        _start.year,
        _start.month,
        _start.day,
        startTime.hour,
        startTime.minute,
      );
      _end = DateTime(
        _end.year,
        _end.month,
        _end.day,
        endTime.hour,
        endTime.minute,
      );
    });
  }

  void _changePoints(int delta) {
    setState(() {
      _points = (_points + delta).clamp(0, 999);
      _pointsController.text = _points.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String orderText = _buildOrderText();

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          _InputCard(
            label: 'Tên việc nhà',
            child: TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Rửa bát, Đổ rác,...',
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
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Rửa sạch bát đũa sau bữa tối...',
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _InputCard(
                  label: 'Ngày thực hiện',
                  child: InkWell(
                    onTap: _pickDate,
                    child: Row(
                      children: [
                        Expanded(child: Text(_formatDateOnly(_start))),
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: kGreyText,
                        ),
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
                    onTap: _pickTimeRange,
                    child: Row(
                      children: [
                        Expanded(child: Text(_formatTimeOnly(_start, _end))),
                        const Icon(
                          Icons.access_time,
                          size: 18,
                          color: kGreyText,
                        ),
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
                    .map(
                      (f) => DropdownMenuItem(
                        value: f,
                        child: Text(_frequencyLabel(f)),
                      ),
                    )
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
                _StepButton(icon: Icons.remove, onTap: () => _changePoints(-1)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _pointsController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: const InputDecoration(border: InputBorder.none),
                    onChanged: (value) {
                      final int? parsed = int.tryParse(value);
                      setState(() {
                        _points = parsed?.clamp(0, 999) ?? 0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                _StepButton(icon: Icons.add, onTap: () => _changePoints(1)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEAFBF3),
              borderRadius: kCardRadius,
              border: Border.all(
                color: _autoRotate ? kPrimaryGreen : Colors.transparent,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sync, color: kPrimaryGreen),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tự động xoay vòng',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tự động phân công cho người tiếp theo sau mỗi chu kỳ',
                            style: TextStyle(fontSize: 13, color: kGreyText),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _autoRotate,
                      activeTrackColor: kPrimaryGreen,
                      onChanged: (v) => setState(() => _autoRotate = v),
                    ),
                  ],
                ),

                if (_autoRotate) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Chọn thành viên tham gia xoay vòng',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ..._members.keys.map((name) {
                    return CheckboxListTile(
                      value: _members[name],
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) =>
                          setState(() => _members[name] = v ?? false),
                      title: Text(name),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: kPrimaryGreen,
                    );
                  }),
                  const SizedBox(height: 12),
                  const Text(
                    'Thứ tự xoay vòng:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(orderText),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ẨN PHÂN CÔNG KHI AUTO ROTATE = TRUE
          if (!_autoRotate)
            _InputCard(
              label: 'Phân công cho',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _assignedMember,
                  isExpanded: true,
                  hint: const Text('Chọn thành viên'),
                  items: _members.keys
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (v) => setState(() => _assignedMember = v),
                ),
              ),
            ),

          const SizedBox(height: 20),

          SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateChoreSuccessPage(),
                  ),
                );
              },
              child: const Text(
                'Tạo việc nhà',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 1),
    );
  }

  String _buildOrderText() {
    final selected = _members.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    return selected.isEmpty ? 'Chưa chọn thành viên' : selected.join(' ➝ ');
  }
}

class _InputCard extends StatelessWidget {
  const _InputCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: kCardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE3E5EA)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
