class StockRequest {
  final int? id;
  final int senderId;
  final String stockType;
  final String status;
  final String description;
  final DateTime createdAt;

  StockRequest({
    this.id,
    required this.senderId,
    required this.stockType,
    this.status = 'pending', // Default status
    required this.description,
    required this.createdAt,
  });

  factory StockRequest.fromJson(Map<String, dynamic> json) {
    return StockRequest(
      id: json['id'],
      senderId: json['sender_id'],
      stockType: json['stock_type'],
      status: json['status'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'stock_type': stockType,
      'status': status,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
