import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportset_admin/models/customer.dart';

class CustomerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'customers';

  /// Stream tất cả khách hàng, sắp xếp mới nhất trước
  Stream<List<Customer>> getAllCustomersStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList());
  }
}
