import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> add(String collection, Map<String, dynamic> data) async {
    await _db.collection(collection).add(data);
  }

  Stream<QuerySnapshot> getCollection(String collection) {
    return _db.collection(collection).snapshots();
  }

  Future<void> update(String collection, String id, Map<String, dynamic> data) async {
    await _db.collection(collection).doc(id).update(data);
  }

  Future<void> delete(String collection, String id) async {
    await _db.collection(collection).doc(id).delete();
  }
}