import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportset_admin/models/voucher.dart';

class VoucherService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collectionName = 'vouchers';

  // Create new voucher
  Future<String> createVoucher(Voucher voucher) async {
    try {
      final docRef = await _db.collection(_collectionName).add(voucher.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create voucher: $e');
    }
  }

  // Get all vouchers as stream
  Stream<List<Voucher>> getAllVouchersStream() {
    return _db.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Voucher.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    });
  }

  // Get all vouchers as future
  Future<List<Voucher>> getAllVouchersFuture() async {
    try {
      final snapshot = await _db.collection(_collectionName).get();
      return snapshot.docs
          .map((doc) =>
              Voucher.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    } catch (e) {
      throw Exception('Failed to get vouchers: $e');
    }
  }

  // Get voucher by ID as stream
  Stream<Voucher?> getVoucherByIdStream(String voucherId) {
    return _db.collection(_collectionName).doc(voucherId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return Voucher.fromFirestore(snapshot, null);
    });
  }

  // Get voucher by ID as future
  Future<Voucher?> getVoucherByIdFuture(String voucherId) async {
    try {
      final snapshot = await _db.collection(_collectionName).doc(voucherId).get();
      if (!snapshot.exists) {
        return null;
      }
      return Voucher.fromFirestore(snapshot, null);
    } catch (e) {
      throw Exception('Failed to get voucher: $e');
    }
  }

  // Update voucher
  Future<void> updateVoucher(String voucherId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = Timestamp.now();
      await _db.collection(_collectionName).doc(voucherId).update(data);
    } catch (e) {
      throw Exception('Failed to update voucher: $e');
    }
  }

  // Delete voucher
  Future<void> deleteVoucher(String voucherId) async {
    try {
      await _db.collection(_collectionName).doc(voucherId).delete();
    } catch (e) {
      throw Exception('Failed to delete voucher: $e');
    }
  }

  // Get vouchers by facility
  Stream<List<Voucher>> getVouchersByFacilityStream(String facilityId) {
    return _db
        .collection(_collectionName)
        .where('facilityId', isEqualTo: facilityId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              Voucher.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>, null))
          .toList();
    });
  }
}
