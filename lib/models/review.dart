import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String bookingId;
  final DateTime createdAt;
  final String fieldId;
  final String fieldName;
  final int rating;
  final String review;
  final String userId;
  final String userName;
  final String userAvatar;
  final List<String> images;
  final bool replied;
  final String? reply;

  const Review({
    required this.id,
    required this.bookingId,
    required this.createdAt,
    required this.fieldId,
    required this.fieldName,
    required this.rating,
    required this.review,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.images,
    required this.replied,
    this.reply,
  });

  factory Review.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final images = (data['images'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();
    return Review(
      id: doc.id,
      bookingId: data['bookingId'] as String? ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      fieldId: data['fieldId'] as String? ?? '',
      fieldName: data['fieldName'] as String? ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      review: data['review'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Khách hàng',
      userAvatar: data['userAvatar'] as String? ?? '',
      images: images,
      replied: data['replied'] as bool? ?? false,
      reply: data['reply'] as String?,
    );
  }
}
