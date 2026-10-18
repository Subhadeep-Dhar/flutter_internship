import '../../domain/entities/review.dart';

/// Data Transfer Object for [Review] serialized from DummyJSON product responses.
class ReviewModel extends Review {
  const ReviewModel({
    required super.rating,
    required super.comment,
    super.date,
    required super.reviewerName,
    super.reviewerEmail,
  });

  /// Safely deserializes a JSON object into a [ReviewModel].
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: (json['comment'] as String?)?.trim() ?? '',
      date: (json['date'] as String?)?.trim(),
      reviewerName: (json['reviewerName'] as String?)?.trim() ?? 'Anonymous',
      reviewerEmail: (json['reviewerEmail'] as String?)?.trim(),
    );
  }

  /// Converts this [ReviewModel] to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'comment': comment,
      if (date != null) 'date': date,
      'reviewerName': reviewerName,
      if (reviewerEmail != null) 'reviewerEmail': reviewerEmail,
    };
  }
}
