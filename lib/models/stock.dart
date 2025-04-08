class Stock {
  final int? id; // Nullable ID for new items not yet in DB
  final String name;
  final String type;
  final String manufacturer;
  final String model;
  final String status;
  final String location;
  final DateTime creationDate;
  final DateTime updateDate;
  final int? userId; // Changed to nullable int

  Stock({
    this.id,
    required this.name,
    required this.type,
    required this.manufacturer,
    required this.model,
    this.status = 'available', // Default status
    this.location = 'SCG', // Default location
    required this.creationDate,
    required this.updateDate,
    this.userId, // Made optional in constructor
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      manufacturer: json['manufacturer'],
      model: json['model'],
      status: json['status'],
      location: json['location'],
      creationDate: DateTime.parse(json['creation_date']),
      updateDate: DateTime.parse(json['update_date']),
      userId: json['user_id'], // Will be null if json['user_id'] is null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'manufacturer': manufacturer,
      'model': model,
      'status': status,
      'location': location,
      'creation_date': creationDate.toIso8601String(),
      'update_date': updateDate.toIso8601String(),
      'user_id': userId,
    };
  }
}
