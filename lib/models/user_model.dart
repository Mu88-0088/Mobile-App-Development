import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;          // 'user' | 'admin'
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool isActive;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImageUrl,
    required this.createdAt,
    required this.isActive,
  });

  bool get isAdmin => role == 'admin';

  // ── Firestore ──────────────────────────────────────

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
      role: d['role'] ?? 'user',
      profileImageUrl: d['profileImageUrl'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: d['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'profileImageUrl': profileImageUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'isActive': isActive,
  };

  UserModel copyWith({
    String? name,
    String? phone,
    String? profileImageUrl,
    bool? isActive,
    String? role,
  }) =>
      UserModel(
        uid: uid,
        email: email,
        createdAt: createdAt,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        role: role ?? this.role,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        isActive: isActive ?? this.isActive,
      );
}
