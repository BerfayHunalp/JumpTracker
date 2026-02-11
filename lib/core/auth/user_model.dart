class AppUser {
  final String id;
  final String email;
  final String nickname;
  final int avatarIndex;
  final String createdAt;

  const AppUser({
    required this.id,
    required this.email,
    required this.nickname,
    required this.avatarIndex,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      nickname: json['nickname'] as String,
      avatarIndex: json['avatarIndex'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'nickname': nickname,
        'avatarIndex': avatarIndex,
        'createdAt': createdAt,
      };

  AppUser copyWith({
    String? nickname,
    int? avatarIndex,
  }) {
    return AppUser(
      id: id,
      email: email,
      nickname: nickname ?? this.nickname,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      createdAt: createdAt,
    );
  }
}
