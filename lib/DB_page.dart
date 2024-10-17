import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'query_playground.dart'; // Import the new page

class DBPage extends StatefulWidget {
  @override
  _DBPageState createState() => _DBPageState();
}

class _DBPageState extends State<DBPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> _todos = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Entries'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshTodos,
          ),
          IconButton(
            icon: Icon(Icons.play_circle), // Add an icon for query playground
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QueryPlayground()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _todos.isEmpty
            ? Center(child: Text('No data available'))
            : Column(
          children: [
            // Display data types above the table
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Data Types:', style: TextStyle(fontWeight: FontWeight.bold)),
                // Correctly format the string for data types
                Text(
                  'ID (INTEGER), Title (TEXT), Description (TEXT), Status (INTEGER), Created At (DATETIME)',
                ),
              ],
            ),
            SizedBox(height: 10), // Add some space between the types and the table

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Title')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Created At')),
                  ],
                  rows: _todos.map((todo) {
                    return DataRow(cells: [
                      DataCell(Text(todo['id']?.toString() ?? 'N/A')),
                      DataCell(Text(todo['title'] ?? 'N/A')),
                      DataCell(Text(todo['description'] ?? 'N/A')),
                      DataCell(
                        Text(
                          todo['isCompleted'] == 1 ? 'Completed' : 'Pending',
                          style: TextStyle(
                            color: todo['isCompleted'] == 1 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      DataCell(Text(todo['createdAt'] ?? 'N/A')),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
