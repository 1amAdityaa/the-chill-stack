import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sai_sports_app/models/AssessmentVideo.dart';
import 'package:sai_sports_app/models/performance_matrix.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_database_service.dart';
import '../services/supabase_storage_service.dart';
import '../models/assessment.dart';
// import '../models/performance_metric.dart';

class AssessmentServiceProvider with ChangeNotifier {
  final SupabaseDatabaseService _databaseService = SupabaseDatabaseService();
  final SupabaseStorageService _storageService = SupabaseStorageService();
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Assessment> _assessments = [];
  List<PerformanceMetric> _currentMetrics = [];
  bool _isLoading = false;
  String? _error;

  // Realtime subscriptions
  RealtimeChannel? _assessmentSubscription;
  RealtimeChannel? _metricsSubscription;

  // Getters
  List<Assessment> get assessments => _assessments;
  List<PerformanceMetric> get currentMetrics => _currentMetrics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered getters
  List<Assessment> get pendingAssessments =>
      _assessments.where((a) => a.status == 'pending').toList();

  List<Assessment> get inProgressAssessments =>
      _assessments.where((a) => a.status == 'in_progress').toList();

  List<Assessment> get completedAssessments =>
      _assessments.where((a) => a.status == 'completed').toList();

  // === ASSESSMENT MANAGEMENT ===

