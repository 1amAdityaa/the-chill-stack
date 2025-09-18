class PerformanceMetric {
  final String id;
  final String assessmentId;
  final String athleteId;
  final String metricName;
  final double metricValue;
  final String? metricUnit;
  final double? benchmarkValue;
  final double? percentile;
  final String? grade; // 'A+', 'A', 'B+', 'B', 'C+', 'C', 'D', 'F'
  final String? notes;
  final DateTime recordedAt;
  final DateTime createdAt;

  // Related data
  final Map<String, dynamic>? assessment;

  // Added: category (used by UI grouping) and a convenience `value` getter
  final String? category;

  PerformanceMetric({
    required this.id,
    required this.assessmentId,
    required this.athleteId,
    required this.metricName,
    required this.metricValue,
    this.metricUnit,
    this.benchmarkValue,
    this.percentile,
    this.grade,
    this.notes,
    required this.recordedAt,
    required this.createdAt,
    this.assessment,
    this.category,
  });

  // Convenience accessor used by your UI which expects `.value`
  dynamic get value => metricValue;

  // Safe date parsing helper
  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is DateTime) return v;
    return DateTime.parse(v.toString());
  }

  // Factory from Supabase JSON with defensive parsing
  factory PerformanceMetric.fromSupabaseJson(Map<String, dynamic> json) {
    // metric_value may be num or string or null
    final metricValNum = (json['metric_value'] is num)
        ? (json['metric_value'] as num).toDouble()
        : (double.tryParse(json['metric_value']?.toString() ?? '') ?? 0.0);

    final benchmarkNum = (json['benchmark_value'] is num)
        ? (json['benchmark_value'] as num).toDouble()
        : double.tryParse(json['benchmark_value']?.toString() ?? '');

    final percentileNum = (json['percentile'] is num)
        ? (json['percentile'] as num).toDouble()
        : double.tryParse(json['percentile']?.toString() ?? '');

    return PerformanceMetric(
      id: json['id']?.toString() ?? '',
      assessmentId: json['assessment_id']?.toString() ?? '',
      athleteId: json['athlete_id']?.toString() ?? '',
      metricName: json['metric_name']?.toString() ?? 'Unknown',
      metricValue: metricValNum,
      metricUnit: json['metric_unit']?.toString(),
      benchmarkValue: benchmarkNum,
      percentile: percentileNum,
      grade: json['grade']?.toString(),
      notes: json['notes']?.toString(),
      recordedAt: _parseDate(json['recorded_at']),
      createdAt: _parseDate(json['created_at']),
      assessment: (json['assessment'] is Map)
          ? Map<String, dynamic>.from(json['assessment'])
          : null,
      // try common keys for category if backend uses different names
      category: json['category']?.toString() ??
          json['type']?.toString() ??
          json['metric_type']?.toString(),
    );
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'assessment_id': assessmentId,
      'athlete_id': athleteId,
      'metric_name': metricName,
      'metric_value': metricValue,
      'metric_unit': metricUnit,
      'benchmark_value': benchmarkValue,
      'percentile': percentile,
      'grade': grade,
      'notes': notes,
      'category': category,
      // optionally include timestamps if you want to write them back:
      // 'recorded_at': recordedAt.toIso8601String(),
      // 'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper methods
  bool get hasBenchmark => benchmarkValue != null;
  bool get hasPercentile => percentile != null;
  bool get hasGrade => grade != null;

  /// Main metric value with unit
  String get formattedValue {
    if (metricUnit != null && metricUnit!.isNotEmpty) {
      return '${metricValue.toStringAsFixed(2)} $metricUnit';
    }
    return metricValue.toStringAsFixed(2);
  }

  /// Benchmark value with unit
  String? get formattedBenchmark {
    if (benchmarkValue != null) {
      if (metricUnit != null && metricUnit!.isNotEmpty) {
        return '${benchmarkValue!.toStringAsFixed(2)} $metricUnit';
      }
      return benchmarkValue!.toStringAsFixed(2);
    }
    return null;
  }

  /// Percentile value with % sign
  String? get formattedPercentile {
    if (percentile != null) {
      return '${percentile!.toStringAsFixed(1)}%';
    }
    return null;
  }

  /// Grade or derived level
  String get performanceLevel {
    if (grade != null) return grade!;
    if (percentile != null) {
      if (percentile! >= 90) return 'Excellent';
      if (percentile! >= 75) return 'Good';
      if (percentile! >= 50) return 'Average';
      if (percentile! >= 25) return 'Below Average';
      return 'Poor';
    }
    return 'Unknown';
  }

  // Performance compared to benchmark
  double? get performanceRatio {
    if (benchmarkValue == null || benchmarkValue == 0) return null;
    return metricValue / benchmarkValue!;
  }

  bool get isAboveBenchmark {
    final ratio = performanceRatio;
    return ratio != null && ratio > 1.0;
  }

  PerformanceMetric copyWith({
    String? id,
    String? assessmentId,
    String? athleteId,
    String? metricName,
    double? metricValue,
    String? metricUnit,
    double? benchmarkValue,
    double? percentile,
    String? grade,
    String? notes,
    DateTime? recordedAt,
    DateTime? createdAt,
    Map<String, dynamic>? assessment,
    String? category,
  }) {
    return PerformanceMetric(
      id: id ?? this.id,
      assessmentId: assessmentId ?? this.assessmentId,
      athleteId: athleteId ?? this.athleteId,
      metricName: metricName ?? this.metricName,
      metricValue: metricValue ?? this.metricValue,
      metricUnit: metricUnit ?? this.metricUnit,
      benchmarkValue: benchmarkValue ?? this.benchmarkValue,
      percentile: percentile ?? this.percentile,
      grade: grade ?? this.grade,
      notes: notes ?? this.notes,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
      assessment: assessment ?? this.assessment,
      category: category ?? this.category,
    );
  }
}
