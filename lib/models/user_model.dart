import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  String? email;
  String? uid;
  String? name;
  String? photoUrl;
  Timestamp? createAt;
  Timestamp? lastLoginAt;

  UserModel({
    this.email,
    this.uid,
    this.name,
    this.photoUrl,
    this.createAt,
    this.lastLoginAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        email: json["email"],
        uid: json["uid"],
        name: json["name"],
        photoUrl: json["photoUrl"],
        createAt: json["createAt"],
        lastLoginAt: json["lastLoginAt"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "uid": uid,
        "name": name,
        "photoUrl": photoUrl,
        "createAt": createAt,
        "lastLoginAt": lastLoginAt,
      };
}
