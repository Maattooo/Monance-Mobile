class ExpenseModel {
  final String id;
  final int amount; // In cents/centavos (integer)
  final String title;
  final String category;
  final String deductionType; // 'daily' or 'wallet'
  final int timestamp; // Milliseconds since epoch

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.title,
    required this.category,
    required this.deductionType,
    required this.timestamp,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    // Robust conversion for amount which can be int or double from JSON
    final rawAmount = json['amount'];
    int parsedAmount = 0;
    if (rawAmount is num) {
      parsedAmount = rawAmount.round();
    } else if (rawAmount is String) {
      parsedAmount = (double.tryParse(rawAmount) ?? 0.0).round();
    }

    // Robust timestamp parsing
    final rawTime = json['timestamp'] ?? json['createdAt'];
    int parsedTime = DateTime.now().millisecondsSinceEpoch;
    if (rawTime is num) {
      parsedTime = rawTime.toInt();
    } else if (rawTime is String) {
      parsedTime = DateTime.tryParse(rawTime)?.millisecondsSinceEpoch ?? parsedTime;
    }

    final rawDeduct = json['deductFrom'] ?? json['deductionType'];
    final deductionType = (rawDeduct == 'balance' || rawDeduct == 'wallet') ? 'wallet' : 'daily';

    return ExpenseModel(
      id: (json['id'] ?? json['_id'] ?? 'exp_${DateTime.now().millisecondsSinceEpoch}').toString(),
      amount: parsedAmount,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Other',
      deductionType: deductionType,
      timestamp: parsedTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'title': title,
      'category': category,
      'deductFrom': deductionType == 'wallet' ? 'balance' : 'allowance',
      'deductionType': deductionType,
      'timestamp': timestamp,
    };
  }

  ExpenseModel copyWith({
    String? id,
    int? amount,
    String? title,
    String? category,
    String? deductionType,
    int? timestamp,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      category: category ?? this.category,
      deductionType: deductionType ?? this.deductionType,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
