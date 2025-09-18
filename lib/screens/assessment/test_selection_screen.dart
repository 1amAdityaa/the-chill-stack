// import 'package:flutter/material.dart';
// import 'camera_screen.dart';

// class TestSelectionScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Select Test'),
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.info_outline,
//                       color: Theme.of(context).primaryColor,
//                     ),
//                     const SizedBox(width: 12),
//                     const Expanded(
//                       child: Text(
//                         'Choose a fitness test to record your performance. AI will analyze your video for accuracy.',
//                         style: TextStyle(fontSize: 14),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Expanded(
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 16,
//                 mainAxisSpacing: 16,
//                 children: [
//                   _buildTestCard(
//                     context,
//                     'Vertical Jump',
//                     'vertical_jump',
//                     Icons.trending_up,
//                     Colors.blue,
//                     'Measure your explosive leg power',
//                   ),
//                   _buildTestCard(
//                     context,
//                     'Shuttle Run',
//                     'shuttle_run',
//                     Icons.directions_run,
//                     Colors.orange,
//                     'Test your agility and speed',
//                   ),
//                   _buildTestCard(
//                     context,
//                     'Sit-ups',
//                     'sit_ups',
//                     Icons.accessibility_new,
//                     Colors.green,
//                     'Measure core strength',
//                   ),
//                   _buildTestCard(
//                     context,
//                     'Endurance Run',
//                     'endurance_run',
//                     Icons.timer,
//                     Colors.red,
//                     'Test cardiovascular fitness',
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTestCard(
//     BuildContext context,
//     String title,
//     String testType,
//     IconData icon,
//     Color color,
//     String description,
//   ) {
//     return Card(
//       elevation: 4,
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) =>
//                   CameraScreen(testType: testType, testTitle: title),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(30),
//                 ),
//                 child: Icon(icon, size: 30, color: color),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 description,
//                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
