class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profilePic;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profilePic,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profilePic: json['profilePic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profilePic': profilePic,
    };
  }
}
