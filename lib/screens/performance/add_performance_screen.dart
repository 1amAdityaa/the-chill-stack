import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/supabase_auth_provider.dart';

class AddPerformanceMetricScreen extends StatefulWidget {
  final String assessmentId;

  const AddPerformanceMetricScreen({
    Key? key,
    required this.assessmentId,
  }) : super(key: key);

  @override
  _AddPerformanceMetricScreenState createState() =>
      _AddPerformanceMetricScreenState();
}

class _AddPerformanceMetricScreenState
    extends State<AddPerformanceMetricScreen> {
  final _formKey = GlobalKey<FormState>();
  final _metricNameController = TextEditingController();
  final _metricValueController = TextEditingController();
  final _benchmarkController = TextEditingController();
  final _percentileController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedUnit = '';
  String _selectedGrade = '';

  final List<String> _units = [
    'seconds',
    'meters',
    'kg',
    'reps',
    'points',
    'cm',
    'mph',
    'bpm'
  ];
  final List<String> _grades = ['A+', 'A', 'B+', 'B', 'C+', 'C', 'D', 'F'];

  Map<String, List<String>> _predefinedMetrics = {
    'physical': [
      '100m Sprint',
      '1500m Run',
      'Vertical Jump',
      'Standing Long Jump',
      'Push-ups',
      'Sit-ups',
      'Bench Press',
      'Squat',
      'Deadlift',
      'Flexibility Test',
      'Agility Test',
      'VO2 Max',
      'Body Fat Percentage',
    ],
    'technical': [
      'Ball Control',
      'Passing Accuracy',
      'Shooting Accuracy',
      'Dribbling Speed',
      'First Touch',
      'Crossing Accuracy',
      'Defensive Tackles',
      'Free Kick Accuracy',
      'Penalty Conversion',
      'Header Accuracy',
    ],
    'tactical': [
      'Decision Making',
      'Positioning',
      'Game Reading',
      'Team Play',
      'Leadership',
      'Communication',
      'Adaptability',
      'Strategic Thinking',
    ],
    'mental': [
      'Concentration',
      'Confidence',
      'Motivation',
      'Stress Management',
      'Mental Toughness',
      'Focus Under Pressure',
      'Goal Setting',
      'Self-Discipline',
      'Emotional Control',
    ],
  };

  @override
  void dispose() {
    _metricNameController.dispose();
    _metricValueController.dispose();
    _benchmarkController.dispose();
    _percentileController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Performance Metric',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetricSelection(),
                    const SizedBox(height: 20),
                    _buildValueInput(),
                    const SizedBox(height: 20),
                    _buildBenchmarkInput(),
                    const SizedBox(height: 20),
                    _buildPerformanceEvaluation(),
                    const SizedBox(height: 20),
                    _buildNotesInput(),
                    const SizedBox(height: 32),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.analytics,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'PERFORMANCE METRIC',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Record performance data and evaluation',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricSelection() {
    final suggestions = _predefinedMetrics['physical'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metric Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _metricNameController,
          decoration: InputDecoration(
            hintText: 'Enter or select metric name',
            prefixIcon:
                Icon(Icons.analytics, color: Theme.of(context).primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a metric name';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        // Predefined metric suggestions
        if (suggestions.isNotEmpty) ...[
          const Text(
            'Quick Select:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((metric) {
              return GestureDetector(
                onTap: () {
                  _metricNameController.text = metric;
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    metric,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildValueInput() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Metric Value',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _metricValueController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter value',
                  prefixIcon: Icon(Icons.straighten,
                      color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a value';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Unit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedUnit.isEmpty ? null : _selectedUnit,
                decoration: InputDecoration(
                  hintText: 'Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: ['', ..._units].map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit.isEmpty ? 'None' : unit),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedUnit = newValue ?? '';
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBenchmarkInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Benchmark (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _benchmarkController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter benchmark value for comparison',
            prefixIcon: Icon(Icons.track_changes,
                color: Theme.of(context).primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value != null &&
                value.isNotEmpty &&
                double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPerformanceEvaluation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Evaluation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grade',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedGrade.isEmpty ? null : _selectedGrade,
                      decoration: InputDecoration(
                        hintText: 'Select grade',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: ['', ..._grades].map((String grade) {
                        return DropdownMenuItem<String>(
                          value: grade,
                          child: Row(
                            children: [
                              if (grade.isNotEmpty)
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _getGradeColor(grade),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Text(grade.isEmpty ? 'None' : grade),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGrade = newValue ?? '';
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Percentile',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _percentileController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: '0-100',
                        suffixText: '%',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final percentile = double.tryParse(value);
                          if (percentile == null ||
                              percentile < 0 ||
                              percentile > 100) {
                            return 'Enter 0-100';
                          }
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any additional observations or comments',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Icon(Icons.note, color: Theme.of(context).primaryColor),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Consumer<AssessmentServiceProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Save Metric',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: provider.isLoading ? null : _saveMetric,
          ),
        );
      },
    );
  }

  Future<void> _saveMetric() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider =
        Provider.of<SupabaseAuthProvider>(context, listen: false);
    final assessmentProvider =
        Provider.of<AssessmentServiceProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final metricName = _metricNameController.text.trim();
    final metricValue =
        double.tryParse(_metricValueController.text.trim()) ?? 0.0;
    final benchmark = _benchmarkController.text.trim().isNotEmpty
        ? double.tryParse(_benchmarkController.text.trim())
        : null;
    final percentile = _percentileController.text.trim().isNotEmpty
        ? double.tryParse(_percentileController.text.trim())
        : null;

    try {
      await assessmentProvider.addPerformanceMetric(
        assessmentId: widget.assessmentId,
        athleteId: authProvider.user!.id,
        metricName: metricName,
        metricValue: metricValue,
        metricUnit: _selectedUnit.isEmpty ? null : _selectedUnit,
        benchmarkValue: benchmark,
        percentile: percentile,
        grade: _selectedGrade.isEmpty ? null : _selectedGrade,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (assessmentProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Metric saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(assessmentProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save metric: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return Colors.green;
      case 'B+':
      case 'B':
        return Colors.lightGreen;
      case 'C+':
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
