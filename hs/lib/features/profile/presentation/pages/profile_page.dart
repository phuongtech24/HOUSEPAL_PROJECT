import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hs/core/widgets/housepal_bottom_nav.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stat_card.dart';
import '../widgets/profile_menu_option.dart';
import 'manage_house_page.dart';

// --- IMPORT QUAN TRỌNG: Dùng Service và Model của Expenses ---
// Hãy chắc chắn đường dẫn này đúng với dự án của bạn
import 'package:hs/features/expenses/data/datasources/ExpenseService.dart';
import 'package:hs/features/expenses/data/models/expense_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};
    
    // 1. Lấy thông tin User
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!userDoc.exists) return {}; 
    final userData = userDoc.data() ?? {};
    
    String houseName = "Chưa có nhà";
    String inviteCode = "";
    double finalBalance = 0.0; 

    // 2. Lấy thông tin House
    if (userData['houseId'] != null && userData['houseId'].toString().isNotEmpty) {
      final String houseId = userData['houseId'];
      final houseDoc = await FirebaseFirestore.instance.collection('houses').doc(houseId).get();
      
      if (houseDoc.exists) {
        final houseData = houseDoc.data() ?? {};
        houseName = houseData['name'] ?? "Nhà chung"; 
        inviteCode = houseData['inviteCode'] ?? "";

        // --- DÙNG SERVICE ĐỂ ĐỒNG BỘ DỮ LIỆU VỚI TRANG TỐI ƯU ---
        try {
          final expenseService = ExpenseService();
          
          // Lấy danh sách chi tiêu từ Stream (lấy snapshot đầu tiên)
          // Điều này đảm bảo chúng ta dùng đúng bộ dữ liệu như trang DebtOptimizationPage
          final List<ExpenseModel> expenses = await expenseService.getExpensesStream().first;

          // Áp dụng thuật toán tính toán tối ưu
          final transactions = _calculateDebts(expenses, user.uid);
          
          // Cộng dồn kết quả: Tôi nợ ai (-) hay ai nợ tôi (+)
          for (var trans in transactions) {
            finalBalance += (trans['amount'] as num).toDouble();
          }
        } catch (e) {
          debugPrint("Lỗi tính toán Profile: $e");
          // Nếu lỗi Service, giữ balance = 0 hoặc fallback tùy ý
        }
      }
    }

    return {
      ...userData,
      'houseName': houseName,
      'inviteCode': inviteCode,
      'calculatedBalance': finalBalance,
    };
  }

  // --- THUẬT TOÁN COPY TỪ DEBT OPTIMIZATION PAGE ---
  // Giữ nguyên logic để đảm bảo số liệu khớp 100%
  List<Map<String, dynamic>> _calculateDebts(List<ExpenseModel> expenses, String myUid) {
    // 1. Tính số dư ròng (Net Balance)
    Map<String, double> netBalance = {};

    for (var expense in expenses) {
      if (expense.splitType == 'settlement') {
         double amount = expense.amount;
         String receiverId = expense.splitDetails.keys.isNotEmpty 
             ? expense.splitDetails.keys.first 
             : '';
         
         if (receiverId.isNotEmpty) {
             netBalance[expense.payerId] = (netBalance[expense.payerId] ?? 0) + amount;
             netBalance[receiverId] = (netBalance[receiverId] ?? 0) - amount;
         }
         continue;
      }

      double myShare = expense.splitDetails[expense.payerId] ?? 0;
      double amountOthersOwe = expense.amount - myShare;
      
      netBalance[expense.payerId] = (netBalance[expense.payerId] ?? 0) + amountOthersOwe;

      expense.splitDetails.forEach((uid, amount) {
        if (uid != expense.payerId) {
          netBalance[uid] = (netBalance[uid] ?? 0) - amount;
        }
      });
    }

    // 2. Tách nhóm
    List<MapEntry<String, double>> debtors = [];
    List<MapEntry<String, double>> creditors = [];

    netBalance.forEach((uid, amount) {
      // Bộ lọc này là nguyên nhân khiến số liệu lệch nếu tính thủ công
      if (amount < -100) debtors.add(MapEntry(uid, amount)); 
      if (amount > 100) creditors.add(MapEntry(uid, amount));
    });

    debtors.sort((a, b) => a.value.compareTo(b.value)); 
    creditors.sort((a, b) => b.value.compareTo(a.value)); 

    // 3. Ghép cặp
    List<Map<String, dynamic>> transactions = [];
    int i = 0; 
    int j = 0; 

    while (i < debtors.length && j < creditors.length) {
      var debtor = debtors[i];
      var creditor = creditors[j];

      double amount = debtor.value.abs() < creditor.value 
          ? debtor.value.abs() 
          : creditor.value;

      // CHỈ LẤY GIAO DỊCH LIÊN QUAN ĐẾN TÔI
      if (debtor.key == myUid || creditor.key == myUid) {
         transactions.add({
          'partnerId': (debtor.key == myUid) ? creditor.key : debtor.key,
          'amount': (debtor.key == myUid) ? -amount : amount, 
        });
      }

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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Hồ sơ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
             return Center(child: Text("Lỗi: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Không có dữ liệu"));
          }

          final data = snapshot.data!;
          final bool isAdmin = (data['role'] == 'admin');
          final String inviteCode = data['inviteCode'] ?? '';
          final String houseName = data['houseName'] ?? 'Nhà chung';
          final double balance = data['calculatedBalance'] ?? 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ProfileHeader(
                  name: data['name'] ?? 'User',
                  email: data['email'] ?? '',
                  avatarUrl: data['avatarUrl'] ?? '',
                  role: data['role'] ?? 'member',
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, size: 14, color: AppColors.primary),
                    label: const Text("Chỉnh sửa thông tin", style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE0F9F4), elevation: 0),
                  ),
                ),
                const SizedBox(height: 24),

                if (isAdmin) 
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => ManageHousePage(
                            houseName: houseName, 
                            inviteCode: inviteCode
                          )
                        )
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xFFFFE0B2), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.apartment, color: Colors.orange, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Quản lý Nhà", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text("Quản lý thành viên, tài chính, quy định", style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  )
                else 
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Thông tin nhà", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        Text(houseName, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 4),
                        const Text("Vai trò của bạn: Thành viên", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              _showInviteCodeDialog(context, inviteCode);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.qr_code, size: 16),
                                  SizedBox(width: 6),
                                  Text("Xem Mã Nhà", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Thống kê - Dữ liệu chắc chắn khớp
                ProfileStatCard(
                  points: data['currentPoints'] ?? 0, 
                  debt: balance
                ),
                
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Cài đặt", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      SizedBox(height: 8),
                      ProfileMenuOption(title: "Thông báo việc nhà", type: MenuType.switchType, switchValue: true),
                      Divider(height: 1),
                      ProfileMenuOption(title: "Thông báo chi tiêu", type: MenuType.switchType, switchValue: true),
                      Divider(height: 1),
                      ProfileMenuOption(title: "Ngôn ngữ", type: MenuType.dropdown, dropdownValue: "Tiếng Việt"),
                      Divider(height: 1),
                      ProfileMenuOption(title: "Giao diện", type: MenuType.dropdown, dropdownValue: "Hệ thống"),
                    ],
                  ),
                ),
                 const SizedBox(height: 20),

                 Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.exit_to_app, color: Colors.red, size: 18),
                          label: const Text("Rời nhà", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(backgroundColor: const Color(0xFFFEECEB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton.icon(
                          onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                          },
                          icon: const Icon(Icons.logout, color: Colors.grey, size: 18),
                          label: const Text("Đăng xuất", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(backgroundColor: const Color(0xFFF2F4F5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 4),
    );
  }

  void _showInviteCodeDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Mã Nhà"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(code, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppColors.primary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã sao chép!")));
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text("Sao chép"),
            )
          ],
        ),
      ),
    );
  }
}