class User {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'athlete', 'coach', 'admin'
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender; // 'male', 'female', 'other'
  final String? state;
  final String? district;
  final String? sport;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.state,
    this.district,
    this.sport,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  // Create User from Supabase JSON (matches your profiles table)
  factory User.fromSupabaseJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      gender: json['gender'],
      state: json['state'],
      district: json['district'],
      sport: json['sport'],
      category: json['category'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Convert User to JSON for Supabase insertion/update
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone': phone,
      'date_of_birth':
          dateOfBirth?.toIso8601String().split('T')[0], // Date only
      'gender': gender,
      'state': state,
      'district': district,
      'sport': sport,
      'category': category,
    };
  }

  // Helper methods
  bool get isAthlete => role == 'athlete';
  bool get isCoach => role == 'coach';
  bool get isAdmin => role == 'admin';

  int? get age {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    int age = today.year - dateOfBirth!.year;
    if (today.month < dateOfBirth!.month ||
        (today.month == dateOfBirth!.month && today.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Copy with method for updates
  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? state,
    String? district,
    String? sport,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      state: state ?? this.state,
      district: district ?? this.district,
      sport: sport ?? this.sport,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
