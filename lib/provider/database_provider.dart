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

  Stream<UserModel> streamUser(String uid) {
    DocumentReference userDoc = _db.doc('users/$uid');
    return userDoc.snapshots().map((user) => UserModel.fromFirestore(user));
  }

  Future updateName(String uid, String name) async {
    try {
      DocumentReference userDoc = _db.doc('users/$uid');
      await userDoc.update({'name': name});
    } on FirebaseException catch (error) {
      return error.message;
    }
  }

  Future updateUserToken(String uid) async {
    try {
      DocumentReference userDoc = _db.doc('users/$uid');
      String? token = await fcm.getToken();
      await userDoc.update({'token': token});
    } on FirebaseException catch (error) {
      return error.message;
    }
  }

  Future deleteUserToken(String uid) async {
    try {
      FirebaseMessaging.instance.deleteToken();
      DocumentReference userDoc = _db.doc('users/$uid');
      await userDoc.update({'token': null});
    } on FirebaseException catch (error) {
      return error.message;
    }
  }

  Future getTests(String genitalia) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('tests')
          .where('genitalia', arrayContains: genitalia)
          .get();
      return snapshot.docs.map((doc) => TestModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (error) {
      return error.message;
    }
  }

  Future getRecentOrders(String uid) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('orders')
          .where('owner', isEqualTo: uid)
          .orderBy('orderedAt', descending: true)
          .limit(3)
          .get();
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } on FirebaseException catch (error) {
      return error.message;
    }
  }

  Future getAllOrders(String uid) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('orders')
          .where('owner', isEqualTo: uid)
          .orderBy('orderedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc));
    } on FirebaseException catch (error) {
      return error.message;
    }
  }

  Future createOrder(OrderModel order) async {
    try {
      await _db.collection('orders').doc().set(order.toFirestore());
    } on FirebaseException catch (error) {
      return error.message;
    }
  }
}
