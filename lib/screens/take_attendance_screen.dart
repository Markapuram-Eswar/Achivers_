import 'package:flutter/material.dart';

class TakeAttendanceScreen extends StatefulWidget {
  const TakeAttendanceScreen({super.key});

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  final Map<String, bool> _attendance = {
    'Eswar Kumar': false,
    'Aditi Sharma': false,
    'Arjun Patel': false,
    'Diya Singh': false,
    'Praveen Kumar': false,
    'Arjun Reddy': false,
    'Kavya Gupta': false,
    'Krishna Rao': false,
    'Meera': false,
    'Nikhil': false,
    'Priya': false,
    'Rahul': false,
    'Riya Desai': false,
    'Sai Prasad': false,
    'Shreyas': false,
  };

  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
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
          'Take Attendance',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _selectDate(context),
            icon:
                const Icon(Icons.calendar_today, color: Colors.white, size: 20),
            label: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  'Class 10-A',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                const Spacer(),
                Text(
                  'Present: ${_attendance.values.where((v) => v).length}/${_attendance.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _attendance.length,
              itemBuilder: (context, index) {
                final name = _attendance.keys.elementAt(index);
                final isPresent = _attendance[name]!;
                return Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          isPresent ? Colors.green[100] : Colors.grey[100],
                      child: Icon(
                        isPresent ? Icons.check : Icons.person_outline,
                        color: isPresent ? Colors.green : Colors.grey,
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Switch(
                      value: isPresent,
                      activeColor: Colors.green,
                      onChanged: (bool value) {
                        setState(() {
                          _attendance[name] = value;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SizedBox(
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
                      content: Text('Attendance saved successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Save Attendance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
