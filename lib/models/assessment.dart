class Assessment {
  final String id;
  final String athleteId;
  final String? coachId;
  final String sport;
  final String assessmentType; // 'physical', 'technical', 'tactical', 'mental'
  final String status; // 'pending', 'in_progress', 'completed', 'reviewed'
  final DateTime? scheduledDate;
  final DateTime? completedDate;
  final String? location;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related data (populated from joins)
  final Map<String, dynamic>? athlete;
  final Map<String, dynamic>? coach;

  Assessment({
    required this.id,
    required this.athleteId,
    this.coachId,
    required this.sport,
    required this.assessmentType,
    required this.status,
    this.scheduledDate,
    this.completedDate,
    this.location,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.athlete,
    this.coach,
  });

  factory Assessment.fromSupabaseJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'],
      athleteId: json['athlete_id'],
      coachId: json['coach_id'],
      sport: json['sport'],
      assessmentType: json['assessment_type'],
      status: json['status'],
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'])
          : null,
      completedDate: json['completed_date'] != null
          ? DateTime.parse(json['completed_date'])
          : null,
      location: json['location'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      athlete: json['athlete'],
      coach: json['coach'],
    );
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'athlete_id': athleteId,
      'coach_id': coachId,
      'sport': sport,
      'assessment_type': assessmentType,
      'status': status,
      'scheduled_date': scheduledDate?.toIso8601String(),
      'completed_date': completedDate?.toIso8601String(),
      'location': location,
      'notes': notes,
    };
  }

  // Helper methods
  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isReviewed => status == 'reviewed';

  String get athleteName => athlete?['full_name'] ?? 'Unknown Athlete';
  String get coachName => coach?['full_name'] ?? 'No Coach Assigned';

  Assessment copyWith({
    String? id,
    String? athleteId,
    String? coachId,
    String? sport,
    String? assessmentType,
    String? status,
    DateTime? scheduledDate,
    DateTime? completedDate,
    String? location,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? athlete,
    Map<String, dynamic>? coach,
  }) {
    return Assessment(
      id: id ?? this.id,
      athleteId: athleteId ?? this.athleteId,
      coachId: coachId ?? this.coachId,
      sport: sport ?? this.sport,
      assessmentType: assessmentType ?? this.assessmentType,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      completedDate: completedDate ?? this.completedDate,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      athlete: athlete ?? this.athlete,
      coach: coach ?? this.coach,
    );
  }
}
