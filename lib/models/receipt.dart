class Receipt {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String receiptType; // 'membership' or 'program_fee'
  final double amount;
  final DateTime paymentDate;
  final String paymentMethod; // 'qr_code', 'card', etc.
  final String transactionId;
  final String status; // 'pending', 'completed', 'failed'
  final Map<String, dynamic>? details; // Additional details for membership or program
  final String pdfUrl;
  final DateTime generatedAt;

  Receipt({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.receiptType,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.transactionId,
    required this.status,
    this.details,
    required this.pdfUrl,
    required this.generatedAt,
  });

  // Convert to Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'receiptType': receiptType,
      'amount': amount,
      'paymentDate': paymentDate,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'status': status,
      'details': details,
      'pdfUrl': pdfUrl,
      'generatedAt': generatedAt,
    };
  }

  // Create from Firestore snapshot
  factory Receipt.fromMap(Map<String, dynamic> map) {
    return Receipt(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      receiptType: map['receiptType'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      paymentDate: map['paymentDate']?.toDate() ?? DateTime.now(),
      paymentMethod: map['paymentMethod'] ?? '',
      transactionId: map['transactionId'] ?? '',
      status: map['status'] ?? '',
      details: map['details'],
      pdfUrl: map['pdfUrl'] ?? '',
      generatedAt: map['generatedAt']?.toDate() ?? DateTime.now(),
    );
  }
}