  Future<void> loadAssessments(String userId) async {
    _setLoading(true);
    try {
      final data = await _databaseService.getAssessments(userId);
      _assessments =
          data.map((json) => Assessment.fromSupabaseJson(json)).toList();
      _error = null;
      _setupAssessmentSubscription(userId);
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<Assessment> createAssessment({
    required String athleteId,
    String? coachId,
    required String sport,
    required String assessmentType,
    DateTime? scheduledDate,
    String? location,
    String? notes,
  }) async {
    _setLoading(true);
    try {
      final data = await _databaseService.createAssessment(
        athleteId: athleteId,
        coachId: coachId,
        sport: sport,
        assessmentType: assessmentType,
        scheduledDate: scheduledDate,
        location: location,
        notes: notes,
      );

      final assessment = Assessment.fromSupabaseJson(data);
      _assessments.insert(0, assessment);
      _error = null;
      notifyListeners();
      return assessment;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAssessmentStatus(
      String assessmentId, String status) async {
    try {
      await _databaseService.updateAssessmentStatus(assessmentId, status);

      // Update local state
      final index = _assessments.indexWhere((a) => a.id == assessmentId);
      if (index != -1) {
        _assessments[index] = _assessments[index].copyWith(
          status: status,
          completedDate: status == 'completed' ? DateTime.now() : null,
        );
        notifyListeners();
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
  }

  // === PERFORMANCE METRICS ===

  Future<void> loadPerformanceMetrics(String assessmentId) async {
    _setLoading(true);
    try {
      final data = await _databaseService.getPerformanceMetrics(assessmentId);
      _currentMetrics =
          data.map((json) => PerformanceMetric.fromSupabaseJson(json)).toList();
      _error = null;
      _setupMetricsSubscription(assessmentId);
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  Future<void> addPerformanceMetric({
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
    try {
      await _databaseService.insertPerformanceMetric(
        assessmentId: assessmentId,
        athleteId: athleteId,
        metricName: metricName,
        metricValue: metricValue,
        metricUnit: metricUnit,
        benchmarkValue: benchmarkValue,
        percentile: percentile,
        grade: grade,
        notes: notes,
      );

      // Reload metrics to get the latest data
      await loadPerformanceMetrics(assessmentId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
  }

  // === VIDEO ANALYSIS ===

  Future<String> uploadAssessmentVideo({
    required String filePath,
    required String assessmentId,
    required String athleteId,
    required String assessmentType,
    Map<String, dynamic>? analysisData,
  }) async {
    _setLoading(true);
    try {
      // Upload video to storage
      final videoUrl = await _storageService.uploadAssessmentVideo(
        filePath: filePath,
        userId: athleteId,
        testId: assessmentId,
      );

      // Save video analysis record to database
      final videoAnalysisId = await _databaseService.insertVideoAnalysis(
        assessmentId: assessmentId,
        athleteId: athleteId,
        videoUrl: videoUrl,
        analysisData: analysisData,
      );

      _error = null;
      return videoAnalysisId;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateVideoAnalysis(
    String videoAnalysisId,
    String status, {
    Map<String, dynamic>? analysisData,
    Map<String, dynamic>? aiInsights,
    Map<String, dynamic>? cheatDetectionResult,
  }) async {
    try {
      await _databaseService.updateVideoAnalysisStatus(
        videoAnalysisId,
        status,
        analysisData: analysisData,
        aiInsights: aiInsights,
        cheatDetectionResult: cheatDetectionResult,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
  }

  // === ATHLETE PERFORMANCE HISTORY ===

  Future<List<PerformanceMetric>> getAthletePerformanceHistory(
      String athleteId) async {
    try {
      final data =
          await _databaseService.getAthletePerformanceHistory(athleteId);
      return data
          .map((json) => PerformanceMetric.fromSupabaseJson(json))
          .toList();
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }

  Future<Map<String, dynamic>> uploadVideoForAssessment({
    required String assessmentId,
    required File videoFile,
    required String exerciseName,
  }) async {
    _setLoading(true);
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${assessmentId}_${exerciseName}_$timestamp.mp4';
      final filePath = 'assessments/$assessmentId/videos/$fileName';

      // Upload video to Supabase storage
      final bytes = await videoFile.readAsBytes();
      await _supabase.storage
          .from('assessment-videos')
          .uploadBinary(filePath, bytes);

      // Get public URL
      final videoUrl =
          _supabase.storage.from('assessment-videos').getPublicUrl(filePath);

      // Save video record to database
      final videoRecord = await _supabase
          .from('assessment_videos')
          .insert({
            'assessment_id': assessmentId,
            'exercise_name': exerciseName,
            'video_url': videoUrl,
            'file_path': filePath,
            'upload_date': DateTime.now().toIso8601String(),
            'status': 'uploaded',
          })
          .select()
          .single();

      // Trigger video analysis (this would integrate with your AI analysis service)
      final analysisResult = await _analyzeVideo(videoUrl, exerciseName);

      // Update video record with analysis
      await _supabase.from('assessment_videos').update({
        'analysis_result': analysisResult,
        'status': 'analyzed',
        'analyzed_at': DateTime.now().toIso8601String(),
      }).eq('id', videoRecord['id']);

      // Create performance metrics from analysis
      await _createMetricsFromAnalysis(
        assessmentId: assessmentId,
        analysisResult: analysisResult,
        exerciseName: exerciseName,
      );

      _clearError();
      return {
        'success': true,
        'videoUrl': videoUrl,
        'analysis': analysisResult,
      };
    } catch (e) {
      _setError('Failed to upload video: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createMetricsFromAnalysis({
    required String assessmentId,
    required String analysisResult,
    required String exerciseName,
  }) async {
    try {
      // Extract performance data from analysis (in a real app, this would be structured data)
      final assessment = getAssessmentById(assessmentId);
      if (assessment == null) return;

      // Create sample metrics based on exercise type
      final metrics = _generateMetricsFromExercise(exerciseName);

      for (final metric in metrics) {
        await _supabase.from('performance_metrics').insert({
          'assessment_id': assessmentId,
          'athlete_id': assessment.athleteId,
          'metric_name': metric['name'],
          'metric_value': metric['value'],
          'metric_unit': metric['unit'],
          'benchmark_value': metric['benchmark'],
          'percentile': metric['percentile'],
          'grade': metric['grade'],
          'notes': 'Generated from video analysis: $exerciseName',
          'category': 'Video Analysis',
          'recorded_at': DateTime.now().toIso8601String(),
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print('Error creating metrics from analysis: $e');
    }
  }

  List<Map<String, dynamic>> _generateMetricsFromExercise(String exerciseName) {
    switch (exerciseName.toLowerCase()) {
      case 'push-ups':
        return [
          {
            'name': 'Push-ups Completed',
            'value': 25.0,
            'unit': 'reps',
            'benchmark': 20.0,
            'percentile': 75.0,
            'grade': 'B+',
          },
          {
            'name': 'Form Quality Score',
            'value': 8.0,
            'unit': '/10',
            'benchmark': 7.0,
            'percentile': 70.0,
            'grade': 'B',
          },
        ];

      case 'sprint test':
        return [
          {
            'name': '20m Sprint Time',
            'value': 3.2,
            'unit': 'seconds',
            'benchmark': 3.5,
            'percentile': 82.0,
            'grade': 'A-',
          },
        ];

      case 'flexibility test':
        return [
          {
            'name': 'Forward Reach',
            'value': 15.0,
            'unit': 'cm',
            'benchmark': 10.0,
            'percentile': 68.0,
            'grade': 'B',
          },
        ];

      default:
        return [
          {
            'name': 'Overall Performance',
            'value': 7.5,
            'unit': '/10',
            'benchmark': 7.0,
            'percentile': 65.0,
            'grade': 'B',
          },
        ];
    }
  }

  // === REALTIME SUBSCRIPTIONS ===

  void _setupAssessmentSubscription(String userId) {
    _assessmentSubscription?.unsubscribe();
    _assessmentSubscription = _databaseService.subscribeToAssessments(
      userId,
      (assessments) {
        _assessments = assessments
            .map((json) => Assessment.fromSupabaseJson(json))
            .toList();
        notifyListeners();
      },
    );
  }

  Future<String> _analyzeVideo(String videoUrl, String exerciseName) async {
    try {
      // This is where you would integrate with your AI analysis service
      // For now, we'll simulate the analysis
      await Future.delayed(Duration(seconds: 2)); // Simulate processing time

      // Mock analysis results based on exercise type
      switch (exerciseName.toLowerCase()) {
        case 'push-ups':
          return '''
Performance Analysis for Push-ups:
• Completed: 25 push-ups in 60 seconds
• Form Quality: Good (8/10)
• Consistency: Maintained good form for 80% of repetitions
• Areas for Improvement: Keep core engaged throughout, maintain straight line from head to heels
• Estimated Percentile: 75th percentile for age group
• Grade: B+

Recommendations:
- Focus on core strengthening exercises
- Practice slower, more controlled movements
- Work on maintaining proper alignment
          ''';

        case 'sprint test':
          return '''
Performance Analysis for Sprint Test:
• 20m Time: 3.2 seconds
• Acceleration Phase: Strong start, good drive phase
• Maximum Velocity: Achieved at 15m mark
• Running Mechanics: Good arm swing, slight overstride detected
• Estimated Percentile: 82nd percentile for age group
• Grade: A-

Recommendations:
- Work on stride frequency over stride length
- Implement acceleration drills
- Focus on forward lean during start phase
          ''';

        case 'flexibility test':
          return '''
Performance Analysis for Flexibility Test:
• Forward Reach: 15cm past toes
• Form Assessment: Good spinal flexion, controlled movement
• Hold Quality: Stable throughout test duration
• Range of Motion: Above average for age group
• Estimated Percentile: 68th percentile for age group
• Grade: B

Recommendations:
- Continue regular stretching routine
- Add dynamic warm-up before activities
- Focus on hip flexor flexibility
          ''';

        default:
          return '''
Performance Analysis Complete:
• Exercise execution analyzed successfully
• Form and technique assessed
• Performance metrics calculated
• Personalized recommendations generated

Your video has been processed and performance data has been recorded.
Detailed feedback will be available in your assessment dashboard.
          ''';
      }
    } catch (e) {
      return 'Analysis completed. Results will be available shortly.';
    }
  }

  void _setupMetricsSubscription(String assessmentId) {
    _metricsSubscription?.unsubscribe();
    _metricsSubscription = _databaseService.subscribeToPerformanceMetrics(
      assessmentId,
      (metrics) {
        _currentMetrics = metrics
            .map((json) => PerformanceMetric.fromSupabaseJson(json))
            .toList();
        notifyListeners();
      },
    );
  }

  // === UTILITY METHODS ===

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Assessment? getAssessmentById(String id) {
    try {
      return _assessments.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Assessment> getAssessmentsByType(String type) {
    return _assessments.where((a) => a.assessmentType == type).toList();
  }

  List<Assessment> getAssessmentsBySport(String sport) {
    return _assessments.where((a) => a.sport == sport).toList();
  }

  Future<List<AssessmentVideo>> getAssessmentVideos(String assessmentId) async {
    _setLoading(true);
    try {
      final response = await _supabase
          .from('assessment_videos')
          .select()
          .eq('assessment_id', assessmentId)
          .order('created_at', ascending: false);

      final videos = (response as List)
          .map((json) => AssessmentVideo.fromJson(json))
          .toList();

      _clearError();
      return videos;
    } catch (e) {
      _setError("Failed to fetch assessment videos: $e");
      return [];
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteAssessmentVideo(
    String videoId,
  ) async {
    _setLoading(true);
    try {
      // Fetch the video record from DB
      final videoRecord = await _supabase
          .from('assessment_videos')
          .select()
          .eq('id', videoId)
          .maybeSingle();

      if (videoRecord == null) {
        _setError("Video record not found.");
        return false;
      }

      final filePath = videoRecord['file_path'] as String?;

      // Delete video from Supabase storage
      if (filePath != null && filePath.isNotEmpty) {
        await _supabase.storage.from('assessment-videos').remove([filePath]);
      }

      // Delete record from DB
      await _supabase.from('assessment_videos').delete().eq('id', videoId);

      _clearError();
      return true;
    } catch (e) {
      _setError("Failed to delete video: $e");
      return false;
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _assessmentSubscription?.unsubscribe();
    _metricsSubscription?.unsubscribe();
    super.dispose();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}
