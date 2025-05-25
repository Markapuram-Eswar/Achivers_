import 'package:flutter/material.dart';

class ScheduleClassScreen extends StatefulWidget {
  const ScheduleClassScreen({super.key});

  @override
  State<ScheduleClassScreen> createState() => _ScheduleClassScreenState();
}

class _ScheduleClassScreenState extends State<ScheduleClassScreen> {
  final List<String> _subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science'
  ];
  final List<String> _sections = ['A', 'B', 'C'];
  final List<String> _classes = ['6', '7', '8', '9', '10'];
  String _selectedSubject = 'Mathematics';
  String _selectedSection = 'A';
  String _selectedClass = '8';
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text(
          'Schedule Class',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Class'),
            Card(
              child: DropdownButtonFormField<String>(
                value: _selectedClass,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: _classes.map((String classNum) {
                  return DropdownMenuItem<String>(
                    value: classNum,
                    child: Text('Class $classNum'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedClass = newValue!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Subject'),
            Card(
              child: DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: _subjects.map((String subject) {
                  return DropdownMenuItem<String>(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubject = newValue!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Section'),
            Card(
              child: DropdownButtonFormField<String>(
                value: _selectedSection,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                ),
                items: _sections.map((String section) {
                  return DropdownMenuItem<String>(
                    value: section,
                    child: Text('Section $section'),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSection = newValue!;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Date'),
            Card(
              child: ListTile(
                title: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Time'),
            Card(
              child: ListTile(
                title: Text(
                  _selectedTime.format(context),
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Additional Notes'),
            const Card(
              child: TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter any additional notes...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Class scheduled successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Schedule Class',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}
