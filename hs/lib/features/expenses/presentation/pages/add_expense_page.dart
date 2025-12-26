import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Để dùng FilteringTextInputFormatter
import 'package:hs/features/expenses/data/datasources/ExpenseService.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart'; // Chú ý đường dẫn import

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final ExpenseService _expenseService = ExpenseService();
  
  // State quản lý tab chia tiền
  int _splitTypeIndex = 0; // 0: Chia đều, 1: Theo %, 2: Số tiền
  final List<String> splitTypes = ["Chia đều", "Theo %", "Số tiền"];

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(); // Thêm controller cho tiêu đề

  // Dữ liệu thành viên (Sẽ load từ Firebase)
  List<Map<String, dynamic>> members = [];
  bool _isLoadingMembers = true;
  bool _isSaving = false;

  DateTime selectedDate = DateTime.now();
  String selectedCategory = "Đi chợ";
  String? selectedPayerId; // Lưu UID người trả

  @override
  void initState() {
    super.initState();
    _fetchHouseMembers();
  }

  // 1. LẤY DANH SÁCH THÀNH VIÊN TỪ FIREBASE
  Future<void> _fetchHouseMembers() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final houseId = userDoc['houseId'];

      if (houseId != null && houseId.isNotEmpty) {
        final houseDoc = await FirebaseFirestore.instance.collection('houses').doc(houseId).get();
        final List<dynamic> memberIds = houseDoc['members'];

        List<Map<String, dynamic>> loadedMembers = [];
        for (String uid in memberIds) {
          final memDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
          if (memDoc.exists) {
            loadedMembers.add({
              "uid": uid,
              "name": memDoc['name'] ?? 'Thành viên',
              "avatar": memDoc['avatarUrl'] ?? '', // Nếu rỗng sẽ xử lý UI sau
              "isSelected": true, // Mặc định chọn hết
              "percentage": 0,
              "fixedAmount": 0,
            });
          }
        }

        if (mounted) {
          setState(() {
            members = loadedMembers;
            selectedPayerId = user.uid; // Mặc định mình là người trả
            _isLoadingMembers = false;
          });
        }
      }
    } catch (e) {
      print("Lỗi load members: $e");
      setState(() => _isLoadingMembers = false);
    }
  }

  // --- LOGIC TÍNH TOÁN (Giữ nguyên logic của bạn, chỉ chỉnh sửa nhỏ) ---
  void _recalculateSplit() {
    if (_splitTypeIndex == 1) {
      _calculatePercentSplit();
    } else if (_splitTypeIndex == 2) {
      _calculateAmountSplit();
    }
  }

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
    if (selectedMembers.isNotEmpty) {
      selectedMembers[0]['percentage'] = (selectedMembers[0]['percentage'] as int) + remainder;
    }
  }

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

  // --- XỬ LÝ LƯU (SAVE) ---
  Future<void> _handleSave() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập tên khoản chi")));
      return;
    }
    double totalAmount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập số tiền")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 1. Chuẩn bị Map splitDetails
      Map<String, double> splitDetails = {};
      List<Map<String, dynamic>> selectedMembers = members.where((m) => m['isSelected'] == true).toList();

      if (selectedMembers.isEmpty) throw Exception("Phải chọn ít nhất 1 người");

      if (_splitTypeIndex == 0) {
        // CHIA ĐỀU
        double share = totalAmount / selectedMembers.length;
        for (var m in selectedMembers) {
          splitDetails[m['uid']] = share;
        }
      } else if (_splitTypeIndex == 1) {
        // THEO %
        for (var m in selectedMembers) {
          double share = totalAmount * (m['percentage'] / 100);
          splitDetails[m['uid']] = share;
        }
      } else {
        // SỐ TIỀN CỤ THỂ
        for (var m in selectedMembers) {
          splitDetails[m['uid']] = (m['fixedAmount'] as int).toDouble();
        }
      }

      // 2. Gọi Service
      await _expenseService.addExpense(
        title: _titleController.text.trim(),
        amount: totalAmount,
        category: selectedCategory,
        payerId: selectedPayerId ?? FirebaseAuth.instance.currentUser!.uid,
        splitType: _splitTypeIndex == 0 ? 'equal' : (_splitTypeIndex == 1 ? 'percent' : 'exact'),
        splitDetails: splitDetails,
        date: selectedDate,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã lưu thành công!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- CÁC POPUP DIALOG (GIỮ NGUYÊN CODE CỦA BẠN, CHỈ SỬA DATA) ---
  void _showPercentageDialog() {
    List<Map<String, dynamic>> activeMembers = members.where((m) => m['isSelected'] == true).toList();
    if (activeMembers.isEmpty) return;
    _calculatePercentSplit(); // Reset về mặc định trước khi sửa

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int totalPercent = activeMembers.fold(0, (sum, item) => sum + (item['percentage'] as int));
            return AlertDialog(
              title: const Text("Chia theo tỷ lệ %", style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Tổng cộng: $totalPercent%", 
                      style: TextStyle(fontWeight: FontWeight.bold, color: totalPercent == 100 ? AppColors.primary : Colors.red)),
                    const SizedBox(height: 16),
                    ...activeMembers.map((member) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: (member['avatar'] != '') ? NetworkImage(member['avatar']) : null,
                            child: (member['avatar'] == '') ? const Icon(Icons.person) : null,
                            radius: 14,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 80,
                            child: TextFormField(
                              initialValue: member['percentage'].toString(),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(suffixText: "%", contentPadding: const EdgeInsets.all(8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                              onChanged: (val) {
                                setDialogState(() {
                                  member['percentage'] = int.tryParse(val) ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    if (totalPercent == 100) {
                      setState(() {}); // Update màn hình chính
                      Navigator.pop(context);
                    } else {
                      // Thông báo lỗi nhỏ
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

  void _showAmountDialog() {
    List<Map<String, dynamic>> activeMembers = members.where((m) => m['isSelected'] == true).toList();
    if (activeMembers.isEmpty) return;
    int inputTotalAmount = int.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    _calculateAmountSplit(); // Reset

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            int currentTotal = activeMembers.fold(0, (sum, item) => sum + (item['fixedAmount'] as int));
            return AlertDialog(
              title: const Text("Chia theo số tiền", style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Tổng: $currentTotal đ / $inputTotalAmount đ", 
                      style: TextStyle(fontWeight: FontWeight.bold, color: currentTotal == inputTotalAmount ? AppColors.primary : Colors.red)),
                    const SizedBox(height: 16),
                    ...activeMembers.map((member) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: (member['avatar'] != '') ? NetworkImage(member['avatar']) : null,
                            child: (member['avatar'] == '') ? const Icon(Icons.person) : null,
                            radius: 14,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 100,
                            child: TextFormField(
                              initialValue: member['fixedAmount'].toString(),
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(contentPadding: const EdgeInsets.all(8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                              onChanged: (val) {
                                setDialogState(() {
                                  member['fixedAmount'] = int.tryParse(val) ?? 0;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () {
                    if (currentTotal == inputTotalAmount) {
                      setState(() {});
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2030),
      builder: (context, child) => Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)), child: child!),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  // --- UI CHÍNH ---
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
      body: _isLoadingMembers 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Tên khoản chi"),
            _buildTextField(controller: _titleController, hint: "Ví dụ: Trả tiền nước tháng 10"),
            const SizedBox(height: 16),
            _buildLabel("Số tiền"),
            _buildTextField(
              controller: _amountController, hint: "0", suffix: "VND", isNumber: true,
              onChanged: (val) {
                if (_splitTypeIndex == 2) setState(() => _calculateAmountSplit());
              },
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildLabel("Ngày chi"),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("${selectedDate.day}/${selectedDate.month}/${selectedDate.year}", style: const TextStyle(fontSize: 13)),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    ]),
                  ),
                )
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildLabel("Người trả"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedPayerId,
                      isExpanded: true,
                      items: members.map((m) => DropdownMenuItem<String>(
                        value: m['uid'],
                        child: Text(m['name'], overflow: TextOverflow.ellipsis),
                      )).toList(),
                      onChanged: (v) => setState(() => selectedPayerId = v),
                    ),
                  ),
                )
              ])),
            ]),
            const SizedBox(height: 16),
            _buildLabel("Loại chi tiêu"),
            Wrap(spacing: 8, children: ["Điện nước", "Internet", "Tiền nhà", "Đi chợ"].map((c) => ChoiceChip(
              label: Text(c), selected: selectedCategory == c, onSelected: (v) => setState(() => selectedCategory = c),
              selectedColor: AppColors.creditGreen, backgroundColor: Colors.white,
            )).toList()),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _buildLabel("Ai tham gia khoản chi"),
              GestureDetector(
                onTap: () {
                  setState(() {
                    bool allSelected = members.every((m) => m['isSelected']);
                    for (var m in members) m['isSelected'] = !allSelected;
                    _recalculateSplit();
                  });
                },
                child: const Text("Chọn tất cả", style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ]),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(children: members.map((member) => CheckboxListTile(
                activeColor: AppColors.primary, dense: true, controlAffinity: ListTileControlAffinity.trailing,
                secondary: CircleAvatar(backgroundImage: (member['avatar'] != '') ? NetworkImage(member['avatar']) : null, child: (member['avatar'] == '') ? const Icon(Icons.person) : null),
                title: Row(children: [
                  Expanded(child: Text(member['name'], style: const TextStyle(fontWeight: FontWeight.bold))),
                  if (_splitTypeIndex == 1 && member['isSelected']) Text("${member['percentage']}%", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  if (_splitTypeIndex == 2 && member['isSelected']) Text("${member['fixedAmount']}đ", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ]),
                value: member['isSelected'],
                onChanged: (val) => setState(() { member['isSelected'] = val ?? false; _recalculateSplit(); }),
              )).toList()),
            ),
            const SizedBox(height: 16),
            _buildLabel("Cách chia tiền"),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
              child: Row(children: List.generate(splitTypes.length, (index) {
                bool isSelected = _splitTypeIndex == index;
                return Expanded(child: GestureDetector(
                  onTap: () {
                    setState(() { _splitTypeIndex = index; _recalculateSplit(); });
                    if (index == 1) _showPercentageDialog();
                    if (index == 2) _showAmountDialog();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(10), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)] : []),
                    child: Text(splitTypes[index], textAlign: TextAlign.center, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: Colors.black)),
                  ),
                ));
              })),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Lưu khoản chi", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 2),
    );
  }

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textBlack)));

  Widget _buildTextField({required TextEditingController controller, required String hint, String? suffix, bool isNumber = false, Function(String)? onChanged}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: TextField(
        controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, onChanged: onChanged,
        decoration: InputDecoration(hintText: hint, suffixText: suffix, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
      ),
    );
  }
}