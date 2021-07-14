import 'package:cloud_firestore/cloud_firestore.dart';

class TestModel {
  String? testId;
  String? name;
  String? info;
  List<dynamic>? genitalia;
  int? sicknessPeriod;

  TestModel({
    this.testId,
    this.name,
    this.info,
    this.genitalia,
    this.sicknessPeriod,
  });

  factory TestModel.fromFirestore(DocumentSnapshot doc) {
    dynamic data = doc.data();
    if (doc.exists) {
      return TestModel(
        testId: doc.id,
        name: data['name'] ?? '',
        genitalia: data['genitalia'] ?? [],
        info: data['info'] ?? '',
        sicknessPeriod: data['sicknessPeriod'] ?? 1,
      );
    } else {
      return TestModel();
    }
  }
}
