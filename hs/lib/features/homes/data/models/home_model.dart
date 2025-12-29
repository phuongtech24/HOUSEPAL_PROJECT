class HomeSummaryModel {
  final int todayChores;
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
