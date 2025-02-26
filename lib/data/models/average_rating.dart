class AverageRating {
  final double averageRating;

  AverageRating({required this.averageRating});

  factory AverageRating.fromJson(Map<String, dynamic> json) {
    return AverageRating(
      averageRating: json['averageRating'].toDouble(),
    );
  }
}
