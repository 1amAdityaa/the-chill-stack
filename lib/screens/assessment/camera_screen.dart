// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:camera/camera.dart';
// import '../../providers/camera_provider.dart';
// import '../../providers/assessment_provider.dart';
// import 'analysis_screen.dart';

// class CameraScreen extends StatefulWidget {
//   final String testType;
//   final String testTitle;

//   const CameraScreen({
//     Key? key,
//     required this.testType,
//     required this.testTitle,
//   }) : super(key: key);

//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   bool _isInstructionsVisible = true;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<CameraProvider>(context, listen: false).initializeCamera();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Consumer<CameraProvider>(
//         builder: (context, cameraProvider, child) {
//           if (cameraProvider.controller == null ||
//               !cameraProvider.controller!.value.isInitialized) {
//             return const Center(
//               child: CircularProgressIndicator(color: Colors.white),
//             );
//           }

//           return Stack(
//             children: [
//               // Camera Preview
//               Positioned.fill(
//                 child: AspectRatio(
//                   aspectRatio: cameraProvider.controller!.value.aspectRatio,
//                   child: CameraPreview(cameraProvider.controller!),
//                 ),
//               ),

//               // Instructions Overlay
//               if (_isInstructionsVisible) _buildInstructionsOverlay(),

//               // Top Bar
//               _buildTopBar(),

//               // Bottom Controls
//               _buildBottomControls(cameraProvider),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildInstructionsOverlay() {
//     return Container(
//       color: Colors.black.withOpacity(0.8),
//       child: Center(
//         child: Container(
//           margin: const EdgeInsets.all(24),
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 _getTestIcon(widget.testType),
//                 size: 48,
//                 color: Theme.of(context).primaryColor,
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 widget.testTitle,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 _getInstructions(widget.testType),
//                 style: const TextStyle(fontSize: 14),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('Cancel'),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _isInstructionsVisible = false;
//                         });
//                       },
//                       child: const Text('Start'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTopBar() {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             IconButton(
//               onPressed: () => Navigator.pop(context),
//               icon: const Icon(Icons.close, color: Colors.white),
//             ),
//             Expanded(
//               child: Text(
//                 widget.testTitle,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             IconButton(
//               onPressed: () {
//                 setState(() {
//                   _isInstructionsVisible = true;
//                 });
//               },
//               icon: const Icon(Icons.help_outline, color: Colors.white),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBottomControls(CameraProvider cameraProvider) {
//     return Positioned(
//       bottom: 0,
//       left: 0,
//       right: 0,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             const SizedBox(width: 60), // Placeholder for alignment
//             // Record Button
//             GestureDetector(
//               onTap: _isInstructionsVisible ? null : _toggleRecording,
//               child: Container(
//                 width: 80,
//                 height: 80,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: cameraProvider.isRecording ? Colors.red : Colors.white,
//                   border: Border.all(color: Colors.white, width: 4),
//                 ),
//                 child: cameraProvider.isRecording
//                     ? const Icon(Icons.stop, size: 32, color: Colors.white)
//                     : const Icon(Icons.videocam, size: 32, color: Colors.red),
//               ),
//             ),

//             // Gallery Button
//             Container(
//               width: 60,
//               height: 60,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               child: IconButton(
//                 onPressed: () {
//                   // Open gallery
//                 },
//                 icon: const Icon(Icons.photo_library, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _toggleRecording() async {
//     final cameraProvider = Provider.of<CameraProvider>(context, listen: false);

//     if (cameraProvider.isRecording) {
//       final videoPath = await cameraProvider.stopRecording();
//       if (videoPath != null) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => AnalysisScreen(
//               videoPath: videoPath,
//               testType: widget.testType,
//               testTitle: widget.testTitle,
//             ),
//           ),
//         );
//       }
//     } else {
//       await cameraProvider.startRecording();
//     }
//   }

//   // ✅ FIX: Added instructions generator
//   String _getInstructions(String testType) {
//     switch (testType) {
//       case 'vertical_jump':
//         return 'Stand straight, bend your knees, and jump as high as you can while keeping within the camera frame.';
//       case 'shuttle_run':
//         return 'Run back and forth between the two marked points as fast as possible until the timer stops.';
//       case 'sit_ups':
//         return 'Lie down on your back, bend your knees, and perform sit-ups until the test ends.';
//       case 'endurance_run':
//         return 'Run continuously for the set duration. Maintain a steady pace throughout.';
//       default:
//         return 'Follow the instructions displayed on screen for this test.';
//     }
//   }

//   IconData _getTestIcon(String testType) {
//     switch (testType) {
//       case 'vertical_jump':
//         return Icons.trending_up;
//       case 'shuttle_run':
//         return Icons.directions_run;
//       case 'sit_ups':
//         return Icons.accessibility_new;
//       case 'endurance_run':
//         return Icons.timer;
//       default:
//         return Icons.fitness_center;
//     }
//   }

//   Color _getTestColor(String testType) {
//     switch (testType) {
//       case 'vertical_jump':
//         return Colors.blue;
//       case 'shuttle_run':
//         return Colors.orange;
//       case 'sit_ups':
//         return Colors.green;
//       case 'endurance_run':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _getTestDisplayName(String testType) {
//     switch (testType) {
//       case 'vertical_jump':
//         return 'Vertical Jump';
//       case 'shuttle_run':
//         return 'Shuttle Run';
//       case 'sit_ups':
//         return 'Sit-ups';
//       case 'endurance_run':
//         return 'Endurance Run';
//       default:
//         return testType.replaceAll('_', ' ').toUpperCase();
//     }
//   }

//   String _getTestUnit(String testType) {
//     switch (testType) {
//       case 'vertical_jump':
//         return 'cm';
//       case 'shuttle_run':
//       case 'endurance_run':
//         return 'sec';
//       case 'sit_ups':
//         return 'reps';
//       default:
//         return '';
//     }
//   }

//   String _formatDateTime(DateTime dateTime) {
//     return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
//         '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
//   }
// }
