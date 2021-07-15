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
  String? isSickWith;
  bool? isSick;
  Timestamp? sickUntil;

  UserModel({
    this.email,
    this.password,
    this.uid,
    this.dob,
    this.name,
    this.gender,
    this.isSickWith,
    this.genitalia,
    this.token,
    this.isSick = false,
    this.sickUntil,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    if (doc.exists) {
      dynamic data = doc.data();
      return UserModel(
        email: data['email'] ?? '',
        name: data['name'] ?? '',
        genitalia: data['genitalia'] ?? '',
        uid: doc.id,
        isSick: data['isSick'] ?? false,
        sickUntil: data['sickUntil'],
        isSickWith: data['isSickWith'] ?? '',
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
        'isSick': isSick,
        'sickUntil': sickUntil,
        'isSickWith': isSickWith,
      };
}
