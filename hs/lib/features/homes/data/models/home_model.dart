import '../../../chores/data/models/chore_model.dart';

class HomeSummaryModel {
  final List<ChoreModel> todayChores;
  final int monthPoints;
  final int debt;
  final int credit;

  HomeSummaryModel({
    required this.todayChores,
    required this.monthPoints,
    required this.debt,
    required this.credit,
  });
}

class HomeActivityModel {
  final String title;
  final String subtitle;
  final DateTime createdAt;

  HomeActivityModel({
    required this.title,
    required this.subtitle,
    required this.createdAt,
  });
}

// Minor optimization

// Updated logic

// Code cleanup
