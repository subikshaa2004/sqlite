import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'DB_page.dart'; // Import the DB_page.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _todos = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshTodos();
  }

  Future<void> _refreshTodos() async {
    final data = await _dbHelper.readAll();
    setState(() {
      _todos = data;
    });
  }

  Future<void> _addTodo() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty)
      return;

    await _dbHelper.create({
      'title': _titleController.text,
      'description': _descriptionController.text,
      'isCompleted': 0,
    });

    _titleController.clear();
    _descriptionController.clear();
    _refreshTodos();
  }

  Future<void> _updateTodo(int id, bool isCompleted) async {
    await _dbHelper.update({
      'id': id,
      'title': _todos.firstWhere((todo) => todo['id'] == id)['title'],
      'description':
      _todos.firstWhere((todo) => todo['id'] == id)['description'],
      'isCompleted': isCompleted ? 0 : 1,
    });
    _refreshTodos();
  }

  Future<void> _deleteTodo(int id) async {
    await _dbHelper.delete(id);
    _refreshTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('To-Do List')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _descriptionController,

              decoration: InputDecoration(labelText: 'Description'),
            ),
          ),
          ElevatedButton(
            onPressed: _addTodo,
            child: Text('Add To-Do'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DBPage()), // Navigate to DBPage
              );
            },
            child: Text('View Database'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];

                return ListTile(
                  title: Text(todo['title']),
                  subtitle: Text(todo['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          todo['isCompleted'] == 1
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: todo['isCompleted'] == 1 ? Colors.green :

                          null,

                        ),
                        onPressed: () =>
                            _updateTodo(todo['id'], todo['isCompleted'] == 1),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTodo(todo['id']),
                      ),
                    ],
                  ),

                );
              },
            ),
          ),
        ],
      ),
    );
  }
}