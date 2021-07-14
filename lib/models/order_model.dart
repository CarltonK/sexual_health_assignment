import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sexual_health_assignment/models/models.dart';

class OrderModel {
  String? owner;
  List<TestModel>? tests;
  String? orderId;
  Timestamp? orderedAt;
  String? result;
  Timestamp? resultReleasedAt;
  String? notes;

  OrderModel({
    this.owner,
    this.tests,
    this.orderId,
    this.orderedAt,
    this.result,
    this.resultReleasedAt,
    this.notes,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    if (doc.exists) {
      dynamic data = doc.data();
      return OrderModel(
        orderId: doc.id,
        tests: data['tests'] ?? '',
        orderedAt: data['orderedAt'],
        result: data['result'],
        resultReleasedAt: data['resultReleasedAt'],
        notes: data['notes'] ?? '',
      );
    } else {
      return OrderModel();
    }
  }

  Map<String, dynamic> toFirestore() => {
        'owner': owner,
        'tests': tests,
      };
}
