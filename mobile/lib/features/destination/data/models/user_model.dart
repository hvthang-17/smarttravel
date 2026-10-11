class UserState {
  final int? id;
  final String? email;
  final String? fullName;
  final String? role;
  final String? token;

  UserState({this.id, this.email, this.fullName, this.role, this.token});

  bool get isAuthenticated => token != null && token!.isNotEmpty;

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
    );
  }
}


