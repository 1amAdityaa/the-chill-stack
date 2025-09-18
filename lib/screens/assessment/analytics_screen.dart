import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/supabase_auth_provider.dart';
import '../../models/performance_matrix.dart';

class AnalyticsScreen extends StatefulWidget {
  @override
  _AnalyticsScreenState createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeRange = '30'; // Days
  List<PerformanceMetric> _performanceHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAnalyticsData();
  }

  void _loadAnalyticsData() async {
    final authProvider =
        Provider.of<SupabaseAuthProvider>(context, listen: false);
    final assessmentProvider =
        Provider.of<AssessmentServiceProvider>(context, listen: false);

    if (authProvider.user != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final history = await assessmentProvider
            .getAthletePerformanceHistory(authProvider.user!.id);
        setState(() {
          _performanceHistory = history;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
      }
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
      body: Consumer2<AssessmentServiceProvider, SupabaseAuthProvider>(
        builder: (context, assessmentProvider, authProvider, child) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: _buildTimeRangeSelector(),
              ),
              SliverToBoxAdapter(
                child: _buildTabSection(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.deepPurple,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: true, // ✅ ensures title is centered
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.deepPurple,
                Colors.deepPurple.withOpacity(0.8),
                Colors.blue.withOpacity(0.6),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Performance Insights',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTimeRangeButton('7', '7 Days'),
          _buildTimeRangeButton('30', '30 Days'),
          _buildTimeRangeButton('90', '3 Months'),
          _buildTimeRangeButton('365', '1 Year'),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(String value, String label) {
    final isSelected = _selectedTimeRange == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTimeRange = value;
          });
          _loadAnalyticsData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.deepPurple : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorColor: Colors.deepPurple,
              tabs: const [
                Tab(icon: Icon(Icons.trending_up), text: 'Overview'),
                Tab(icon: Icon(Icons.bar_chart), text: 'Metrics'),
                Tab(icon: Icon(Icons.timeline), text: 'Progress'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildMetricsTab(),
                _buildProgressTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverviewStatsGrid(),
          const SizedBox(height: 20),
          _buildRecentPerformanceCard(),
          const SizedBox(height: 20),
          _buildTopMetricsCard(),
          const SizedBox(height: 40), // ✅ extra space so it’s not hidden
        ],
      ),
    );
  }

  Widget _buildOverviewStatsGrid() {
    final totalMetrics = _performanceHistory.length;
    final avgScore = _calculateAverageScore();
    final improvements = _calculateImprovements();
    final completedAssessments = _getUniqueAssessments();

    return GridView.count(
      shrinkWrap: true, // ✅ important
      physics: const NeverScrollableScrollPhysics(), // ✅ avoid scroll conflict
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Metrics',
          totalMetrics.toString(),
          Icons.assessment,
          Colors.blue,
        ),
        _buildStatCard(
          'Avg Score',
          avgScore.toStringAsFixed(1),
          Icons.star,
          Colors.orange,
        ),
        _buildStatCard(
          'Improvements',
          '+${improvements.toString()}%',
          Icons.trending_up,
          Colors.green,
        ),
        _buildStatCard(
          'Assessments',
          completedAssessments.toString(),
          Icons.check_circle,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPerformanceCard() {
    final recentMetrics = _performanceHistory.take(5).toList();

    return Container(
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
          const Text(
            'Recent Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (recentMetrics.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No performance data yet',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            ...recentMetrics.map((metric) => _buildMetricListItem(metric)),
        ],
      ),
    );
  }

  Widget _buildMetricListItem(PerformanceMetric metric) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.speed,
              color: Colors.deepPurple,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.metricName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  metric.value?.toString() ?? 'No data',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (metric.grade != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getGradeColor(metric.grade!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                metric.grade!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getGradeColor(metric.grade!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopMetricsCard() {
    final topMetrics = _getTopMetrics();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performing Metrics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (topMetrics.isEmpty)
            Text(
              'No metrics to display',
              style: TextStyle(color: Colors.grey.shade600),
            )
          else
            ...topMetrics.map((metric) => _buildTopMetricItem(metric)),
        ],
      ),
    );
  }

  Widget _buildTopMetricItem(PerformanceMetric metric) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.star,
            color: Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              metric.metricName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            metric.grade ?? metric.value?.toString() ?? 'N/A',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final metricsByType = _groupMetricsByType();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: metricsByType.entries.map((entry) {
          return _buildMetricTypeCard(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _buildMetricTypeCard(String type, List<PerformanceMetric> metrics) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(type),
                  color: _getTypeColor(type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                type,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${metrics.length} metrics',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...metrics.map((metric) => _buildMetricItem(metric)),
        ],
      ),
    );
  }

  Widget _buildMetricItem(PerformanceMetric metric) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.metricName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  metric.value?.toString() ?? 'No data',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (metric.grade != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getGradeColor(metric.grade!).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                metric.grade!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _getGradeColor(metric.grade!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressSummary(),
          const SizedBox(height: 20),
          _buildProgressChart(),
          const SizedBox(height: 20),
          _buildProgressByCategory(),
        ],
      ),
    );
  }

  Widget _buildProgressSummary() {
    final progressData = _calculateProgressSummary();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade50,
            Colors.blue.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progress Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  'Overall Progress',
                  '${progressData['overall']}%',
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressItem(
                  'This Month',
                  '${progressData['monthly']}%',
                  Icons.calendar_month,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    return Container(
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
          const Text(
            'Performance Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chart visualization would go here',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressByCategory() {
    final categorizedProgress = _calculateProgressByCategory();

    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24), // ✅ space from next widget
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
          const Text(
            'Progress by Category',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true, // ✅ let it size itself
            physics:
                const NeverScrollableScrollPhysics(), // ✅ prevent nested scroll
            itemCount: categorizedProgress.length,
            itemBuilder: (context, index) {
              final entry = categorizedProgress.entries.elementAt(index);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCategoryProgressItem(entry.key, entry.value),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProgressItem(String category, double progress) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${progress.toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(progress),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(_getProgressColor(progress)),
          ),
        ],
      ),
    );
  }

  // Helper methods
  double _calculateAverageScore() {
    if (_performanceHistory.isEmpty) return 0.0;
    final totalScore = _performanceHistory
        .where((m) =>
            m.value != null && double.tryParse(m.value.toString()) != null)
        .fold(
            0.0,
            (sum, metric) =>
                sum + (double.tryParse(metric.value.toString()) ?? 0.0));
    final count = _performanceHistory
        .where((m) =>
            m.value != null && double.tryParse(m.value.toString()) != null)
        .length;
    return count > 0 ? totalScore / count : 0.0;
  }

  int _calculateImprovements() {
    if (_performanceHistory.length < 2) return 0;
    // Simple improvement calculation - this would be more sophisticated in practice
    return 15; // Placeholder
  }

  int _getUniqueAssessments() {
    return _performanceHistory.map((m) => m.id).toSet().length;
  }

  List<PerformanceMetric> _getTopMetrics() {
    return _performanceHistory
        .where((m) => m.grade != null && (m.grade == 'A' || m.grade == 'B'))
        .take(5)
        .toList();
  }

  Map<String, List<PerformanceMetric>> _groupMetricsByType() {
    final Map<String, List<PerformanceMetric>> grouped = {};
    for (final metric in _performanceHistory) {
      final type = metric.category ?? 'General';
      grouped.putIfAbsent(type, () => []).add(metric);
    }
    return grouped;
  }

  Map<String, double> _calculateProgressSummary() {
    return {
      'overall': 78.0, // Placeholder values
      'monthly': 12.0,
    };
  }

  Map<String, double> _calculateProgressByCategory() {
    return {
      'Strength': 85.0,
      'Endurance': 72.0,
      'Flexibility': 68.0,
      'Speed': 79.0,
    };
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'strength':
        return Colors.red;
      case 'endurance':
        return Colors.blue;
      case 'flexibility':
        return Colors.green;
      case 'speed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'strength':
        return Icons.fitness_center;
      case 'endurance':
        return Icons.directions_run;
      case 'flexibility':
        return Icons.self_improvement;
      case 'speed':
        return Icons.speed;
      default:
        return Icons.assessment;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 60) return Colors.blue;
    if (progress >= 40) return Colors.orange;
    return Colors.red;
  }
}
