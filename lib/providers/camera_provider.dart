import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';

class CameraProvider with ChangeNotifier {
  CameraController? _controller;
  bool _isRecording = false;
  String? _videoPath;
  List<CameraDescription>? _cameras;

  CameraController? get controller => _controller;
  bool get isRecording => _isRecording;
  String? get videoPath => _videoPath;

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _controller!.initialize();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  Future<void> startRecording() async {
    if (_controller != null && !_isRecording) {
      try {
        await _controller!.startVideoRecording();
        _isRecording = true;
        notifyListeners();
      } catch (e) {
        debugPrint('Error starting recording: $e');
      }
    }
  }

  Future<String?> stopRecording() async {
    if (_controller != null && _isRecording) {
      try {
        final video = await _controller!.stopVideoRecording();
        _isRecording = false;
        _videoPath = video.path;
        notifyListeners();
        return video.path;
      } catch (e) {
        debugPrint('Error stopping recording: $e');
        _isRecording = false;
        notifyListeners();
      }
    }
    return null;
  }

  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
