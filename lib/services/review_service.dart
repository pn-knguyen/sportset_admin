import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sportset_admin/models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'reviews';

  /// Stream tất cả đánh giá, sắp xếp mới nhất trước
  Stream<List<Review>> getAllReviewsStream() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Review.fromFirestore(doc)).toList());
  }

  /// Xóa đánh giá khỏi Firestore
  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection(_collection).doc(reviewId).delete();
  }

  /// Lưu phản hồi của admin vào Firestore (field name theo app customer)
  Future<void> submitReply(String reviewId, String reply) async {
    await _firestore.collection(_collection).doc(reviewId).update({
      'reply': reply.trim(),
      'replied': true,
    });
  }
}
