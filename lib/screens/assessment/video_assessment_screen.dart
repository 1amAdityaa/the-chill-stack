import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../../providers/assessment_provider.dart';
import '../../providers/supabase_auth_provider.dart';
import '../../models/assessment.dart';

class VideoAssessmentScreen extends StatefulWidget {
  final String assessmentId;
  final String assessmentType;

  const VideoAssessmentScreen({
    Key? key,
    required this.assessmentId,
    required this.assessmentType,
  }) : super(key: key);

  @override
  _VideoAssessmentScreenState createState() => _VideoAssessmentScreenState();
}

class _VideoAssessmentScreenState extends State<VideoAssessmentScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  // Camera related
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _isUploading = false;

  // Video related
  VideoPlayerController? _videoPlayerController;
  File? _recordedVideoFile;
  File? _selectedVideoFile;

  // UI related
  late TabController _tabController;
  String _currentTab = 'record'; // 'record' or 'upload'
  double _uploadProgress = 0.0;
  String? _analysisResult;

  // Assessment exercises based on type
  List<Map<String, dynamic>> _exercises = [];
  int _currentExerciseIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 2, vsync: this);
    _setupExercises();
    _initializeCamera();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cameraController?.dispose();
    _videoPlayerController?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _setupExercises() {
    // Define exercises based on assessment type
    switch (widget.assessmentType.toLowerCase()) {
      case 'physical':
        _exercises = [
          {
            'name': 'Push-ups',
            'duration': 60,
            'description': 'Perform as many push-ups as possible in 60 seconds',
            'instructions':
                'Keep your body straight, lower until chest nearly touches ground',
          },
          {
            'name': 'Sprint Test',
            'duration': 30,
            'description': '20-meter sprint test',
            'instructions': 'Run as fast as possible for 20 meters',
          },
          {
            'name': 'Flexibility Test',
            'duration': 45,
            'description': 'Forward bend flexibility assessment',
            'instructions': 'Slowly bend forward and hold the position',
          },
        ];
        break;
      case 'technical':
        _exercises = [
          {
            'name': 'Ball Control',
            'duration': 90,
            'description': 'Demonstrate ball control skills',
            'instructions': 'Show various ball control techniques',
          },
          {
            'name': 'Passing Accuracy',
            'duration': 120,
            'description': 'Passing accuracy demonstration',
            'instructions': 'Demonstrate accurate passes to targets',
          },
        ];
        break;
      case 'tactical':
        _exercises = [
          {
            'name': 'Decision Making',
            'duration': 180,
            'description': 'Tactical decision-making scenario',
            'instructions': 'Demonstrate tactical awareness in game situations',
          },
        ];
        break;
      default:
        _exercises = [
          {
            'name': 'General Assessment',
            'duration': 120,
            'description': 'General sports performance assessment',
            'instructions': 'Demonstrate your sporting abilities',
          },
        ];
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Request permissions
      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      if (!cameraStatus.isGranted || !micStatus.isGranted) {
        _showPermissionDialog();
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _showErrorDialog('No cameras available');
        return;
      }

      // Initialize camera controller
      _cameraController = CameraController(
        _cameras.first,
        ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to initialize camera: $e');
    }
  }

  Future<void> _startRecording() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });

      // Auto-stop recording after exercise duration
      final exercise = _exercises[_currentExerciseIndex];
      Future.delayed(Duration(seconds: exercise['duration']), () {
        if (_isRecording) {
          _stopRecording();
        }
      });
    } catch (e) {
      _showErrorDialog('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording || _cameraController == null) return;

    try {
      final videoFile = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _recordedVideoFile = File(videoFile.path);
      });

      _initializeVideoPlayer(_recordedVideoFile!);
    } catch (e) {
      _showErrorDialog('Failed to stop recording: $e');
    }
  }

  Future<void> _pickVideoFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final videoFile = File(result.files.single.path!);
        setState(() {
          _selectedVideoFile = videoFile;
        });

        _initializeVideoPlayer(videoFile);
      }
    } catch (e) {
      _showErrorDialog('Failed to pick video: $e');
    }
  }

  Future<void> _initializeVideoPlayer(File videoFile) async {
    try {
      _videoPlayerController?.dispose();
      _videoPlayerController = VideoPlayerController.file(videoFile);
      await _videoPlayerController!.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _showErrorDialog('Failed to load video: $e');
    }
  }

  Future<void> _uploadAndAnalyzeVideo() async {
    final videoFile =
        _currentTab == 'record' ? _recordedVideoFile : _selectedVideoFile;
    if (videoFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final assessmentProvider =
          Provider.of<AssessmentServiceProvider>(context, listen: false);

      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        await Future.delayed(Duration(milliseconds: 200));
        if (mounted) {
          setState(() {
            _uploadProgress = i / 100.0;
          });
        }
      }

      // Upload video and get analysis
      final result = await assessmentProvider.uploadVideoForAssessment(
        assessmentId: widget.assessmentId,
        videoFile: videoFile,
        exerciseName: _exercises[_currentExerciseIndex]['name'],
      );

      setState(() {
        _isUploading = false;
        _analysisResult = result['analysis'] ?? 'Video uploaded successfully!';
      });

      _showAnalysisDialog();
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showErrorDialog('Upload failed: $e');
    }
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _recordedVideoFile = null;
        _selectedVideoFile = null;
        _videoPlayerController?.dispose();
        _videoPlayerController = null;
      });
    } else {
      _completeAssessment();
    }
  }

  void _completeAssessment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Assessment Complete'),
        content: Text(
            'All exercises have been completed. Your videos will be analyzed and results will be available soon.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: Text('Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Video Assessment', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          onTap: (index) {
            setState(() {
              _currentTab = index == 0 ? 'record' : 'upload';
            });
          },
          tabs: [
            Tab(icon: Icon(Icons.videocam), text: 'Record'),
            Tab(icon: Icon(Icons.upload_file), text: 'Upload'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildExerciseHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildRecordTab(),
                _buildUploadTab(),
              ],
            ),
          ),
          if (_isUploading) _buildUploadProgress(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildExerciseHeader() {
    final exercise = _exercises[_currentExerciseIndex];

    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Exercise ${_currentExerciseIndex + 1} of ${_exercises.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Spacer(),
              Icon(Icons.timer, size: 16, color: Colors.grey.shade600),
              SizedBox(width: 4),
              Text(
                '${exercise['duration']}s',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            exercise['name'],
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            exercise['description'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    exercise['instructions'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _buildCameraPreview(),
              ),
            ),
          ),
          SizedBox(height: 20),
          if (_recordedVideoFile != null) _buildVideoPreview(),
        ],
      ),
    );
  }

  Widget _buildUploadTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: _selectedVideoFile == null
                ? _buildUploadPrompt()
                : _buildVideoPreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(_cameraController!),
        if (_isRecording)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'REC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: _isRecording ? _stopRecording : _startRecording,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.red : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _isRecording ? Colors.white : Colors.red,
                    width: 4,
                  ),
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.videocam,
                  color: _isRecording ? Colors.white : Colors.red,
                  size: 30,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPrompt() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload,
              size: 64,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'Upload Video',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Select a pre-recorded video from your device',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickVideoFile,
              icon: Icon(Icons.file_upload),
              label: Text('Choose Video'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return Container(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            VideoPlayer(_videoPlayerController!),
            Positioned.fill(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_videoPlayerController!.value.isPlaying) {
                        _videoPlayerController!.pause();
                      } else {
                        _videoPlayerController!.play();
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _videoPlayerController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Uploading and analyzing video...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.grey.shade300,
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          SizedBox(height: 4),
          Text(
            '${(_uploadProgress * 100).toInt()}%',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final hasVideo = (_currentTab == 'record' && _recordedVideoFile != null) ||
        (_currentTab == 'upload' && _selectedVideoFile != null);

    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          if (_currentExerciseIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentExerciseIndex--;
                    _recordedVideoFile = null;
                    _selectedVideoFile = null;
                    _videoPlayerController?.dispose();
                    _videoPlayerController = null;
                  });
                },
                child: Text('Previous'),
              ),
            ),
          if (_currentExerciseIndex > 0) SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed:
                  hasVideo && !_isUploading ? _uploadAndAnalyzeVideo : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isUploading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Submit & Analyze'),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: hasVideo ? _nextExercise : null,
              child: Text(_currentExerciseIndex == _exercises.length - 1
                  ? 'Finish'
                  : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permissions Required'),
        content: Text(
            'Camera and microphone permissions are required for video recording.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAnalysisDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Analysis Complete'),
        content: SingleChildScrollView(
          child: Text(_analysisResult ?? 'Analysis completed successfully!'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
