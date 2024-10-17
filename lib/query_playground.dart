import 'package:flutter/material.dart';
import 'database_helper.dart';
class QueryPlayground extends StatefulWidget {
  @override
  _QueryPlaygroundState createState() => _QueryPlaygroundState();

}
class _QueryPlaygroundState extends State<QueryPlayground> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final TextEditingController _queryController = TextEditingController();
  String _output = '';
  List<Map<String, dynamic>> _queryResult = [];
  Future<void> _executeQuery() async {
    String query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _output = 'Please enter a query.';
      });
      return;
    }
    try {
      final result = await _dbHelper.executeRawQuery(query);
      if (query.toLowerCase().startsWith('select')) {
// If it's a SELECT query, set the result to be displayed
        setState(() {
          _queryResult = List<Map<String, dynamic>>.from(result);
          _output = 'Query executed successfully!';
        });
      } else {
        setState(() {
          _output = 'Query executed successfully!';
          _queryResult = [];
        });
      }
    } catch (e) {
      setState(() {
        _output = 'Error: $e';
        _queryResult = [];
      });
    }

  }
  Widget _buildTable() {
    if (_queryResult.isEmpty) return Text('No data to display.');
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: _queryResult.first.keys.map((key) {
          return DataColumn(label: Text(key));
        }).toList(),
        rows: _queryResult.map((row) {
          return DataRow(
            cells: row.values.map((value) {
              return DataCell(Text(value.toString()));
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Query Playground')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter SQL Query',
              ),
              maxLines: 5,
            ),

            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _executeQuery,
              child: Text('Run Query'),
            ),
            SizedBox(height: 10),
            Text('Output:'),
            Text(_output, style: TextStyle(color: Colors.red)),
            Expanded(child: _buildTable()), // Display the results
          ],
        ),
      ),
    );
  }
}