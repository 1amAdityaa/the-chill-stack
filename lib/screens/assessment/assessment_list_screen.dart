import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/assessment_provider.dart';
import '../../providers/supabase_auth_provider.dart';

class CreateAssessmentScreen extends StatefulWidget {
  @override
  _CreateAssessmentScreenState createState() => _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState extends State<CreateAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedSport = 'Football';
  String _selectedAssessmentType = 'physical';
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;

  final List<String> _sports = [
    'Football',
    'Cricket',
    'Basketball',
    'Tennis',
    'Swimming',
    'Athletics',
    'Badminton',
    'Volleyball',
    'Hockey',
    'Wrestling'
  ];

  final List<Map<String, dynamic>> _assessmentTypes = [
    {
      'value': 'physical',
      'title': 'Physical Assessment',
      'description': 'Test physical fitness, strength, and endurance',
      'icon': Icons.fitness_center,
      'color': Colors.red,
    },
    {
      'value': 'technical',
      'title': 'Technical Assessment',
      'description': 'Evaluate sport-specific technical skills',
      'icon': Icons.sports,
      'color': Colors.blue,
    },
    {
      'value': 'tactical',
      'title': 'Tactical Assessment',
      'description': 'Assess game understanding and decision making',
      'icon': Icons.psychology,
      'color': Colors.green,
    },
    {
      'value': 'mental',
      'title': 'Mental Assessment',
      'description': 'Evaluate psychological aspects and mindset',
      'icon': Icons.psychology_outlined,
      'color': Colors.purple,
    },
  ];

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('New Assessment', style: TextStyle(color: Colors.white)),
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
                    _buildAssessmentTypeSelection(),
                    const SizedBox(height: 24),
                    _buildSportSelection(),
                    const SizedBox(height: 24),
                    _buildDateTimeSelection(),
                    const SizedBox(height: 24),
                    _buildLocationField(),
                    const SizedBox(height: 24),
                    _buildNotesField(),
                    const SizedBox(height: 32),
                    _buildCreateButton(),
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
            Icons.assessment,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 8),
          const Text(
            'Create New Assessment',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Set up a comprehensive sports assessment',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assessment Type',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _assessmentTypes.length,
          itemBuilder: (context, index) {
            final type = _assessmentTypes[index];
            final isSelected = _selectedAssessmentType == type['value'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAssessmentType = type['value'];
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? type['color'].withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? type['color'] : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type['icon'],
                      color: isSelected ? type['color'] : Colors.grey.shade600,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type['title'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? type['color'] : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type['description'],
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSportSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sport',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSport,
              isExpanded: true,
              icon: Icon(Icons.expand_more, color: Colors.grey.shade600),
              items: _sports.map((String sport) {
                return DropdownMenuItem<String>(
                  value: sport,
                  child: Row(
                    children: [
                      Icon(
                        Icons.sports,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        sport,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedSport = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Schedule (Optional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _scheduledDate != null
                            ? '${_scheduledDate!.day}/${_scheduledDate!.month}/${_scheduledDate!.year}'
                            : 'Select Date',
                        style: TextStyle(
                          fontSize: 16,
                          color: _scheduledDate != null
                              ? Colors.black87
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: _selectTime,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _scheduledTime != null
                            ? _scheduledTime!.format(context)
                            : 'Select Time',
                        style: TextStyle(
                          fontSize: 16,
                          color: _scheduledTime != null
                              ? Colors.black87
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location (Optional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Enter assessment location',
            prefixIcon:
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
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

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Add any additional notes or requirements',
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 60),
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

  Widget _buildCreateButton() {
    return Consumer<AssessmentServiceProvider>(
      builder: (context, assessmentProvider, child) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: assessmentProvider.isLoading ? null : _createAssessment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: assessmentProvider.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Create Assessment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _scheduledDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _scheduledDate) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _scheduledTime) {
      setState(() {
        _scheduledTime = picked;
      });
    }
  }

  Future<void> _createAssessment() async {
    final authProvider =
        Provider.of<SupabaseAuthProvider>(context, listen: false);
    final assessmentProvider =
        Provider.of<AssessmentServiceProvider>(context, listen: false);

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to create an assessment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    DateTime? combinedDateTime;
    if (_scheduledDate != null && _scheduledTime != null) {
      combinedDateTime = DateTime(
        _scheduledDate!.year,
        _scheduledDate!.month,
        _scheduledDate!.day,
        _scheduledTime!.hour,
        _scheduledTime!.minute,
      );
    } else if (_scheduledDate != null) {
      combinedDateTime = _scheduledDate;
    }

    try {
      await assessmentProvider.createAssessment(
        athleteId: authProvider.user!.id,
        sport: _selectedSport,
        assessmentType: _selectedAssessmentType,
        scheduledDate: combinedDateTime,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (assessmentProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assessment created successfully!'),
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
          content: Text('Failed to create assessment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
