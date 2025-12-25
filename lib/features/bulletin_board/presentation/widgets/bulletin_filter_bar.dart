import 'package:flutter/material.dart';

class BulletinFilterBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const BulletinFilterBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildTab("Hôm nay", 0),
          _buildTab("Ghi chú", 1),
          _buildTab("Mua sắm", 2),
        ],
      ),
    );
  }

  Widget _buildTab(String text, int index) {
    bool isSelected = selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}