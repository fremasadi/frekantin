double extractRating(List<dynamic>? reviews) {
  if (reviews == null || reviews.isEmpty) return 0.0;

  try {
    final review = reviews[0] as Map<String, dynamic>;
    final reviewerId = review.keys.first;
    final reviewData = review[reviewerId] as Map<String, dynamic>;
    final ratingKey = reviewData.keys.first;

    // Safely convert the rating to double
    return double.tryParse(ratingKey) ?? 0.0;
  } catch (e) {
    return 0.0;
  }
}
