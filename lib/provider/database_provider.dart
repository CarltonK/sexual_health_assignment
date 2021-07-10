import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sexual_health_assignment/models/models.dart';

class DatabaseProvider {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future saveUser(UserModel user, String uid) async {
    user.uid = uid;
    try {
      // // Register device to receive notifications
      // user.deviceToken = await fcm.getToken();

      // User document reference
      DocumentReference userDoc = _db.collection('users').doc(uid);

      // Save document
      await userDoc.set(user.toFirestore());
    } on FirebaseException catch (error) {
      throw error;
    }
  }
}
