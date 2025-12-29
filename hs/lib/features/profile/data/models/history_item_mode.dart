import 'package:flutter/material.dart';

enum HistoryType { money, chore, badge }

class HistoryItemModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final HistoryType type;
  final String valueDisplay; 
  final bool isNegative;     
  
  // Các thuộc tính UI đi kèm
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  HistoryItemModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.type,
    required this.valueDisplay,
    this.isNegative = false,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}