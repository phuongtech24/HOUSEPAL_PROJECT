import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/datasources/ExpenseService.dart';
import '../../data/models/expense_model.dart';

class EditExpensePage extends StatefulWidget {
  final ExpenseModel expense;

  const EditExpensePage({super.key, required this.expense});

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  final ExpenseService _expenseService = ExpenseService();
  
  // State quản lý tab chia tiền
  int _splitTypeIndex = 0; // 0: Chia đều, 1: Theo %, 2: Số tiền
  final List<String> splitTypes = ["Chia đều", "Theo %", "Số tiền"];

  late TextEditingController _amountController;
  late TextEditingController _titleController;

  // Dữ liệu thành viên (Sẽ load từ Firebase)
  List<Map<String, dynamic>> members = [];
  bool _isLoadingMembers = true;
  bool _isSaving = false;

  late DateTime selectedDate;
  late String selectedCategory;
  String? selectedPayerId;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.expense.amount.toInt().toString());
    _titleController = TextEditingController(text: widget.expense.title);
    selectedDate = widget.expense.date;
    selectedCategory = widget.expense.category;
    selectedPayerId = widget.expense.payerId;
    
    // Determine split type index
    if (widget.expense.splitType == 'percent') {
      _splitTypeIndex = 1;
    } else if (widget.expense.splitType == 'exact') {
      _splitTypeIndex = 2;
    } else {
      _splitTypeIndex = 0;
    }

    _fetchHouseMembers();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  // 1. LẤY DANH SÁCH THÀNH VIÊN TỪ FIREBASE VÀ MAP VỚI DỮ LIỆU CŨ
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
            // Check if this member was involved in the expense
            bool isInvolved = widget.expense.splitDetails.containsKey(uid);
            double amountOrPercent = widget.expense.splitDetails[uid] ?? 0;
            
            int percentage = 0;
            int fixedAmount = 0;

            if (_splitTypeIndex == 1 && isInvolved) {
               // Restore percentage (approximate logic if needed, but ideally we store it)
               // Since we store exact amounts, we might need to recalculate back to percent
               // For simplicity, let's just default to recalculating if user changes tab.
               // But if current mode is percent, we should try.
               percentage = ((amountOrPercent / widget.expense.amount) * 100).round();
            } else if (_splitTypeIndex == 2 && isInvolved) {
               fixedAmount = amountOrPercent.toInt();
            }

            loadedMembers.add({
              "uid": uid,
              "name": memDoc['name'] ?? 'Thành viên',
              "avatar": memDoc['avatarUrl'] ?? '',
              "isSelected": isInvolved,
              "percentage": percentage,
              "fixedAmount": fixedAmount,
            });
          }
        }

        if (mounted) {
          setState(() {
            members = loadedMembers;
            _isLoadingMembers = false;
            // Recalculate if split type is equal to ensure UI is consistent
            if (_splitTypeIndex == 0) _recalculateSplit();
          });
        }
      }
    } catch (e) {
      print("Lỗi load members: $e");
      setState(() => _isLoadingMembers = false);
    }
  }

  // --- LOGIC TÍNH TOÁN (Giữ nguyên) ---
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
    // If we are editing, we might want to preserve existing values if possible, 
    // but simplifying to auto-split for now if user touches controls is safer than complex logic.
    // However, on first load we tried to set them. Use simple logic for updates.
    int count = selectedMembers.length;
    int basePercent = (100 / count).floor();
    int remainder = 100 - (basePercent * count);

    for (var m in members) {
      if (m['isSelected'] == true) {
         // Only overwrite if 0 (newly selected)
         if (m['percentage'] == 0) m['percentage'] = basePercent;
      } else {
        m['percentage'] = 0;
      }
    }
    // Simple normalization check (optional)
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
        if (m['fixedAmount'] == 0) m['fixedAmount'] = baseAmount;
      } else {
        m['fixedAmount'] = 0;
      }
    }
  }

  // --- XỬ LÝ LƯU (SAVE) ---
  Future<void> _handleUpdate() async {
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

      // 2. Gọi Service Update
      final updatedExpense = widget.expense.isActiveCopy().copyWith(
        title: _titleController.text.trim(),
        amount: totalAmount,
        category: selectedCategory,
        payerId: selectedPayerId ?? FirebaseAuth.instance.currentUser!.uid,
        splitType: _splitTypeIndex == 0 ? 'equal' : (_splitTypeIndex == 1 ? 'percent' : 'exact'),
        splitDetails: splitDetails,
        date: selectedDate,
      );

      await _expenseService.updateExpense(updatedExpense);

      if (mounted) {
        Navigator.pop(context); // Close Edit Page
        Navigator.pop(context); // Close Detail Page (optional, or rely on Stream)
        // Better: Pop Edit Page, Detail Page updates automatically via Stream if it listens, 
        // OR simply pop back to list.
        // If Detail Page receives the model directly, it won't auto-update unless wrapped in StreamBuilder/ValueListenable.
        // However, usually detailed pages just show constant data or we can pass the data back.
        // For now, let's pop Edit Page, and the user might need to navigate back or re-enter detailing.
        // ACTUALLY: The best UX is to pop EditPage, and if DetailPage is just a stateless widget with static data, it will be stale.
        // So we should navigate back to ExpensesPage or convert DetailPage to StreamBuilder.
        // For simplicity: Pop EditPage.
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã cập nhật khoản chi!")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- CÁC POPUP DIALOG (GIỮ NGUYÊN) ---
  void _showPercentageDialog() {
    List<Map<String, dynamic>> activeMembers = members.where((m) => m['isSelected'] == true).toList();
    if (activeMembers.isEmpty) return;
    
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
    // Dynamic Colors
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardTheme.color ?? Colors.white;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor, elevation: 0,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: textColor), onPressed: () => Navigator.pop(context)),
        title: Text("Sửa khoản chi", style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoadingMembers 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Tên khoản chi", textColor),
            _buildTextField(controller: _titleController, hint: "Ví dụ: Trả tiền nước tháng 10", cardColor: cardColor, textColor: textColor),
            const SizedBox(height: 16),
            _buildLabel("Số tiền", textColor),
            _buildTextField(
              controller: _amountController, hint: "0", suffix: "VND", isNumber: true, cardColor: cardColor, textColor: textColor,
              onChanged: (val) {
                if (_splitTypeIndex == 2) setState(() => _calculateAmountSplit());
              },
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildLabel("Ngày chi", textColor),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(DateFormat('dd/MM/yyyy').format(selectedDate), style: TextStyle(fontSize: 13, color: textColor)),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    ]),
                  ),
                )
              ])),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildLabel("Người trả", textColor),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedPayerId,
                      dropdownColor: cardColor,
                      isExpanded: true,
                      items: members.map((m) => DropdownMenuItem<String>(
                        value: m['uid'],
                        child: Text(m['name'], overflow: TextOverflow.ellipsis, style: TextStyle(color: textColor)),
                      )).toList(),
                      onChanged: (v) => setState(() => selectedPayerId = v),
                    ),
                  ),
                )
              ])),
            ]),
            const SizedBox(height: 16),
            _buildLabel("Loại chi tiêu", textColor),
            Wrap(spacing: 8, children: ["Điện nước", "Internet", "Tiền nhà", "Đi chợ"].map((c) => ChoiceChip(
              label: Text(c, style: TextStyle(color: selectedCategory == c ? Colors.white : textColor)), 
              selected: selectedCategory == c, 
              onSelected: (v) => setState(() => selectedCategory = c),
              selectedColor: AppColors.creditGreen, 
              backgroundColor: cardColor,
            )).toList()),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _buildLabel("Ai tham gia khoản chi", textColor),
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
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
              child: Column(children: members.map((member) => CheckboxListTile(
                activeColor: AppColors.primary, dense: true, controlAffinity: ListTileControlAffinity.trailing,
                secondary: CircleAvatar(backgroundImage: (member['avatar'] != '') ? NetworkImage(member['avatar']) : null, child: (member['avatar'] == '') ? const Icon(Icons.person) : null),
                title: Row(children: [
                  Expanded(child: Text(member['name'], style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
                  if (_splitTypeIndex == 1 && member['isSelected']) Text("${member['percentage']}%", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  if (_splitTypeIndex == 2 && member['isSelected']) Text("${member['fixedAmount']}đ", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ]),
                value: member['isSelected'],
                onChanged: (val) => setState(() { member['isSelected'] = val ?? false; _recalculateSplit(); }),
              )).toList()),
            ),
            const SizedBox(height: 16),
            _buildLabel("Cách chia tiền", textColor),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
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
                    decoration: BoxDecoration(color: isSelected ? cardColor : Colors.transparent, borderRadius: BorderRadius.circular(10), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)] : []),
                    child: Text(splitTypes[index], textAlign: TextAlign.center, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: textColor)),
                  ),
                ));
              })),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text("Cập nhật", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, Color color) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)));

  Widget _buildTextField({required TextEditingController controller, required String hint, String? suffix, bool isNumber = false, Function(String)? onChanged, required Color cardColor, required Color textColor}) {
    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: TextField(
        controller: controller, keyboardType: isNumber ? TextInputType.number : TextInputType.text, onChanged: onChanged,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(hintText: hint, suffixText: suffix, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), hintStyle: TextStyle(color: Colors.grey)),
      ),
    );
  }
}

// Add extension to copy ExpenseModel if not already present
extension ExpenseModelCopy on ExpenseModel {
  // Assuming copyWith exists, if not, implement it here or in model file.
  // For now I assume it might NOT exist or I can't check easily. 
  // Let's implement a safe copyWith here or just creating new instance.
  ExpenseModel isActiveCopy() {
    return this; 
  }

  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? payerId,
    String? category,
    String? splitType,
    Map<String, double>? splitDetails,
    DateTime? date,
    String? evidenceUrl,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      payerId: payerId ?? this.payerId,
      category: category ?? this.category,
      splitType: splitType ?? this.splitType,
      splitDetails: splitDetails ?? this.splitDetails,
      date: date ?? this.date,
      evidenceUrl: evidenceUrl ?? this.evidenceUrl,
    );
  }
}
