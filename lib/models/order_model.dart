import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String? owner;
  String? test;
  String? orderId;
  Timestamp? orderedAt;
  String? result;
  Timestamp? resultReleasedAt;
  String? notes;

  OrderModel({
    this.owner,
    this.test,
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
        test: data['test'] ?? '',
        orderedAt: data['orderedAt'],
        result: data['result'],
        resultReleasedAt: data['resultReleasedAt'],
        notes: data['notes'],
      );
    } else {
      return OrderModel();
    }
  }

  Map<String, dynamic> toFirestore() => {
        'owner': owner,
        'test': test,
        'resultReleasedAt': resultReleasedAt,
        'orderedAt': Timestamp.now(),
      };
}
