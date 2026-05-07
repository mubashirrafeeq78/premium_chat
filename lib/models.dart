class UserModel {
  final String phone;
  final String name;
  final String role;
  final String avatarBase64;

  const UserModel({
    required this.phone,
    required this.name,
    required this.role,
    required this.avatarBase64,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) {
    return UserModel(
      phone: (j["phone"] ?? "").toString(),
      name: (j["name"] ?? "").toString(),
      role: (j["role"] ?? "").toString(),
      avatarBase64: (j["avatarBase64"] ?? "").toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        "phone": phone,
        "name": name,
        "role": role,
        "avatarBase64": avatarBase64,
      };
}