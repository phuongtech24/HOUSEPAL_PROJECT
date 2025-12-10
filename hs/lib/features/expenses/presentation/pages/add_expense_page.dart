import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  // State quản lý tab chia tiền
  int _splitTypeIndex = 0; // 0: Chia đều, 1: Theo %, 2: Số tiền
  final List<String> splitTypes = ["Chia đều", "Theo %", "Số tiền"];
  
  final TextEditingController _amountController = TextEditingController();
  
  // Dữ liệu giả lập thành viên
  final List<Map<String, dynamic>> members = [
    {"name": "Văn Dũng", "avatar": "https://i.pravatar.cc/150?img=11", "isSelected": true, "percentage": 0, "fixedAmount": 0},
    {"name": "Nam Phương", "avatar": "https://i.pravatar.cc/150?img=12", "isSelected": true, "percentage": 0, "fixedAmount": 0},
    {"name": "Minh Tuấn", "avatar": "https://i.pravatar.cc/150?img=13", "isSelected": true, "percentage": 0, "fixedAmount": 0},
  ];

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedCategory = "Đi chợ";
  String selectedPayer = "Nam Phương";
  final List<String> payers = ["Nam Phương", "Văn Dũng", "Minh Tuấn"];

  // --- LOGIC POPUP ---

  // 1. Popup nhập %
  void _showPercentageDialog() {
    List<Map<String, dynamic>> selectedMembers = members.where((m) => m['isSelected'] == true).toList();
    if (selectedMembers.isEmpty) return;

    // Reset chia đều %
    int defaultPercent = (100 / selectedMembers.length).floor();
    for (var m in selectedMembers) { m['percentage'] = defaultPercent; }
    selectedMembers[0]['percentage'] += (100 - (defaultPercent * selectedMembers.length));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int totalPercent = selectedMembers.fold(0, (sum, item) => sum + (item['percentage'] as int));
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Chia theo tỷ lệ %", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Tổng cộng: $totalPercent%", style: TextStyle(fontWeight: FontWeight.bold, color: totalPercent == 100 ? AppColors.primary : Colors.red)),
                  const SizedBox(height: 16),
                  ...selectedMembers.map((member) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(child: Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            initialValue: member['percentage'].toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              suffixText: "%",
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (val) {
                              setDialogState(() {
                                member['percentage'] = int.tryParse(val) ?? 0;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  )),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() => _splitTypeIndex = 0); // Quay về mặc định nếu hủy
                    Navigator.pop(context);
                  }, 
                  child: const Text("Hủy", style: TextStyle(color: Colors.grey))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                    if (totalPercent == 100) {
                      setState(() {}); // Cập nhật UI chính để hiện kết quả
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tổng phải bằng 100%")));
                    }
                  },
                  child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 2. Popup nhập Số tiền cụ thể
  void _showAmountDialog() {
    List<Map<String, dynamic>> selectedMembers = members.where((m) => m['isSelected'] == true).toList();
    if (selectedMembers.isEmpty) return;
    
    double totalAmount = double.tryParse(_amountController.text) ?? 0;
    // Chia đều ban đầu
    double defaultSplit = (totalAmount / selectedMembers.length);
    for (var m in selectedMembers) { m['fixedAmount'] = defaultSplit.toInt(); }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int currentTotal = selectedMembers.fold(0, (sum, item) => sum + (item['fixedAmount'] as int));
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Chia theo số tiền", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Tổng cộng: ${currentTotal}đ", style: TextStyle(fontWeight: FontWeight.bold, color: currentTotal == totalAmount.toInt() ? AppColors.primary : Colors.red)),
                  const SizedBox(height: 16),
                  ...selectedMembers.map((member) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(child: Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            initialValue: member['fixedAmount'].toString(),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onChanged: (val) {
                              setDialogState(() {
                                member['fixedAmount'] = int.tryParse(val) ?? 0;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                  )),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() => _splitTypeIndex = 0);
                    Navigator.pop(context);
                  }, 
                  child: const Text("Hủy", style: TextStyle(color: Colors.grey))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () {
                     setState(() {});
                     Navigator.pop(context);
                  },
                  child: const Text("Xác nhận", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)), child: child!),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text("Thêm khoản chi", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Tên khoản chi"),
            _buildTextField(controller: null, hint: "Ví dụ: Trả tiền nước tháng 10"),
            const SizedBox(height: 16),
            _buildLabel("Số tiền"),
            _buildTextField(controller: _amountController, hint: "0", suffix: "VND", isNumber: true),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Ngày chi"), GestureDetector(onTap: () => _selectDate(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}", style: const TextStyle(fontSize: 13)), const Icon(Icons.calendar_today, size: 16, color: Colors.grey)])))])),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel("Người trả"), Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: selectedPayer, isExpanded: true, icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey), style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold), onChanged: (String? v) => setState(() => selectedPayer = v!), items: payers.map((String v) => DropdownMenuItem(value: v, child: Text(v))).toList())))])),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel("Loại chi tiêu"),
            Wrap(spacing: 8, children: ["Điện nước", "Internet", "Tiền nhà", "Đi chợ"].map((c) => ChoiceChip(label: Text(c), selected: selectedCategory==c, onSelected: (v)=>setState(()=>selectedCategory=c), selectedColor: AppColors.creditGreen, backgroundColor: Colors.white)).toList()),
            const SizedBox(height: 16),
            
            // --- GIAO DIỆN TAB CHIA TIỀN ---
            _buildLabel("Cách chia tiền"),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: List.generate(splitTypes.length, (index) {
                  bool isSelected = _splitTypeIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _splitTypeIndex = index);
                        if (index == 1) _showPercentageDialog();
                        if (index == 2) _showAmountDialog();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)] : [],
                        ),
                        child: Text(splitTypes[index], textAlign: TextAlign.center, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: Colors.black)),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            
            // Danh sách người tham gia (Hiển thị kết quả chia tiền)
            _buildLabel("Ai tham gia khoản chi"),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: members.map((member) {
                  return CheckboxListTile(
                    activeColor: AppColors.primary,
                    title: Row(children: [
                      Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (_splitTypeIndex == 1 && member['isSelected']) Text("${member['percentage']}%", style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                      if (_splitTypeIndex == 2 && member['isSelected']) Text("${member['fixedAmount']}đ", style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                    ]),
                    secondary: CircleAvatar(backgroundImage: NetworkImage(member['avatar'])),
                    value: member['isSelected'],
                    onChanged: (val) => setState(() => member['isSelected'] = val),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: (){ Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Lưu khoản chi", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 2,
        onTap: (index) { if(index==2) Navigator.pop(context); },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Trang chủ"),
          BottomNavigationBarItem(icon: Icon(Icons.cleaning_services_outlined), label: "Việc nhà"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: "Quỹ chung"),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: "Bảng tin"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Hồ sơ"),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textBlack)));
  
  Widget _buildTextField({required TextEditingController? controller, required String hint, String? suffix, bool isNumber = false}) {
    return Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: TextField(controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, decoration: InputDecoration(hintText: hint, suffixText: suffix, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))));
  }
}