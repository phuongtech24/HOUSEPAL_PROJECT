import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- CÁC IMPORT CỦA BẠN ---
// Hãy đảm bảo đường dẫn import đúng với cấu trúc dự án của bạn
import 'package:hs/features/expenses/data/datasources/ExpenseService.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/housepal_bottom_nav.dart';
import '../../data/models/expense_model.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_item.dart';

// --- IMPORT TRANG CHI TIẾT ---
import 'expense_detail_page.dart'; 

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final ExpenseService _service = ExpenseService();
  final String _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  
  final currencyFormat = NumberFormat("#,##0", "vi_VN");

  // --- LOGIC TÍNH TOÁN SỐ DƯ ---
  Map<String, double> _calculateBalances(List<ExpenseModel> expenses) {
    double totalDebt = 0;       // Tổng tiền mình nợ
    double totalReceivable = 0; // Tổng tiền người khác nợ mình

    for (var expense in expenses) {
      bool isSettlement = expense.splitType == 'settlement';

      // TRƯỜNG HỢP 1: Mình là người chi tiền (Payer)
      if (expense.payerId == _myUid) {
        if (isSettlement) {
          // Mình trả tiền để Xóa nợ -> Giảm tổng nợ của mình
          totalDebt -= expense.amount; 
        } else {
          // Chi tiêu thường -> Người khác nợ mình
          double myShare = expense.splitDetails[_myUid] ?? 0;
          totalReceivable += (expense.amount - myShare);
        }
      } 
      // TRƯỜNG HỢP 2: Mình là người thụ hưởng/tham gia (Receiver)
      else if (expense.splitDetails.containsKey(_myUid)) {
        double myPortion = expense.splitDetails[_myUid]!;
        
        if (isSettlement) {
          // Mình được nhận tiền trả nợ -> Giảm tổng phải thu
          totalReceivable -= myPortion;
        } else {
          // Chi tiêu thường (người khác trả hộ) -> Mình nợ thêm
          totalDebt += myPortion;
        }
      }
    }
    
    if (totalDebt < 0) totalDebt = 0;
    if (totalReceivable < 0) totalReceivable = 0;

    return {
      'debt': totalDebt,
      'receivable': totalReceivable,
      'net': totalReceivable - totalDebt
    };
  }

  IconData _getIconForCategory(String category) {
    String cat = category.toLowerCase();
    if (cat.contains("thanh toán") || cat.contains("trả nợ")) return Icons.check_circle_outline;
    if (cat.contains("điện")) return Icons.electric_bolt;
    if (cat.contains("nước")) return Icons.water_drop;
    if (cat.contains("net") || cat.contains("wifi")) return Icons.wifi;
    if (cat.contains("chợ") || cat.contains("ăn")) return Icons.shopping_cart;
    if (cat.contains("nhà")) return Icons.home;
    return Icons.receipt_long;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text("Quỹ chung", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<ExpenseModel>>(
        stream: _service.getExpensesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text("Lỗi tải dữ liệu"));

          final expenses = snapshot.data ?? [];
          
          // Tính toán lại số dư
          final balances = _calculateBalances(expenses);
          final double netBalance = balances['net']!;
          final double debt = balances['debt']!;
          final double receivable = balances['receivable']!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                // 1. CARD SỐ DƯ
                BalanceCard(
                  highlightType: netBalance >= 0 ? HighlightType.receivable : HighlightType.debt,
                  totalBalance: "${netBalance >= 0 ? '+' : ''}${currencyFormat.format(netBalance)}đ",
                  debtAmount: "${currencyFormat.format(debt)}đ",
                  receivableAmount: "${currencyFormat.format(receivable)}đ",
                ),

                const SizedBox(height: 24),
                const Text("Khoản chi tiêu gần đây", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                // 2. DANH SÁCH GIAO DỊCH
                expenses.isEmpty
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Chưa có giao dịch", style: TextStyle(color: Colors.grey))))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      final bool isMePayer = expense.payerId == _myUid;
                      final bool isSettlement = expense.splitType == 'settlement';
                      final String dateStr = DateFormat('dd/MM').format(expense.date);

                      // --- LOGIC HIỂN THỊ ITEM ---
                      String titleText = expense.title;
                      String payerText = "";
                      String amountText = "${currencyFormat.format(expense.amount)}đ";
                      Color amountColor = Colors.black;
                      String statusText = "";
                      Color statusBg = Colors.grey.shade100;
                      Color statusTextCol = Colors.grey;
                      Color iconBg = Colors.white;

                      if (isSettlement) {
                        // GIAO DỊCH TRẢ NỢ
                        titleText = "Thanh toán nợ";
                        iconBg = const Color(0xFFE8F5E9); 
                        if (isMePayer) {
                           payerText = "Bạn đã trả nợ ($dateStr)";
                           amountText = "-${currencyFormat.format(expense.amount)}đ";
                           amountColor = Colors.green;
                           statusText = "Đã thanh toán";
                           statusBg = const Color(0xFFE8F5E9);
                           statusTextCol = Colors.green;
                        } else {
                           payerText = "Bạn đã nhận tiền ($dateStr)";
                           amountText = "+${currencyFormat.format(expense.amount)}đ";
                           amountColor = Colors.green;
                           statusText = "Đã nhận";
                           statusBg = const Color(0xFFE8F5E9);
                           statusTextCol = Colors.green;
                        }
                      } else {
                        // CHI TIÊU THƯỜNG
                        if (isMePayer) {
                           payerText = "Bạn đã trả ($dateStr)";
                           statusText = "Đã trả trước";
                           statusBg = const Color(0xFFE0F2FE);
                           statusTextCol = Colors.blue;
                           iconBg = const Color(0xFFE3F2FD);
                        } else {
                           payerText = "Thành viên khác trả ($dateStr)";
                           amountColor = AppColors.debtRed;
                           statusText = "Bạn nợ";
                           statusBg = const Color(0xFFFFF0F0);
                           statusTextCol = AppColors.debtRed;
                           iconBg = const Color(0xFFFFF3E0);
                        }
                      }

                      // --- SỰ KIỆN NHẤN ĐỂ XEM CHI TIẾT ---
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExpenseDetailPage(expense: expense),
                            ),
                          );
                        },
                        child: TransactionItem(
                          title: titleText,
                          payer: payerText,
                          amount: amountText,
                          amountColor: amountColor,
                          status: statusText,
                          statusBgColor: statusBg,
                          statusTextColor: statusTextCol,
                          icon: _getIconForCategory(expense.category),
                          iconBgColor: iconBg,
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_expense'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      bottomNavigationBar: const HousePalBottomNav(currentIndex: 2),
    );
  }
}