class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? cniNumber;
  final String? cniRectoImage;
  final String? cniVersoImage;
  final String? profilePicture;
  final DateTime createdAt;
  final bool isVerified;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.cniNumber,
    this.cniRectoImage,
    this.cniVersoImage,
    this.profilePicture,
    required this.createdAt,
    this.isVerified = false,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'cniNumber': cniNumber,
      'cniRectoImage': cniRectoImage,
      'cniVersoImage': cniVersoImage,
      'profilePicture': profilePicture,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      cniNumber: json['cniNumber'],
      cniRectoImage: json['cniRectoImage'],
      cniVersoImage: json['cniVersoImage'],
      profilePicture: json['profilePicture'],
      createdAt: DateTime.parse(json['createdAt']),
      isVerified: json['isVerified'] ?? false,
    );
  }
}