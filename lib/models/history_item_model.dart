class HistoryItem {
  final String id;
  final String? imagePath;
  final double authenticityScore;
  final String riskLevel;
  final DateTime timestamp;

  HistoryItem({
    required this.id,
    required this.imagePath,
    required this.authenticityScore,
    required this.riskLevel,
    required this.timestamp,
  });
}
