import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

// =====================
// MODEL
// =====================
class Task {
  final int? id;
  final String title;
  final String priority;
  final String dueDate;
  final bool isDone;
  Task({
    this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    this.isDone = false,
  });
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      priority: json['priority'],
      dueDate: json['due_date'],
      isDone: json['is_done'].toString() == 'true',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "priority": priority,
      "due_date": dueDate,
      "is_done": isDone.toString(),
    };
  }
}
// =====================
// API SERVICE
// =====================

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/tasks";
  Future<List<Task>> getTasks() async {
    final token = await AuthService().getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  Future<bool> addTask(Task task) async {
    final token = await AuthService().getToken();
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(task.toJson()),
    );
    
    print('Add Task Response Status: ${response.statusCode}'); // Debug response
    print('Add Task Response Body: ${response.body}'); // Debug response

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add task');
    }
  }

  Future<bool> updateTask(Task task) async {
    if (task.id == null) return false;
    final token = await AuthService().getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/${task.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode(task.toJson()),
    );

    print('Update Task Response Status: ${response.statusCode}'); // Debug response
    print('Update Task Response Body: ${response.body}'); // Debug response

    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteTask(int id) async {
    final token = await AuthService().getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    print('Delete Task Response Status: ${response.statusCode}'); // Debug response
    print('Delete Task Response Body: ${response.body}'); // Debug response

    return response.statusCode == 200 || response.statusCode == 204;
  }
}

// =====================
// UI: Contoh Penggunaan
// =====================
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
          primary: Colors.deepPurple,
          secondary: Colors.purpleAccent,
          surface: Colors.white,
          background: Colors.grey[50],
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.deepPurple),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.deepPurple,
          ),
        ),
      ),
      home: FutureBuilder<bool>(
        future: _authService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.data == true) {
            return TaskListScreen();
          }

          return LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => TaskListScreen(),
      },
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ApiService api = ApiService();
  List<Task> tasks = [];
  bool isLoading = true;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final result = await AuthService().getUserProfile();
      if (result['success']) {
        setState(() {
          userName = result['data']['name'] ?? 'User';
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _loadTasks() async {
    setState(() => isLoading = true);
    try {
      final loadedTasks = await api.getTasks();
      // Sort tasks by due date and priority
      loadedTasks.sort((a, b) {
        // First compare by due date
        final dateA = DateTime.parse(a.dueDate);
        final dateB = DateTime.parse(b.dueDate);
        final dateComparison = dateA.compareTo(dateB);
        
        // If dates are the same, sort by priority
        if (dateComparison == 0) {
          final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
          return priorityOrder[a.priority.toLowerCase()]!.compareTo(
            priorityOrder[b.priority.toLowerCase()]!
          );
        }
        
        return dateComparison;
      });
      
      setState(() {
        tasks = loadedTasks;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading tasks: $e')),
      );
    }
  }

  Future<void> _addTask() async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => AddTaskDialog(),
    );

    if (result != null) {
      try {
        final success = await api.addTask(result);
        if (success) {
          await _loadTasks(); // Reload tasks after successful addition
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Task added successfully'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding task: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _toggleTaskStatus(Task task) async {
    final updatedTask = Task(
      id: task.id,
      title: task.title,
      priority: task.priority,
      dueDate: task.dueDate,
      isDone: !task.isDone,
    );

    try {
      final success = await api.updateTask(updatedTask);
      if (success) {
        _loadTasks();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                userName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No tasks yet',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add a new task to get started',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.isDone,
                          onChanged: (_) => _toggleTaskStatus(task),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.flag,
                                  size: 16,
                                  color: _getPriorityColor(task.priority),
                                ),
                                SizedBox(width: 4),
                                Text(task.priority),
                                SizedBox(width: 16),
                                Icon(Icons.calendar_today, size: 16),
                                SizedBox(width: 4),
                                Text(task.dueDate),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline),
                          onPressed: () async {
                            if (task.id != null) {
                              final bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Task'),
                                  content: Text('Are you sure you want to delete this task?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  print('Deleting task with ID: ${task.id}');
                                  final success = await api.deleteTask(task.id!);
                                  print('Delete response: $success');
                                  if (success) {
                                    print('Current tasks before delete: ${tasks.length}');
                                    setState(() {
                                      tasks.removeWhere((t) => t.id == task.id);
                                    });
                                    print('Tasks after delete: ${tasks.length}');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.white),
                                            SizedBox(width: 8),
                                            Text('Task deleted successfully'),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print('Error deleting task: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to delete task: $e'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: Icon(Icons.add),
        label: Text('Add Task'),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class AddTaskDialog extends StatefulWidget {
  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _priority = 'low';
  DateTime _dueDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Task'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _priority,
              decoration: InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: ['high', 'medium', 'low']
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority.toUpperCase()),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _priority = value);
                }
              },
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Due Date'),
              subtitle: Text(
                '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}',
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _dueDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                    );
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final task = Task(
                title: _titleController.text,
                priority: _priority,
                dueDate: '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}',
              );
              Navigator.pop(context, task);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
