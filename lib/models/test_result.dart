import 'dart:convert';


class TestResult {
  final String id;
  final String userId;
  final String testType;
  final double score;
  final String videoPath;
  final DateTime timestamp;
  final bool isVerified;
  final bool isSynced;
  final Map<String, dynamic> metadata;

  TestResult({
    required this.id,
    required this.userId,
    required this.testType,
    required this.score,
    required this.videoPath,
    required this.timestamp,
    this.isVerified = false,
    this.isSynced = false,
    this.metadata = const {},
  });

  // ✅ Convert object to JSON (for local DB / Supabase insert)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'test_type': testType,
      'score': score,
      'video_url': videoPath,
      'timestamp': timestamp.toIso8601String(),
      'is_verified': isVerified ? 1 : 0, // store as int for SQLite
      'is_synced': isSynced ? 1 : 0,
      'metadata': metadata, // works if stored as JSON (SQLite needs jsonEncode)
    };
  }

  // ✅ For local DB / SQLite
  factory TestResult.fromJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      testType: json['test_type'] as String,
      score: (json['score'] as num).toDouble(),
      videoPath: json['video_url'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isVerified: (json['is_verified'] is int)
          ? json['is_verified'] == 1
          : (json['is_verified'] ?? false),
      isSynced: (json['is_synced'] is int)
          ? json['is_synced'] == 1
          : (json['is_synced'] ?? false),
      metadata: (json['metadata'] is String)
          ? Map<String, dynamic>.from(
              jsonDecode(json['metadata']),
            )
          : Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  // ✅ For Supabase (API JSON usually matches camel/snake case differently)
  factory TestResult.fromSupabaseJson(Map<String, dynamic> json) {
    return TestResult(
      id: json['id'],
      userId: json['user_id'],
      testType: json['test_type'],
      score: (json['score'] as num).toDouble(),
      videoPath: json['video_url'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      isVerified: json['is_verified'] ?? false,
      isSynced: true, // Always synced when coming from Supabase
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
}
