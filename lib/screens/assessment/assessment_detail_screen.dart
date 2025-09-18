import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sai_sports_app/models/AssessmentVideo.dart';
import 'package:sai_sports_app/screens/performance/add_performance_screen.dart';
import 'package:sai_sports_app/screens/assessment/video_assessment_screen.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/supabase_auth_provider.dart';
import '../../models/assessment.dart';
import '../../models/performance_matrix.dart';

class AssessmentDetailScreen extends StatefulWidget {
  final String assessmentId;

  const AssessmentDetailScreen({Key? key, required this.assessmentId})
      : super(key: key);

  @override
  _AssessmentDetailScreenState createState() => _AssessmentDetailScreenState();
}

class _AssessmentDetailScreenState extends State<AssessmentDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Assessment? _assessment;
  List<AssessmentVideo> _assessmentVideos = [];
  bool _loadingVideos = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAssessmentData();
  }

  void _loadAssessmentData() {
    final assessmentProvider =
        Provider.of<AssessmentServiceProvider>(context, listen: false);
    _assessment = assessmentProvider.getAssessmentById(widget.assessmentId);

    if (_assessment != null) {
      assessmentProvider.loadPerformanceMetrics(widget.assessmentId);
      _loadAssessmentVideos();
    }
  }

  Future<void> _loadAssessmentVideos() async {
    setState(() {
      _loadingVideos = true;
    });

    final assessmentProvider =
        Provider.of<AssessmentServiceProvider>(context, listen: false);

    try {
      final List<AssessmentVideo> videos =
          await assessmentProvider.getAssessmentVideos(widget.assessmentId);

      setState(() {
        _assessmentVideos = videos;
      });
    } catch (e) {
      print('Error loading videos: $e');
    } finally {
      setState(() {
        _loadingVideos = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AssessmentServiceProvider>(
        builder: (context, provider, child) {
          final assessment = provider.getAssessmentById(widget.assessmentId);

          if (assessment == null) {
            return _buildNotFoundState();
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(assessment),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildAssessmentInfo(assessment),
                    _buildTabSection(assessment, provider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildSliverAppBar(Assessment assessment) {
    final Color statusColor = _getStatusColor(assessment.status);

    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: statusColor,
      iconTheme: const IconThemeData(color: Colors.white),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '${assessment.assessmentType.toUpperCase()} ASSESSMENT',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                statusColor,
                statusColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(
                  _getAssessmentIcon(assessment.assessmentType),
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    assessment.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) => _handleMenuAction(value, assessment),
          itemBuilder: (context) => [
            if (assessment.status == 'pending')
              const PopupMenuItem(
                value: 'start',
                child: Row(
                  children: [
                    Icon(Icons.play_arrow),
                    SizedBox(width: 8),
                    Text('Start Assessment'),
                  ],
                ),
              ),
            if (assessment.status == 'in_progress')
              const PopupMenuItem(
                value: 'complete',
                child: Row(
                  children: [
                    Icon(Icons.check_circle),
                    SizedBox(width: 8),
                    Text('Mark Complete'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'video_assessment',
              child: Row(
                children: [
                  Icon(Icons.videocam),
                  SizedBox(width: 8),
                  Text('Video Assessment'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('Share'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssessmentInfo(Assessment assessment) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assessment.sport,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Assessment ID: ${assessment.id.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(assessment.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(assessment.status),
                  color: _getStatusColor(assessment.status),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Assessment Details
          _buildInfoRow(Icons.person, 'Athlete', assessment.athleteName),
          if (assessment.coachId != null)
            _buildInfoRow(Icons.sports, 'Coach', assessment.coachName),
          _buildInfoRow(Icons.calendar_today, 'Created',
              _formatDate(assessment.createdAt)),
          if (assessment.scheduledDate != null)
            _buildInfoRow(Icons.schedule, 'Scheduled',
                _formatDate(assessment.scheduledDate!)),
          if (assessment.completedDate != null)
            _buildInfoRow(Icons.check_circle, 'Completed',
                _formatDate(assessment.completedDate!)),
          if (assessment.location != null)
            _buildInfoRow(Icons.location_on, 'Location', assessment.location!),

          // Video Assessment Button
          if (assessment.status == 'pending' ||
              assessment.status == 'in_progress') ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.blue.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(Icons.videocam, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  const Text(
                    'Video Assessment Available',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Record or upload videos for AI-powered analysis',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _startVideoAssessment(assessment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                    ),
                    child: const Text('Start Video Assessment'),
                  ),
                ],
              ),
            ),
          ],

          if (assessment.notes != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                assessment.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection(
      Assessment assessment, AssessmentServiceProvider provider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Theme.of(context).primaryColor,
              isScrollable: true,
              tabs: const [
                Tab(icon: Icon(Icons.analytics), text: 'Metrics'),
                Tab(icon: Icon(Icons.videocam), text: 'Videos'),
                Tab(icon: Icon(Icons.video_library), text: 'Media'),
                Tab(icon: Icon(Icons.timeline), text: 'Timeline'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMetricsTab(provider.currentMetrics),
                _buildVideosTab(),
                _buildMediaTab(),
                _buildTimelineTab(assessment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideosTab() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: _loadingVideos
          ? const Center(child: CircularProgressIndicator())
          : _assessmentVideos.isEmpty
              ? _buildEmptyVideosState()
              : ListView.builder(
                  itemCount: _assessmentVideos.length,
                  itemBuilder: (context, index) {
                    return _buildVideoCard(_assessmentVideos[index]);
                  },
                ),
    );
  }

  Widget _buildVideoCard(AssessmentVideo video) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.play_circle_filled, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assessment Video',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Uploaded: ${_formatDate(video.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'UPLOADED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    _playVideo(video.filePath);
                  },
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('Play'),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    _showDeleteVideoDialog(video.id);
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyVideosState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_off, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No videos uploaded yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the video assessment feature to record or upload exercise videos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              final assessment =
                  Provider.of<AssessmentServiceProvider>(context, listen: false)
                      .getAssessmentById(widget.assessmentId);
              if (assessment != null) {
                _startVideoAssessment(assessment);
              }
            },
            icon: const Icon(Icons.videocam),
            label: const Text('Start Video Assessment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsTab(List<PerformanceMetric> metrics) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: metrics.isEmpty
          ? _buildEmptyMetricsState()
          : ListView.builder(
              itemCount: metrics.length,
              itemBuilder: (context, index) {
                return _buildMetricCard(metrics[index]);
              },
            ),
    );
  }

  Widget _buildMetricCard(PerformanceMetric metric) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    metric.metricName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  metric.metricValue.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            if (metric.metricUnit != null) ...[
              const SizedBox(height: 8),
              Text(
                'Unit: ${metric.metricUnit}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            if (metric.grade != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getGradeColor(metric.grade!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Grade: ${metric.grade}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getGradeColor(metric.grade!),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMetricsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_outlined, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            'No metrics recorded yet',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'Add performance metrics for this assessment.',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddPerformanceMetricScreen(
                    assessmentId: widget.assessmentId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Metrics'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTab() {
    return Center(
      child: Text(
        'Media content will go here',
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }

  Widget _buildTimelineTab(Assessment assessment) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _buildTimelineItem(
            icon: Icons.create,
            title: 'Assessment Created',
            time: _formatDate(assessment.createdAt),
            isCompleted: true,
          ),
          if (assessment.scheduledDate != null)
            _buildTimelineItem(
              icon: Icons.schedule,
              title: 'Scheduled',
              time: _formatDate(assessment.scheduledDate!),
              isCompleted: assessment.scheduledDate!.isBefore(DateTime.now()),
            ),
          _buildTimelineItem(
            icon: Icons.play_arrow,
            title: 'In Progress',
            time: assessment.status == 'in_progress' ? 'Current' : 'Pending',
            isCompleted: assessment.status == 'in_progress' ||
                assessment.status == 'completed',
          ),
          _buildTimelineItem(
            icon: Icons.check_circle,
            title: 'Completed',
            time: assessment.completedDate != null
                ? _formatDate(assessment.completedDate!)
                : 'Pending',
            isCompleted: assessment.status == 'completed',
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String time,
    required bool isCompleted,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return const Center(
      child: Text(
        'Assessment not found',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return FloatingActionButton(
      onPressed: () {
        final assessment =
            Provider.of<AssessmentServiceProvider>(context, listen: false)
                .getAssessmentById(widget.assessmentId);
        if (assessment != null) {
          _startVideoAssessment(assessment);
        }
      },
      backgroundColor: Theme.of(context).primaryColor,
      child: const Icon(Icons.videocam),
    );
  }

  void _handleMenuAction(String value, Assessment assessment) {
    final provider =
        Provider.of<AssessmentServiceProvider>(context, listen: false);

    switch (value) {
      case 'start':
        provider.updateAssessmentStatus(assessment.id, 'in_progress');
        break;
      case 'complete':
        provider.updateAssessmentStatus(assessment.id, 'completed');
        break;
      case 'video_assessment':
        _startVideoAssessment(assessment);
        break;
      case 'share':
        // TODO: Handle share logic
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share functionality coming soon')),
        );
        break;
    }
  }

  void _startVideoAssessment(Assessment assessment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoAssessmentScreen(
          assessmentId: assessment.id,
          assessmentType: assessment.assessmentType,
        ),
      ),
    ).then((_) {
      _loadAssessmentVideos(); // Refresh after returning
    });
  }

  void _playVideo(String url) {
    // TODO: Implement your video player
    print("Play video at $url");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video player integration pending')),
    );
  }

  void _showDeleteVideoDialog(String videoId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Video"),
        content: const Text("Are you sure you want to delete this video?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final provider = Provider.of<AssessmentServiceProvider>(context,
                  listen: false);
              final success = await provider.deleteAssessmentVideo(videoId);
              Navigator.of(ctx).pop();
              if (success) {
                _loadAssessmentVideos(); // refresh list
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video deleted successfully')),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Helper methods for colors and formatting
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'in_progress':
        return Icons.play_arrow;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  IconData _getAssessmentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fitness':
      case 'physical':
        return Icons.fitness_center;
      case 'skill':
      case 'technical':
        return Icons.sports_soccer;
      case 'tactical':
        return Icons.psychology;
      case 'mental':
        return Icons.psychology_alt;
      default:
        return Icons.assessment;
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'A-':
      case 'B+':
      case 'B':
        return Colors.blue;
      case 'B-':
      case 'C+':
      case 'C':
        return Colors.orange;
      case 'C-':
      case 'D':
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
