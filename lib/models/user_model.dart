import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class UserModel{
  String id;
  String name;
  String email;
  List<CartItem> cart;
  DateTime createdAt;
  DateTime lastLoginAt;
  String phone;
  String profilePic;

//<editor-fold desc="Data Methods">
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.cart,
    required this.createdAt,
    required this.lastLoginAt,
    required this.phone,
    required this.profilePic,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          cart == other.cart &&
          createdAt == other.createdAt &&
          lastLoginAt == other.lastLoginAt &&
          phone == other.phone &&
          profilePic == other.profilePic);

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      email.hashCode ^
      cart.hashCode ^
      createdAt.hashCode ^
      lastLoginAt.hashCode ^
      phone.hashCode ^
      profilePic.hashCode;

  @override
  String toString() {
    return 'UserModel{' +
        ' id: $id,' +
        ' name: $name,' +
        ' email: $email,' +
        ' cart: $cart,' +
        ' createdAt: $createdAt,' +
        ' lastLoginAt: $lastLoginAt,' +
        ' phone: $phone,' +
        ' profilePic: $profilePic,' +
        '}';
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    List<CartItem>? cart,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? phone,
    String? profilePic,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      cart: cart ?? this.cart,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      phone: phone ?? this.phone,
      profilePic: profilePic ?? this.profilePic,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'cart': cart.map((item) => item.toJson()).toList(),
      'createdAt': createdAt,
      'lastLoginAt': lastLoginAt,
      'phone': phone,
      'profilePic': profilePic,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      cart: (map['cart'] as List).map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (map['lastLoginAt'] as Timestamp).toDate(),
      phone: map['phone'] as String,
      profilePic: map['profilePic'] as String,
    );
  }

//</editor-fold>
}