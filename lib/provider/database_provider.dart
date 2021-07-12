import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sexual_health_assignment/models/models.dart';

class DatabaseProvider {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging fcm = FirebaseMessaging.instance;

  DatabaseProvider() {
    // Comment this line for production
    // _db.useFirestoreEmulator('192.168.100.11', 4001);
  }

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

  Future getUser(String uid) async {
    try {
      DocumentReference userDoc = _db.doc('users/$uid');
      DocumentSnapshot snapshot = await userDoc.get();
      return UserModel.fromFirestore(snapshot);
    } on FirebaseException catch (error) {
      return error.message;
    }
  }
}
