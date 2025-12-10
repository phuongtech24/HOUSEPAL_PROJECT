class Expense {
  final String? id;
  final String title;
  final String payer;
  final int amount; // store cents or whole units as needed
  final String status;
  final DateTime timestamp;

  Expense({
    this.id,
    required this.title,
    required this.payer,
    required this.amount,
    required this.status,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'payer': payer,
      'amount': amount,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    return Expense(
      id: id,
      title: map['title'] as String? ?? '',
      payer: map['payer'] as String? ?? '',
      amount: (map['amount'] is int) ? map['amount'] as int : int.tryParse('${map['amount']}') ?? 0,
      status: map['status'] as String? ?? '',
      timestamp: DateTime.tryParse('${map['timestamp']}') ?? DateTime.now(),
    );
  }
}
