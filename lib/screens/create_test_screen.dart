import 'package:flutter/material.dart';

class CreateTestScreen extends StatefulWidget {
  const CreateTestScreen({super.key});

  @override
  State<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends State<CreateTestScreen> {
  final List<String> _subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science'
  ];
  final List<String> _sections = ['A', 'B', 'C'];
  String _selectedSubject = 'Mathematics';
  String _selectedSection = 'A';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _durationController =
      TextEditingController(text: '60');
  final TextEditingController _maxMarksController =
      TextEditingController(text: '100');

  final List<Map<String, dynamic>> _questions = [];

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

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => _QuestionTypeDialog(
        onSelectType: (type) {
          Navigator.pop(context);
          showDialog(
            context: context,
            builder: (context) => type == QuestionType.multipleChoice
                ? _AddMultipleChoiceDialog(
                    onAdd: (question) {
                      setState(() {
                        _questions.add({...question, 'type': 'multipleChoice'});
                      });
                    },
                  )
                : _AddFillBlanksDialog(
                    onAdd: (question) {
                      setState(() {
                        _questions.add({...question, 'type': 'fillBlanks'});
                      });
                    },
                  ),
          );
        },
      ),
    );
  }

  void _editQuestion(int index) {
    final question = _questions[index];
    showDialog(
      context: context,
      builder: (context) => question['type'] == 'multipleChoice'
          ? _AddMultipleChoiceDialog(
              initialQuestion: question,
              onAdd: (updatedQuestion) {
                setState(() {
                  _questions[index] = {
                    ...updatedQuestion,
                    'type': 'multipleChoice'
                  };
                });
              },
            )
          : _AddFillBlanksDialog(
              initialQuestion: question,
              onAdd: (updatedQuestion) {
                setState(() {
                  _questions[index] = {
                    ...updatedQuestion,
                    'type': 'fillBlanks'
                  };
                });
              },
            ),
    );
  }

  void _deleteQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int index) {
    if (question['type'] == 'multipleChoice') {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(
            'Q${index + 1}: ${question['question']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              ...List.generate(
                question['options'].length,
                (optionIndex) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        '${String.fromCharCode(65 + optionIndex)}. ',
                        style: TextStyle(
                          color: (question['correctOptions'] as List<int>)
                                  .contains(optionIndex)
                              ? Colors.green
                              : Colors.black87,
                          fontWeight: (question['correctOptions'] as List<int>)
                                  .contains(optionIndex)
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        question['options'][optionIndex],
                        style: TextStyle(
                          color: (question['correctOptions'] as List<int>)
                                  .contains(optionIndex)
                              ? Colors.green
                              : Colors.black87,
                          fontWeight: (question['correctOptions'] as List<int>)
                                  .contains(optionIndex)
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editQuestion(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteQuestion(index),
              ),
            ],
          ),
        ),
      );
    } else {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Text(
            'Q${index + 1}: Fill in the blanks',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(question['sentence']),
              const SizedBox(height: 4),
              Text(
                'Answer: ${question['answer']}',
                style: const TextStyle(color: Colors.green),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editQuestion(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteQuestion(index),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text(
          'Create Test',
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
            _buildSectionTitle('Test Details'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedSubject,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedSection,
                      decoration: const InputDecoration(
                        labelText: 'Section',
                        border: OutlineInputBorder(),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Schedule'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                    const Divider(),
                    ListTile(
                      title: Text(_selectedTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () => _selectTime(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Test Configuration'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duration (minutes)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _maxMarksController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Maximum Marks',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Questions'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        return _buildQuestionCard(_questions[index], index);
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Question'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[900],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _addQuestion,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Instructions'),
            const Card(
              child: TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter test instructions...',
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
                  if (_questions.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add at least one question'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test created successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'Create Test',
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

enum QuestionType {
  multipleChoice,
  fillBlanks,
}

class _QuestionTypeDialog extends StatelessWidget {
  final Function(QuestionType) onSelectType;

  const _QuestionTypeDialog({required this.onSelectType});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Question Type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.radio_button_checked),
            title: const Text('Multiple Choice'),
            onTap: () => onSelectType(QuestionType.multipleChoice),
          ),
          ListTile(
            leading: const Icon(Icons.short_text),
            title: const Text('Fill in the Blanks'),
            onTap: () => onSelectType(QuestionType.fillBlanks),
          ),
        ],
      ),
    );
  }
}

class _AddMultipleChoiceDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  final Map<String, dynamic>? initialQuestion;

  const _AddMultipleChoiceDialog({
    required this.onAdd,
    this.initialQuestion,
  });

  @override
  State<_AddMultipleChoiceDialog> createState() =>
      _AddMultipleChoiceDialogState();
}

class _AddMultipleChoiceDialogState extends State<_AddMultipleChoiceDialog> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;
  late List<bool> _correctOptions;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.initialQuestion?['question'] ?? '',
    );
    _optionControllers = List.generate(
      4,
      (index) => TextEditingController(
        text: widget.initialQuestion?['options']?[index] ?? '',
      ),
    );
    _correctOptions = List.generate(
      4,
      (index) =>
          widget.initialQuestion?['correctOptions']?.contains(index) ?? false,
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.initialQuestion == null ? 'Add Question' : 'Edit Question'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: _correctOptions[index],
                      onChanged: (value) {
                        setState(() {
                          _correctOptions[index] = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _optionControllers[index],
                        decoration: InputDecoration(
                          labelText:
                              'Option ${String.fromCharCode(65 + index)}',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_questionController.text.isEmpty ||
                _optionControllers
                    .any((controller) => controller.text.isEmpty) ||
                !_correctOptions.contains(true)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Please fill all fields and select at least one correct answer'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            final List<int> correctOptionIndices = [];
            for (int i = 0; i < _correctOptions.length; i++) {
              if (_correctOptions[i]) {
                correctOptionIndices.add(i);
              }
            }
            widget.onAdd({
              'question': _questionController.text,
              'options': _optionControllers.map((c) => c.text).toList(),
              'correctOptions': correctOptionIndices,
            });
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _AddFillBlanksDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAdd;
  final Map<String, dynamic>? initialQuestion;

  const _AddFillBlanksDialog({
    required this.onAdd,
    this.initialQuestion,
  });

  @override
  State<_AddFillBlanksDialog> createState() => _AddFillBlanksDialogState();
}

class _AddFillBlanksDialogState extends State<_AddFillBlanksDialog> {
  late TextEditingController _sentenceController;
  late TextEditingController _answerController;

  @override
  void initState() {
    super.initState();
    _sentenceController = TextEditingController(
      text: widget.initialQuestion?['sentence'] ?? '',
    );
    _answerController = TextEditingController(
      text: widget.initialQuestion?['answer'] ?? '',
    );
  }

  @override
  void dispose() {
    _sentenceController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialQuestion == null
          ? 'Add Fill in the Blanks'
          : 'Edit Fill in the Blanks'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _sentenceController,
              decoration: const InputDecoration(
                labelText: 'Sentence (use ___ for blank)',
                border: OutlineInputBorder(),
                hintText: 'The capital of France is ___',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(),
                hintText: 'Paris',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_sentenceController.text.isEmpty ||
                _answerController.text.isEmpty ||
                !_sentenceController.text.contains('___')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Please fill all fields and include ___ for the blank'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
            widget.onAdd({
              'sentence': _sentenceController.text,
              'answer': _answerController.text,
            });
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
