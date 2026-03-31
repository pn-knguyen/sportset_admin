import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportset_admin/models/sport.dart';

class SportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'sports';

  Stream<List<Sport>> getAllSportsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Sport.fromFirestore(doc)).toList(),
        );
  }

  Future<List<Sport>> getAllSports() async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Sport.fromFirestore(doc)).toList();
  }

  Future<Sport?> getSportById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return Sport.fromFirestore(doc);
  }

  Stream<Sport?> getSportByIdStream(String id) {
    return _firestore.collection(_collection).doc(id).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return Sport.fromFirestore(doc);
    });
  }

  Future<String> createSport({
    required String name,
    required String description,
    required String iconKey,
    required bool isVisible,
  }) async {
    final now = DateTime.now();
    final docRef = await _firestore.collection(_collection).add({
      'name': name,
      'description': description,
      'iconKey': iconKey,
      'isVisible': isVisible,
      'itemCount': 0,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    return docRef.id;
  }

  Future<void> updateSport({
    required String id,
    required String name,
    required String description,
    required String iconKey,
    required bool isVisible,
    int? itemCount,
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'description': description,
      'iconKey': iconKey,
      'isVisible': isVisible,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (itemCount != null) {
      payload['itemCount'] = itemCount;
    }

    await _firestore.collection(_collection).doc(id).update(payload);
  }

  Future<void> deleteSport(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
