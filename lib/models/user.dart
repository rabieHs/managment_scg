// ignore_for_file: public_member_api_docs, sort_constructors_first
class User {
  final int id;
  final String name;
  final String email;
  final String type;
  final String phone;
  final List<String>? speciality;
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.phone,
    this.speciality,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] ??
          json[
              'id'], // Prioritize 'user_id' if available (from join), otherwise use 'id'
      name: json['name'],
      email: json['email'],
      type: json['type'],
      phone: json['phone'],
      speciality: (json['speciality'] as String?)?.split(','),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type,
      'phone': phone,
      'speciality': speciality,
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? type,
    String? phone,
    List<String>? speciality,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      type: type ?? this.type,
      phone: phone ?? this.phone,
      speciality: speciality ?? this.speciality,
    );
  }
}
