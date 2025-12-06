import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  // --- STATE VARIABLES ---
  String selectedCategory = "Đi chợ";
  String splitType = "Chia đều";
  
  // 1. Quản lý ngày tháng
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // 2. Quản lý người trả tiền (Dropdown)
  final List<String> payers = ["Nam Phương", "Văn Dũng", "Minh Tuấn"];
  String selectedPayer = "Nam Phương"; // Giá trị mặc định

  // Danh sách thành viên (Thêm trường percentage để lưu %)
  final List<Map<String, dynamic>> members = [
    {"name": "Văn Dũng", "avatar": "https://i.pravatar.cc/150?img=11", "isSelected": true, "percentage": 0},
    {"name": "Nam Phương", "avatar": "https://i.pravatar.cc/150?img=12", "isSelected": true, "percentage": 0},
    {"name": "Minh Tuấn", "avatar": "https://i.pravatar.cc/150?img=13", "isSelected": true, "percentage": 0},
  ];

  // --- LOGIC FUNCTIONS ---

  // Hàm chọn ngày
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Hàm hiển thị Popup nhập %
  void _showPercentageDialog() {
    // Lọc ra những người được chọn
    List<Map<String, dynamic>> selectedMembers = members.where((m) => m['isSelected'] == true).toList();
    
    if (selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng chọn ít nhất 1 người tham gia!")));
      return;
    }

    // Tự động chia đều % ban đầu cho đỡ phải nhập nhiều
    int defaultPercent = (100 / selectedMembers.length).floor();
    for (var m in selectedMembers) {
      m['percentage'] = defaultPercent;
    }
    // Cộng phần dư vào người đầu tiên cho đủ 100%
    selectedMembers[0]['percentage'] += (100 - (defaultPercent * selectedMembers.length));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Dùng StatefulBuilder để update UI trong Dialog
          builder: (context, setDialogState) {
            int totalPercent = selectedMembers.fold(0, (sum, item) => sum + (item['percentage'] as int));

            return AlertDialog(
              title: const Text("Chia theo tỷ lệ %"),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Tổng cộng: $totalPercent%", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: totalPercent == 100 ? Colors.green : Colors.red
                      )
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: selectedMembers.length,
                      itemBuilder: (context, index) {
                        var member = selectedMembers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Text(member['name']),
                              const Spacer(),
                              SizedBox(
                                width: 60,
                                child: TextFormField(
                                  initialValue: member['percentage'].toString(),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    suffixText: "%",
                                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setDialogState(() {
                                      member['percentage'] = int.tryParse(value) ?? 0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    if (totalPercent != 100) {
                      // Báo lỗi nếu chưa đủ 100%
                      ScaffoldMessenger.of(context).showSnackBar(
                         const SnackBar(content: Text("Tổng tỷ lệ phải bằng 100%"))
                      );
                    } else {
                      // Lưu và đóng
                      setState(() {
                        splitType = "Theo %";
                      });
                      Navigator.pop(context);
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

  // Hàm xử lý Lưu khoản chi
  void _handleSaveExpense() {
    // 1. Logic lưu vào Database (Firebase) sẽ viết ở đây
    
    // 2. Hiển thị thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Lưu khoản chi thành công!"),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    // 3. Đóng màn hình sau 1 giây
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Thêm khoản chi", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tên khoản chi
            _buildLabel("Tên khoản chi"),
            _buildTextField(hint: "Ví dụ: Trả tiền nước tháng 10"),
            
            const SizedBox(height: 16),

            // 2. Số tiền
            _buildLabel("Số tiền"),
            _buildTextField(hint: "0", suffix: "VND", isNumber: true),

            const SizedBox(height: 16),

            // 3. Ngày chi & Người trả (2 cột)
            Row(
              children: [
                // CỘT 1: NGÀY CHI (ĐÃ SỬA: Bấm vào hiện lịch)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Ngày chi"),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}", 
                                style: const TextStyle(fontSize: 13)
                              ),
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                // CỘT 2: NGƯỜI TRẢ (ĐÃ SỬA: Dropdown 3 người)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Người trả"),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPayer,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                            style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedPayer = newValue!;
                              });
                            },
                            items: payers.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4. Loại chi tiêu
            _buildLabel("Loại chi tiêu"),
            Wrap(
              spacing: 8,
              children: ["Điện nước", "Internet", "Tiền nhà", "Đi chợ", "Đồ dùng chung", "Khác"]
                  .map((category) => ChoiceChip(
                        label: Text(category),
                        selected: selectedCategory == category,
                        selectedColor: AppColors.creditGreen,
                        backgroundColor: Colors.white,
                        onSelected: (bool selected) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                      ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // 5. Ai tham gia
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel("Ai tham gia khoản chi"),
                GestureDetector(
                   onTap: () {
                     // Nếu chọn tắt cả -> Bỏ chọn hết
                     // Bạn có thể tùy biến logic này
                   },
                   child: const Text("Chọn tất cả", style: TextStyle(color: AppColors.primary, fontSize: 12))
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: members.map((member) {
                  return CheckboxListTile(
                    activeColor: AppColors.primary,
                    title: Row(
                      children: [
                        Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (splitType == "Theo %" && member['isSelected'])
                           Text(" (${member['percentage']}%)", style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold))
                      ],
                    ),
                    secondary: CircleAvatar(backgroundImage: NetworkImage(member['avatar'])),
                    value: member['isSelected'],
                    onChanged: (val) {
                      setState(() {
                        member['isSelected'] = val;
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // 6. Cách chia tiền (ĐÃ SỬA: Xử lý Popup khi chọn %)
            _buildLabel("Cách chia tiền"),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: ["Chia đều", "Theo %", "Số tiền"].map((type) {
                  bool isSelected = splitType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (type == "Theo %") {
                          _showPercentageDialog();
                        } else {
                          setState(() => splitType = type);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)] : [],
                        ),
                        child: Text(
                          type,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // 7. Ghi chú & Ảnh
            _buildLabel("Ghi chú (Tùy chọn)"),
            Container(
              height: 100,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
              child: const TextField(
                maxLines: null,
                decoration: InputDecoration.collapsed(hintText: "Thêm ghi chú cho khoản chi...", hintStyle: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
              ),
              child: const Column(
                children: [
                  Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
                  SizedBox(height: 4),
                  Text("Thêm ảnh", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Nút Lưu (ĐÃ SỬA: Thêm thông báo thành công)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSaveExpense,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("Lưu khoản chi", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textBlack)),
    );
  }

  Widget _buildTextField({required String hint, String? suffix, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          suffixText: suffix,
          suffixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}