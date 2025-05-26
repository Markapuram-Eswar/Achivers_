import 'package:flutter/material.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  TasksScreenState createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> {
  final List<Map<String, dynamic>> _taskItems = [
    {
      'title': 'Mathematics',
      'subtitle': 'Algebra, Geometry, Calculus',
      'icon': 'https://img.icons8.com/isometric/50/calculator.png',
      'color': Colors.blue,
      'progress': 0.65,
      'tasks': 15,
      'completed': 10,
    },
    {
      'title': 'Science',
      'subtitle': 'Physics, Chemistry, Biology',
      'icon': 'https://img.icons8.com/isometric/50/test-tube.png',
      'color': Colors.green,
      'progress': 0.40,
      'tasks': 20,
      'completed': 8,
    },
    {
      'title': 'English',
      'subtitle': 'Grammar, Vocabulary, Literature',
      'icon': 'https://img.icons8.com/isometric/50/literature.png',
      'color': Colors.purple,
      'progress': 0.75,
      'tasks': 12,
      'completed': 9,
    },
    {
      'title': 'History',
      'subtitle': 'World History, Civics, Geography',
      'icon': 'https://img.icons8.com/isometric/50/globe.png',
      'color': Colors.orange,
      'progress': 0.30,
      'tasks': 10,
      'completed': 3,
    },
  ];

  final List<Map<String, dynamic>> _recentTasks = [
    {
      'title': 'Algebra Homework',
      'subject': 'Mathematics',
      'dueDate': 'Due Tomorrow',
      'status': 'In Progress',
      'color': Colors.blue,
    },
    {
      'title': 'Science Project',
      'subject': 'Science',
      'dueDate': 'Due in 2 days',
      'status': 'Not Started',
      'color': Colors.green,
    },
    {
      'title': 'Book Report',
      'subject': 'English',
      'dueDate': 'Due in 3 days',
      'status': 'Not Started',
      'color': Colors.purple,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            const Text(
              'Your Tasks Overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track and manage your academic tasks',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Upcoming tasks section
            const Text(
              'Upcoming Tasks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentTasks.take(2).length,
                itemBuilder: (context, index) {
                  final item = _recentTasks[index];
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: item['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: item['color'].withOpacity(0.3)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              item['subject'],
                              style: TextStyle(
                                color: item['color'],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['dueDate'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: item['color'],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item['status'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // All subjects section
            const Text(
              'Tasks by Subject',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _taskItems.length,
              itemBuilder: (context, index) {
                final item = _taskItems[index];
                return _buildTaskCard(item, context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> item, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailScreen(subject: item['title']),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: item['progress'],
              backgroundColor: item['color'].withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(item['color']),
              minHeight: 8,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject icon and title
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: item['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(
                          item['icon'],
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress text
                  Text(
                    '${item['completed']} of ${item['tasks']} tasks completed',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Progress percentage
                  Text(
                    '${(item['progress'] * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: item['color'],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // View all button
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item['color'].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'View All',
                        style: TextStyle(
                          color: item['color'],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Task detail screen that will be shown when a subject is tapped
class TaskDetailScreen extends StatelessWidget {
  final String subject;

  const TaskDetailScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$subject Tasks'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          'Tasks for $subject will be displayed here',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
