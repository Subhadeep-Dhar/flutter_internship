/// Pure Dart domain entity representing a customer review on a product.
class Review {
  final double rating;
  final String comment;
  final String? date;
  final String reviewerName;
  final String? reviewerEmail;

  const Review({
    required this.rating,
    required this.comment,
    this.date,
    required this.reviewerName,
    this.reviewerEmail,
  });

  /// Safely parses the ISO date string into a [DateTime], if valid.
  DateTime? get parsedDate {
    if (date == null || date!.isEmpty) return null;
    return DateTime.tryParse(date!);
  }

  /// Formatted date string for display (e.g., "May 23, 2024").
  String get formattedDate {
    final parsed = parsedDate;
    if (parsed == null) return date ?? '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Review &&
          runtimeType == other.runtimeType &&
          rating == other.rating &&
          comment == other.comment &&
          reviewerName == other.reviewerName &&
          date == other.date;

  @override
  int get hashCode =>
      rating.hashCode ^
      comment.hashCode ^
      reviewerName.hashCode ^
      date.hashCode;

  @override
  String toString() =>
      'Review(reviewer: $reviewerName, rating: $rating, comment: $comment)';
}
