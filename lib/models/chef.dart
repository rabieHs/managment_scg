class Chef {
  final int id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final List<String> speciality;

  Chef({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.speciality,
  });

  factory Chef.fromJson(Map<String, dynamic> json) {
    return Chef(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      phone: json['phone'] as String,
      speciality: (json['speciality'] as String?)
              ?.split(',')
              ?.cast<String>()
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'speciality': speciality,
    };
  }

  Chef copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    List<String>? speciality,
  }) {
    return Chef(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      speciality: speciality ?? this.speciality,
    );
  }
}
