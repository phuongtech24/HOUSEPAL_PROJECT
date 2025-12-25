import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  final String title;
  final String payer;
  final String amount;
  final Color amountColor;
  final String status;
  final Color statusBgColor;
  final Color statusTextColor;
  final IconData icon;
  final Color iconBgColor;

  const TransactionItem({
    super.key,
    required this.title,
    required this.payer,
    required this.amount,
    required this.amountColor,
    required this.status,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.icon,
    required this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon tròn
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.blueAccent),
          ),
          const SizedBox(width: 12),
          // Thông tin chính
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text("Người trả: $payer", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          // Số tiền và trạng thái
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: amountColor)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(status, style: TextStyle(fontSize: 10, color: statusTextColor, fontWeight: FontWeight.bold)),
              )
            ],
          )
        ],
      ),
    );
  }
}