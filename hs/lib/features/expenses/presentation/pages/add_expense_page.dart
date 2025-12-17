import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';

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

  // --- LOGIC TÍNH TOÁN ---
  
  // Hàm điều phối chung: Kiểm tra đang ở tab nào để tính toán theo tab đó
  void _recalculateSplit() {
    if (_splitTypeIndex == 1) {
      _calculatePercentSplit();
    } else if (_splitTypeIndex == 2) {
      _calculateAmountSplit();
    }
    // Tab 0 (Chia đều) không cần tính số liệu cụ thể, chỉ cần trạng thái isSelected là đủ
  }

  // 1. Logic Chia %
  void _calculatePercentSplit() {
    List<Map<String, dynamic>> selectedMembers = members.where((m) => m['isSelected'] == true).toList();
    
    if (selectedMembers.isEmpty) {
      for (var m in members) m['percentage'] = 0;
      return;
    }

    int count = selectedMembers.length;
    int basePercent = (100 / count).floor(); 
    int remainder = 100 - (basePercent * count); 

    for (var m in members) {
      if (m['isSelected'] == true) {
        m['percentage'] = basePercent;
      } else {
        m['percentage'] = 0;
      }
    }
    // Cộng phần lẻ vào người đầu tiên được chọn
    if (selectedMembers.isNotEmpty) {
      selectedMembers[0]['percentage'] = (selectedMembers[0]['percentage'] as int) + remainder;
    }
  }

  // 2. Logic Chia SỐ TIỀN
  void _calculateAmountSplit() {
    int totalAmount = int.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    List<Map<String, dynamic>> selectedMembers = members.where((m) => m['isSelected'] == true).toList();

    if (selectedMembers.isEmpty) {
      for (var m in members) m['fixedAmount'] = 0;
      return;
    }

    int count = selectedMembers.length;
    int baseAmount = (totalAmount / count).floor();
    int remainder = totalAmount - (baseAmount * count);

    for (var m in members) {
      if (m['isSelected'] == true) {
        m['fixedAmount'] = baseAmount;
      } else {
        m['fixedAmount'] = 0;
      }
    }
    if (selectedMembers.isNotEmpty) {
      selectedMembers[0]['fixedAmount'] = (selectedMembers[0]['fixedAmount'] as int) + remainder;
    }
  }

  // --- POPUP DIALOGS ---

  // 1. Popup nhập % (ĐÃ BỎ CHECKBOX)
  void _showPercentageDialog() {
    // Chỉ lấy những người đã chọn ở màn hình chính
    List<Map<String, dynamic>> activeMembers = members.where((m) => m['isSelected'] == true).toList();
    
    if (activeMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn người tham gia trước!")));
      return;
    }

    // Tính toán lại lần đầu để đảm bảo số liệu đúng trước khi mở popup cho người dùng sửa
    _calculatePercentSplit();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int totalPercent = activeMembers.fold(0, (sum, item) => sum + (item['percentage'] as int));

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Chia theo tỷ lệ %", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Tổng cộng: $totalPercent%", style: TextStyle(fontWeight: FontWeight.bold, color: totalPercent == 100 ? AppColors.primary : Colors.red)),
                    const SizedBox(height: 16),
                    // Duyệt danh sách activeMembers (không cần hiện checkbox nữa)
                    ...activeMembers.map((member) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          // Avatar + Tên
                          CircleAvatar(backgroundImage: NetworkImage(member['avatar']), radius: 14),
                          const SizedBox(width: 8),
                          Expanded(child: Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                          
                          // Ô nhập liệu
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              key: ValueKey(member['percentage']),
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
              ),
              actions: [
                TextButton(
                  onPressed: () { Navigator.pop(context); }, 
                  child: const Text("Hủy", style: TextStyle(color: Colors.grey))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    if (totalPercent == 100) {
                      setState(() {});
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

  // 2. Popup nhập Số tiền (ĐÃ BỎ CHECKBOX)
  void _showAmountDialog() {
    List<Map<String, dynamic>> activeMembers = members.where((m) => m['isSelected'] == true).toList();
    
    if (activeMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn người tham gia trước!")));
      return;
    }
    
    int inputTotalAmount = int.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    _calculateAmountSplit(); // Tính lại phân bổ tiền tự động

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int currentTotal = activeMembers.fold(0, (sum, item) => sum + (item['fixedAmount'] as int));

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Chia theo số tiền", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Tổng cộng: ${currentTotal}đ", style: TextStyle(fontWeight: FontWeight.bold, color: currentTotal == inputTotalAmount ? AppColors.primary : Colors.red)),
                    const SizedBox(height: 16),
                    
                    ...activeMembers.map((member) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(backgroundImage: NetworkImage(member['avatar']), radius: 14),
                          const SizedBox(width: 8),
                          Expanded(child: Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                          
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              key: ValueKey(member['fixedAmount']),
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
              ),
              actions: [
                TextButton(
                  onPressed: () { Navigator.pop(context); }, 
                  child: const Text("Hủy", style: TextStyle(color: Colors.grey))
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                      if (currentTotal == inputTotalAmount) {
                         setState(() {});
                         Navigator.pop(context);
                      } else {
                         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tổng phải khớp với số tiền đã nhập")));
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)), child: child!),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
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
            // Cập nhật: Thêm onChanged để khi sửa tổng tiền, các phần chia cũng tự cập nhật
            _buildTextField(controller: _amountController, hint: "0", suffix: "VND", isNumber: true, onChanged: (val) {
               if (_splitTypeIndex == 2) setState(() { _calculateAmountSplit(); });
            }),
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
            
            // --- DANH SÁCH THÀNH VIÊN (CHO PHÉP TÍCH CHỌN TRỰC TIẾP) ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel("Ai tham gia khoản chi"),
                GestureDetector(
                  onTap: () {
                     // Nút chọn tất cả nhanh
                     setState(() {
                       bool allSelected = members.every((m) => m['isSelected']);
                       for (var m in members) m['isSelected'] = !allSelected;
                       _recalculateSplit(); // Tính lại ngay sau khi chọn tất cả
                     });
                  },
                  child: const Text("Chọn tất cả", style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: members.map((member) {
                  // KHÔNG CÒN AbsorbPointer -> Cho phép click
                  return CheckboxListTile(
                    activeColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.trailing,
                    title: Row(children: [
                      Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      // Hiển thị kết quả tính toán ngay tại đây
                      if (_splitTypeIndex == 1 && member['isSelected']) 
                        Text("${member['percentage']}%", style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                      if (_splitTypeIndex == 2 && member['isSelected']) 
                        Text("${member['fixedAmount']}đ", style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                    ]),
                    secondary: CircleAvatar(backgroundImage: NetworkImage(member['avatar'])),
                    value: member['isSelected'],
                    onChanged: (val) {
                       setState(() {
                         member['isSelected'] = val ?? false;
                         // QUAN TRỌNG: Tích xong thì tính lại tiền ngay
                         _recalculateSplit();
                       });
                    }, 
                  );
                }).toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // --- CÁCH CHIA TIỀN (TAB DƯỚI CÙNG) ---
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
                        setState(() {
                           _splitTypeIndex = index;
                           _recalculateSplit(); // Chuyển tab thì tính lại theo tab đó
                        });
                        // Nếu chuyển sang tab % hoặc tiền thì mở popup để chỉnh chi tiết
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

            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: (){ Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Lưu khoản chi", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 2, isSubPage: true),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textBlack)));
  
  // Update: Thêm hàm onChanged để bắt sự kiện nhập tiền
  Widget _buildTextField({required TextEditingController? controller, required String hint, String? suffix, bool isNumber = false, Function(String)? onChanged}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), 
      child: TextField(
        controller: controller, 
        keyboardType: isNumber ? TextInputType.number : TextInputType.text, 
        onChanged: onChanged, // Gắn hàm onChanged vào đây
        decoration: InputDecoration(hintText: hint, suffixText: suffix, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))
      )
    );
  }
}