import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Upload video file (for tests or general videos)
  Future<String> uploadVideo({
    required String filePath,
    required String userId,
    required String testId,
  }) async {
    final file = File(filePath);
    final fileName =
        '${userId}/${testId}_${DateTime.now().millisecondsSinceEpoch}.mp4';

    await _client.storage.from('test-videos').upload(fileName, file);

    return _client.storage.from('test-videos').getPublicUrl(fileName);
  }

  // Upload profile picture
  Future<String> uploadProfilePicture({
    required String filePath,
    required String userId,
  }) async {
    final file = File(filePath);
    final fileName =
        '${userId}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _client.storage.from('profile-pictures').upload(fileName, file);

    return _client.storage.from('profile-pictures').getPublicUrl(fileName);
  }

  // Upload assessment video (new method added)
  Future<String> uploadAssessmentVideo({
    required String filePath,
    required String userId,
    required String testId,
  }) async {
    final file = File(filePath);
    final fileName =
        '${userId}/assessment_${testId}_${DateTime.now().millisecondsSinceEpoch}.mp4';

    await _client.storage.from('assessment-videos').upload(fileName, file);

    return _client.storage.from('assessment-videos').getPublicUrl(fileName);
  }

  // Delete file from any bucket
  Future<void> deleteFile({
    required String bucket,
    required String fileName,
  }) async {
    await _client.storage.from(bucket).remove([fileName]);
  }
}
