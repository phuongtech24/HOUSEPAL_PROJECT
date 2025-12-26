import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';
import '../../data/models/expense_model.dart';
import 'debt_detail_page.dart';
import '../../data/datasources/ExpenseService.dart'; // Đảm bảo đường dẫn này đúng với file của bạn

class DebtOptimizationPage extends StatefulWidget {
  const DebtOptimizationPage({super.key});

  @override
  State<DebtOptimizationPage> createState() => _DebtOptimizationPageState();
}

class _DebtOptimizationPageState extends State<DebtOptimizationPage> {
  final ExpenseService _service = ExpenseService();
  final String _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final currencyFormat = NumberFormat("#,##0", "vi_VN");

  Map<String, Map<String, String>> _userProfiles = {};

  @override
  void initState() {
    super.initState();
    _fetchAllUserProfiles();
  }

  // Lấy thông tin (Tên + Avatar) của các thành viên trong nhà
  Future<void> _fetchAllUserProfiles() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final houseId = userDoc['houseId'];
      
      if (houseId == null) return;

      final houseDoc = await FirebaseFirestore.instance.collection('houses').doc(houseId).get();
      List<dynamic> members = houseDoc['members'];

      Map<String, Map<String, String>> profiles = {};
      for (String uid in members) {
        final uDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
        if (uDoc.exists) {
          profiles[uid] = {
            'name': uDoc['name'] ?? 'Thành viên',
            'avatar': uDoc['avatarUrl'] ?? '',
          };
        }
      }
      if (mounted) setState(() => _userProfiles = profiles);
    } catch (e) {
      print("Lỗi load profile: $e");
    }
  }

  // --- THUẬT TOÁN TỐI ƯU HÓA DÒNG TIỀN (NET BALANCE) ---
  List<Map<String, dynamic>> _calculateDebts(List<ExpenseModel> expenses) {
    // 1. Tính số dư ròng (Net Balance) của TẤT CẢ thành viên
    Map<String, double> netBalance = {};

    for (var expense in expenses) {
      // Xử lý Settlement (Thanh toán nợ)
      if (expense.splitType == 'settlement') {
         double amount = expense.amount;
         // Lấy người nhận tiền (thường chỉ có 1 người trong map splitDetails)
         String receiverId = expense.splitDetails.keys.isNotEmpty 
             ? expense.splitDetails.keys.first 
             : '';
         
         if (receiverId.isNotEmpty) {
             netBalance[expense.payerId] = (netBalance[expense.payerId] ?? 0) + amount; // Người trả (+)
             netBalance[receiverId] = (netBalance[receiverId] ?? 0) - amount;           // Người nhận (-)
         }
         continue;
      }

      // Xử lý Chi tiêu thường (Expense)
      // Người trả tiền (Payer) được cộng (+) phần tiền họ đã trả hộ người khác
      double myShare = expense.splitDetails[expense.payerId] ?? 0;
      double amountOthersOwe = expense.amount - myShare;
      
      netBalance[expense.payerId] = (netBalance[expense.payerId] ?? 0) + amountOthersOwe;

      // Những người tham gia (trừ Payer) bị trừ (-) số tiền họ nợ
      expense.splitDetails.forEach((uid, amount) {
        if (uid != expense.payerId) {
          netBalance[uid] = (netBalance[uid] ?? 0) - amount;
        }
      });
    }

    // 2. Tách thành 2 nhóm: Con nợ (Âm) và Chủ nợ (Dương)
    List<MapEntry<String, double>> debtors = [];
    List<MapEntry<String, double>> creditors = [];

    netBalance.forEach((uid, amount) {
      if (amount < -100) debtors.add(MapEntry(uid, amount)); 
      if (amount > 100) creditors.add(MapEntry(uid, amount));
    });

    // Sắp xếp giảm dần theo độ lớn
    debtors.sort((a, b) => a.value.compareTo(b.value)); // Tăng dần (-500 trước -100)
    creditors.sort((a, b) => b.value.compareTo(a.value)); // Giảm dần (+500 trước +100)

    // 3. Ghép cặp trả nợ (Match Debtors to Creditors)
    List<Map<String, dynamic>> transactions = [];
    int i = 0; 
    int j = 0; 

    while (i < debtors.length && j < creditors.length) {
      var debtor = debtors[i];
      var creditor = creditors[j];

      // Số tiền giao dịch = Min(Nợ bao nhiêu, Được nhận bao nhiêu)
      double amount = debtor.value.abs() < creditor.value 
          ? debtor.value.abs() 
          : creditor.value;

      // CHỈ HIỂN THỊ NẾU LIÊN QUAN ĐẾN TÔI (_myUid)
      if (debtor.key == _myUid || creditor.key == _myUid) {
         transactions.add({
          'partnerId': (debtor.key == _myUid) ? creditor.key : debtor.key,
          'amount': (debtor.key == _myUid) ? -amount : amount, // Âm: Tôi phải trả, Dương: Tôi được nhận
        });
      }

      // Cập nhật lại số dư sau khi "ảo" trả
      double remainingDebt = debtor.value + amount;     
      double remainingCredit = creditor.value - amount; 

      if (remainingDebt.abs() < 100) {
        i++; 
      } else {
        debtors[i] = MapEntry(debtor.key, remainingDebt);
      }

      if (remainingCredit < 100) {
        j++; 
      } else {
        creditors[j] = MapEntry(creditor.key, remainingCredit);
      }
    }

    return transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("Tối ưu công nợ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: _service.getExpensesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final expenses = snapshot.data ?? [];
          final debtItems = _calculateDebts(expenses);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: AppColors.creditGreen, shape: BoxShape.circle), child: const Icon(Icons.cached, color: Colors.white, size: 30)),
                      const SizedBox(width: 16),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text("Đã tối ưu hóa dòng tiền", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text("Hệ thống đã tính toán đường đi ngắn nhất để thanh toán hết nợ.", style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ])),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Align(alignment: Alignment.centerLeft, child: Text("Danh sách cần thanh toán", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                const SizedBox(height: 12),

                // List
                Expanded(
                  child: debtItems.isEmpty
                      ? Center(child: Text("Tuyệt vời! Không còn khoản nợ nào.", style: TextStyle(color: Colors.grey.shade500)))
                      : ListView.builder(
                          itemCount: debtItems.length,
                          itemBuilder: (context, index) {
                            final item = debtItems[index];
                            final partnerId = item['partnerId'];
                            final amount = item['amount'] as double;
                            final isCreditor = amount > 0;

                            final profile = _userProfiles[partnerId] ?? {'name': 'Đang tải...', 'avatar': ''};

                            return _buildDebtCard(
                              context,
                              partnerId: partnerId,
                              partnerName: profile['name']!,
                              partnerAvatar: profile['avatar']!,
                              amount: amount,
                              isCreditor: isCreditor,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 2),
    );
  }

  Widget _buildDebtCard(BuildContext context, {required String partnerId, required String partnerName, required String partnerAvatar, required double amount, required bool isCreditor}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DebtDetailPage(
              partnerId: partnerId,
              partnerName: partnerName,
              partnerAvatar: partnerAvatar,
              amount: amount.abs(),
              isCreditor: isCreditor,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          children: [
            Row(
              children: [
                _buildAvatar(isCreditor ? partnerAvatar : ""),
                if(!isCreditor) const SizedBox(width: 8),
                if(!isCreditor) Text(partnerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                if(isCreditor) const Text("Bạn", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_right_alt, color: Colors.grey))),
                if(isCreditor) Text(partnerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                if(!isCreditor) const Text("Bạn", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(width: 8),
                _buildAvatar(isCreditor ? "" : partnerAvatar),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: isCreditor ? const Color(0xFFE0F9F4) : const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(4)),
                  child: Text(isCreditor ? "Người khác nợ bạn" : "Bạn cần thanh toán", 
                    style: TextStyle(color: isCreditor ? Colors.teal : Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                Text("${currencyFormat.format(amount.abs())}đ", style: TextStyle(color: isCreditor ? AppColors.primary : AppColors.debtRed, fontWeight: FontWeight.bold, fontSize: 16)),
                const Text("Chi tiết >", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }
  
  // --- ĐÃ SỬA: Hàm hiển thị avatar thông minh (Local hoặc Network) ---
  Widget _buildAvatar(String url) {
    if (url.isEmpty) {
      return const CircleAvatar(backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white), radius: 20);
    }
    
    // Kiểm tra nếu là ảnh trong máy (Assets)
    if (url.contains('lib/') || url.contains('assets/')) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: AssetImage(url), 
      );
    }

    // Trường hợp còn lại là ảnh mạng
    return CircleAvatar(
      radius: 20,
      backgroundImage: NetworkImage(url),
    );
  }
}