class UserState {
  final int? id;
  final String? email;
  final String? fullName;
  final String? role;
  final String? token;
  final String? phone;
  final String? bio;
  final String? persona;
  final int? avatarIndex;

  UserState({
    this.id,
    this.email,
    this.fullName,
    this.role,
    this.token,
    this.phone,
    this.bio,
    this.persona = 'Khách du lịch tự túc',
    this.avatarIndex = 0,
  });

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  UserState copyWith({
    int? id,
    String? email,
    String? fullName,
    String? role,
    String? token,
    String? phone,
    String? bio,
    String? persona,
    int? avatarIndex,
  }) {
    return UserState(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      token: token ?? this.token,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      persona: persona ?? this.persona,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }

  factory UserState.fromJson(Map<String, dynamic> json, String token) {
    final rawId = json['id'];
    int? parsedId;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId != null) {
      parsedId = int.tryParse(rawId.toString());
    }

    return UserState(
      id: parsedId,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      role: json['role'] as String?,
      token: token,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      persona: (json['persona'] as String?) ?? 'Khách du lịch tự túc',
      avatarIndex: json['avatarIndex'] is int ? json['avatarIndex'] as int : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      'token': token,
      'phone': phone,
      'bio': bio,
      'persona': persona,
      'avatarIndex': avatarIndex,
    };
  }
}
