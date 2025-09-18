class AssessmentVideo {
  final String id;
  final String assessmentId;
  final String filePath;
  final String? thumbnailUrl;
  final DateTime createdAt;

  AssessmentVideo({
    required this.id,
    required this.assessmentId,
    required this.filePath,
    this.thumbnailUrl,
    required this.createdAt,
  });

  factory AssessmentVideo.fromJson(Map<String, dynamic> json) {
    return AssessmentVideo(
      id: json['id'] as String,
      assessmentId: json['assessment_id'] as String,
      filePath: json['file_path'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
