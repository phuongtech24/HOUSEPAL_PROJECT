import 'package:flutter/material.dart';
import '../widgets/chore_widgets.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';

enum RepeatFrequency { none, daily, monthly, yearly }

class CreateChorePage extends StatefulWidget {
  const CreateChorePage({super.key});

  @override
  State<CreateChorePage> createState() => _CreateChorePageState();
}

class _CreateChorePageState extends State<CreateChorePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _start = DateTime(2025, 11, 28, 9, 0);
  DateTime _end = DateTime(2025, 11, 28, 16, 0);
  RepeatFrequency _frequency = RepeatFrequency.none;
  int _points = 10;
  bool _autoRotate = false;

  final Map<String, bool> _members = {
    'Bạn': true,
    'Nam Phương': false,
    'Minh Tuấn': false,
  };

  String? _assignedMember;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    final String day = dt.day.toString().padLeft(2, '0');
    final String month = dt.month.toString().padLeft(2, '0');
    final String year = dt.year.toString();
    final String hour = dt.hour.toString().padLeft(2, '0');
    final String minute = dt.minute.toString().padLeft(2, '0');
    return '$day/$month/$year  $hour:$minute';
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

  Future<void> _pickStart() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) {
      return;
    }

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (time == null) {
      return;
    }

    setState(() {
      _start = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickEnd() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null) {
      return;
    }

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_end),
    );
    if (time == null) {
      return;
    }

    setState(() {
      _end = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _changePoints(int delta) {
    setState(() {
      _points = (_points + delta).clamp(0, 999);
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
          color: Colors.black87,
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: const Text(
          'Tạo việc nhà mới',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        children: [
          _InputCard(
            label: 'Tên việc nhà',
            child: TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Rửa bát, Đổ rác,...',
                hintStyle: TextStyle(color: kGreyText, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InputCard(
            label: 'Mô tả (Tùy chọn)',
            child: TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Vệ sinh tủ lạnh sau bữa trưa...',
                hintStyle: TextStyle(color: kGreyText, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InputCard(
                  label: 'Ngày bắt đầu',
                  child: _DateField(
                    text: _formatDateTime(_start),
                    onTap: _pickStart,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputCard(
                  label: 'Ngày kết thúc',
                  child: _DateField(
                    text: _formatDateTime(_end),
                    onTap: _pickEnd,
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
                icon: const Icon(Icons.expand_more, color: kGreyText),
                style: const TextStyle(fontSize: 14, color: Colors.black),
                items: RepeatFrequency.values
                    .map(
                      (f) => DropdownMenuItem(
                        value: f,
                        child: Text(_frequencyLabel(f)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _frequency = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InputCard(
            label: 'Điểm',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepButton(icon: Icons.remove, onTap: () => _changePoints(-1)),
                const SizedBox(width: 24),
                Text(
                  '$_points',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 24),
                _StepButton(icon: Icons.add, onTap: () => _changePoints(1)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEAFBF3),
              borderRadius: kCardRadius,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sync, color: kPrimaryGreen),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Tự động xoay vòng',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Switch(
                      value: _autoRotate,
                      activeColor: Colors.white,
                      activeTrackColor: kPrimaryGreen,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFD5E5DA),
                      onChanged: (value) {
                        setState(() {
                          _autoRotate = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tự động phân công cho người tiếp theo sau mỗi chu kỳ',
                  style: TextStyle(fontSize: 13, color: kGreyText),
                ),
                const SizedBox(height: 12),
                if (_autoRotate) ...[
                  const Text(
                    'Chọn thành viên tham gia xoay vòng',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _members.keys.map((name) {
                      final bool checked = _members[name]!;
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        visualDensity: const VisualDensity(
                          horizontal: -4,
                          vertical: -4,
                        ),
                        value: checked,
                        onChanged: (value) {
                          setState(() {
                            _members[name] = value ?? false;
                          });
                        },
                        title: Text(name, style: const TextStyle(fontSize: 14)),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: kPrimaryGreen,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Thứ tự xoay vòng:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(orderText, style: const TextStyle(fontSize: 14)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _InputCard(
            label: 'Phân công cho',
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _assignedMember,
                isExpanded: true,
                hint: const Text(
                  'Chọn thành viên',
                  style: TextStyle(fontSize: 14, color: kGreyText),
                ),
                icon: const Icon(Icons.expand_more, color: kGreyText),
                style: const TextStyle(fontSize: 14, color: Colors.black),
                items: _members.keys
                    .map(
                      (name) => DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _assignedMember = value;
                  });
                },
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
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () {},
              child: const Text('Tạo việc nhà'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 1),
    );
  }

  String _buildOrderText() {
    final List<String> selected = _members.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (selected.isEmpty) {
      return 'Chưa chọn thành viên';
    }
    return selected.join(' ➝ ');
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4A4A),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: kCardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE3E5EA)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: child,
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.calendar_today_outlined, size: 18, color: kGreyText),
        ],
      ),
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
