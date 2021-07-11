import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sexual_health_assignment/models/models.dart';

class DatabaseProvider {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging fcm = FirebaseMessaging.instance;

  Future saveUser(UserModel user, String uid) async {
    user.uid = uid;
    try {
      // // Register device to receive notifications
      user.token = await fcm.getToken();

      // User document reference
      DocumentReference userDoc = _db.collection('users').doc(uid);

      // Save document
      await userDoc.set(user.toFirestore());
    } on FirebaseException {
      rethrow;
    }
  }
}
