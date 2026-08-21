class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.isOnline = false,
    this.lastSeenAt,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown User',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'] ?? json['avatar'],
      bio: json['bio']?.toString(),
      isOnline: json['is_online'] == true || json['isOnline'] == true,
      lastSeenAt: json['last_seen_at'] != null 
          ? DateTime.tryParse(json['last_seen_at'].toString()) 
          : (json['lastSeenAt'] != null 
              ? DateTime.tryParse(json['lastSeenAt'].toString()) 
              : (json['lastSeen'] != null ? DateTime.tryParse(json['lastSeen'].toString()) : null)),
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'].toString()) 
          : (json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_online': isOnline,
      'last_seen_at': lastSeenAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    bool? isOnline,
    DateTime? lastSeenAt,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
