import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hs/features/expenses/data/datasources/ExpenseService.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/expense_model.dart';

class DebtDetailPage extends StatefulWidget {
  final String partnerId;
  final String partnerName;
  final String partnerAvatar;
  final double amount;
  final bool isCreditor; // True: Họ nợ tôi (Tôi được nút Xác nhận). False: Tôi nợ họ (Nút Thanh toán).

  const DebtDetailPage({
    super.key,
    required this.partnerId,
    required this.partnerName,
    required this.partnerAvatar,
    required this.amount,
    required this.isCreditor,
  });

  @override
  State<DebtDetailPage> createState() => _DebtDetailPageState();
}

class _DebtDetailPageState extends State<DebtDetailPage> {
  final ExpenseService _service = ExpenseService();
  final String _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  final currencyFormat = NumberFormat("#,##0", "vi_VN");
  bool _isProcessing = false;

  // Lấy các khoản chi liên quan giữa tôi và đối tác
  // Logic: Lọc những khoản mà (Tôi trả, Họ có phần) HOẶC (Họ trả, Tôi có phần)
  // Và chưa bị settled (cái này tính tương đối qua stream)
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: const Text("Chi tiết nợ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. CARD TỔNG
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                    child: Column(
                      children: [
                        // Avatar Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildAvatarColumn(widget.isCreditor ? widget.partnerName : "Bạn", widget.isCreditor ? widget.partnerAvatar : ""),
                            const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Icon(Icons.arrow_forward, color: Colors.grey, size: 28)),
                            _buildAvatarColumn(widget.isCreditor ? "Bạn" : widget.partnerName, widget.isCreditor ? "" : widget.partnerAvatar),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text("${currencyFormat.format(widget.amount)}đ", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: widget.isCreditor ? const Color(0xFFE0F9F4) : const Color(0xFFFFF0F0), borderRadius: BorderRadius.circular(20)),
                          child: Text(widget.isCreditor ? "Chờ họ thanh toán" : "Chưa thanh toán", 
                            style: TextStyle(color: widget.isCreditor ? Colors.teal : Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // 2. DANH SÁCH CÁC KHOẢN CHI LIÊN QUAN (Lịch sử)
                  const Text("Các khoản chi liên quan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  
                  StreamBuilder<List<ExpenseModel>>(
                    stream: _service.getExpensesStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      
                      // Lọc ra các khoản chi liên quan đến cặp đôi này
                      final relatedExpenses = snapshot.data!.where((e) {
                        bool involved = false;
                        // Case A: Tôi trả, Họ có phần
                        if (e.payerId == _myUid && e.splitDetails.containsKey(widget.partnerId)) involved = true;
                        // Case B: Họ trả, Tôi có phần
                        if (e.payerId == widget.partnerId && e.splitDetails.containsKey(_myUid)) involved = true;
                        
                        return involved;
                      }).toList();

                      return Column(
                        children: relatedExpenses.map((e) {
                          bool iPaid = e.payerId == _myUid;
                          double amountInvolved = iPaid 
                              ? (e.splitDetails[widget.partnerId] ?? 0) // Tiền họ nợ tôi trong khoản này
                              : (e.splitDetails[_myUid] ?? 0);          // Tiền tôi nợ họ trong khoản này
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(color: iPaid ? Colors.blue.withOpacity(0.1) : Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                                  child: Icon(iPaid ? Icons.arrow_outward : Icons.arrow_downward, color: iPaid ? Colors.blue : Colors.orange, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(iPaid ? "Bạn đã trả hộ" : "${widget.partnerName} đã trả", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                )),
                                Text("${currencyFormat.format(amountInvolved)}đ", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // 3. NÚT HÀNH ĐỘNG
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : () => _handleAction(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.isCreditor ? "Xác nhận đã nhận tiền" : "Đã chuyển khoản (Chờ xác nhận)",
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LOGIC XỬ LÝ NÚT BẤM
  Future<void> _handleAction(BuildContext context) async {
    // Chỉ Chủ nợ (Người được nhận tiền) mới có quyền Xóa nợ thật sự trên hệ thống
    if (widget.isCreditor) {
      setState(() => _isProcessing = true);
      try {
        // Gọi Service tạo giao dịch thanh toán
        await _service.settleDebt(
          debtorId: widget.partnerId,  // Người nợ là đối phương
          creditorId: _myUid,          // Chủ nợ là tôi
          amount: widget.amount,       // Số tiền nợ hiện tại
        );
        
        if (mounted) {
          Navigator.pop(context); // Quay lại trang trước
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã xác nhận thanh toán thành công!")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    } else {
      // Nếu là người nợ -> Chỉ hiện thông báo (Vì app chưa có tính năng banking thật)
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Hãy báo cho người kia xác nhận nhé!")));
    }
  }

  Widget _buildAvatarColumn(String name, String url) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
          child: url.isEmpty ? const Icon(Icons.person) : null,
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}