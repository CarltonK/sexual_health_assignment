import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? email;
  String? password;
  String? uid;
  Timestamp? dob;
  String? name;
  String? gender;
  String? genitalia;
  String? token;

  UserModel({
    this.email,
    this.password,
    this.uid,
    this.dob,
    this.name,
    this.gender,
    this.genitalia,
    this.token,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    if (doc.exists) {
      dynamic data = doc.data();
      return UserModel(
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        uid: doc.id,
      );
    } else {
      return UserModel();
    }
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'uid': uid,
        'dob': dob,
        'name': name,
        'gender': gender,
        'genitalia': genitalia,
        'token': token,
      };
}