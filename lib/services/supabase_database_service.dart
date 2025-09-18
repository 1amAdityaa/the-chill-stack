import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDatabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // === ASSESSMENTS ===

  // Create new assessment
  Future<Map<String, dynamic>> createAssessment({
    required String athleteId,
    String? coachId,
    required String sport,
    required String
        assessmentType, // 'physical', 'technical', 'tactical', 'mental'
    DateTime? scheduledDate,
    String? location,
    String? notes,
  }) async {
    final response = await _client
        .from('assessments')
        .insert({
          'athlete_id': athleteId,
          'coach_id': coachId,
          'sport': sport,
          'assessment_type': assessmentType,
          'scheduled_date': scheduledDate?.toIso8601String(),
          'location': location,
          'notes': notes,
        })
        .select()
        .single();

    return response;
  }

  // Get assessments for user (athlete or coach)
  Future<List<Map<String, dynamic>>> getAssessments(String userId) async {
    final response = await _client
        .from('assessments')
        .select('''
          *,
          athlete:profiles!athlete_id(full_name, sport),
          coach:profiles!coach_id(full_name)
        ''')
        .or('athlete_id.eq.$userId,coach_id.eq.$userId')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Update assessment status
  Future<void> updateAssessmentStatus(
      String assessmentId, String status) async {
    await _client.from('assessments').update({
      'status': status,
      if (status == 'completed')
        'completed_date': DateTime.now().toIso8601String(),
    }).eq('id', assessmentId);
  }

  // === PERFORMANCE METRICS ===

  // Insert performance metric
  Future<void> insertPerformanceMetric({
    required String assessmentId,
    required String athleteId,
    required String metricName,
    required double metricValue,
    String? metricUnit,
    double? benchmarkValue,
    double? percentile,
    String? grade,
    String? notes,
  }) async {
    await _client.from('performance_metrics').insert({
      'assessment_id': assessmentId,
      'athlete_id': athleteId,
      'metric_name': metricName,
      'metric_value': metricValue,
      'metric_unit': metricUnit,
      'benchmark_value': benchmarkValue,
      'percentile': percentile,
      'grade': grade,
      'notes': notes,
    });
  }

  // Get performance metrics for assessment
  Future<List<Map<String, dynamic>>> getPerformanceMetrics(
      String assessmentId) async {
    final response = await _client
        .from('performance_metrics')
        .select()
        .eq('assessment_id', assessmentId)
        .order('recorded_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Get athlete's performance history
  Future<List<Map<String, dynamic>>> getAthletePerformanceHistory(
      String athleteId) async {
    final response = await _client.from('performance_metrics').select('''
          *,
          assessment:assessments(sport, assessment_type, completed_date)
        ''').eq('athlete_id', athleteId).order('recorded_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // === VIDEO ANALYSIS ===

  // Insert video analysis
  Future<String> insertVideoAnalysis({
    required String assessmentId,
    required String athleteId,
    required String videoUrl,
    Map<String, dynamic>? analysisData,
    Map<String, dynamic>? aiInsights,
    Map<String, dynamic>? cheatDetectionResult,
  }) async {
    final response = await _client
        .from('video_analysis')
        .insert({
          'assessment_id': assessmentId,
          'athlete_id': athleteId,
          'video_url': videoUrl,
          'analysis_data': analysisData,
          'ai_insights': aiInsights,
          'cheat_detection_result': cheatDetectionResult,
          'processing_status': 'pending',
        })
        .select('id')
        .single();

    return response['id'];
  }

  // Update video analysis processing status
  Future<void> updateVideoAnalysisStatus(
    String videoAnalysisId,
    String status, {
    Map<String, dynamic>? analysisData,
    Map<String, dynamic>? aiInsights,
    Map<String, dynamic>? cheatDetectionResult,
  }) async {
    final updateData = <String, dynamic>{
      'processing_status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (analysisData != null) updateData['analysis_data'] = analysisData;
    if (aiInsights != null) updateData['ai_insights'] = aiInsights;
    if (cheatDetectionResult != null)
      updateData['cheat_detection_result'] = cheatDetectionResult;

    await _client
        .from('video_analysis')
        .update(updateData)
        .eq('id', videoAnalysisId);
  }

  // Get video analysis for assessment
  Future<List<Map<String, dynamic>>> getVideoAnalysis(
      String assessmentId) async {
    final response = await _client
        .from('video_analysis')
        .select()
        .eq('assessment_id', assessmentId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // === PROFILES ===

  // Get athletes (for coaches)
  Future<List<Map<String, dynamic>>> getAthletes({
    String? sport,
    String? state,
    String? district,
  }) async {
    var query = _client.from('profiles').select().eq('role', 'athlete');

    if (sport != null) query = query.eq('sport', sport);
    if (state != null) query = query.eq('state', state);
    if (district != null) query = query.eq('district', district);

    final response = await query.order('full_name');
    return List<Map<String, dynamic>>.from(response);
  }

  // Get coaches
  Future<List<Map<String, dynamic>>> getCoaches({String? sport}) async {
    var query = _client.from('profiles').select().eq('role', 'coach');

    if (sport != null) query = query.eq('sport', sport);

    final response = await query.order('full_name');
    return List<Map<String, dynamic>>.from(response);
  }

  // === REAL-TIME SUBSCRIPTIONS ===

  // Subscribe to assessment changes
  RealtimeChannel subscribeToAssessments(
      String userId, Function(List<Map<String, dynamic>>) onData) {
    final channel = _client.channel('user_assessments_$userId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'assessments',
      callback: (payload) async {
        final assessments = await getAssessments(userId);
        onData(assessments);
      },
    );

    channel.subscribe();
    return channel;
  }

  // Subscribe to performance metrics changes
  RealtimeChannel subscribeToPerformanceMetrics(
      String assessmentId, Function(List<Map<String, dynamic>>) onData) {
    final channel = _client.channel('metrics_$assessmentId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'performance_metrics',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'assessment_id',
        value: assessmentId,
      ),
      callback: (payload) async {
        final metrics = await getPerformanceMetrics(assessmentId);
        onData(metrics);
      },
    );

    channel.subscribe();
    return channel;
  }

  // Subscribe to video analysis updates
  RealtimeChannel subscribeToVideoAnalysis(
      String assessmentId, Function(List<Map<String, dynamic>>) onData) {
    final channel = _client.channel('video_analysis_$assessmentId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'video_analysis',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'assessment_id',
        value: assessmentId,
      ),
      callback: (payload) async {
        final videos = await getVideoAnalysis(assessmentId);
        onData(videos);
      },
    );

    channel.subscribe();
    return channel;
  }
}
