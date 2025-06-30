import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

DateTime shownDate = DateTime.now();
String currentDate = DateFormat('dd-MMM yyyy (EEEE)').format(DateTime.now());
DateFormat format = DateFormat("dd-MMM yyyy (EEEE)");
bool cat = false;
void main() async {
  await Hive.initFlutter(); // Initialize Hive
  await Hive.openBox(currentDate); // Open a box for storing tasks
  
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  @override
  _TodoHomePageState createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  
  
  Box _todoBox = Hive.box(currentDate);
  final TextEditingController _taskController = TextEditingController();

  List<Map<String, dynamic>> get _tasks {
    return List<Map<String, dynamic>>.from(
    _todoBox.get('tasks', defaultValue: []).map((task) => Map<String, dynamic>.from(task)),
  );
  }

  void _saveTasks(List<Map<String, dynamic>> tasks) {
    _todoBox.put('tasks', tasks);
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      final newTask = {'task': _taskController.text, 'isDone': false};
      final updatedTasks = [..._tasks, newTask];

      setState(() {
        _saveTasks(updatedTasks);
        _taskController.clear();
      });
    }
  }

  void _toggleTaskStatus(int index) {
    final updatedTasks = List<Map<String, dynamic>>.from(_tasks);
    updatedTasks[index]['isDone'] = !updatedTasks[index]['isDone'];

    setState(() {
      _saveTasks(updatedTasks);
    });
  }

  void _deleteTask(int index) {
    final updatedTasks = List<Map<String, dynamic>>.from(_tasks)..removeAt(index);

    setState(() {
      _saveTasks(updatedTasks);
    });
  }

  void _nextDay(DateTime shownDate) async {
   shownDate = format.parse(currentDate);
   shownDate = shownDate.add(const Duration(days: 1));
   currentDate = DateFormat('dd-MMM yyyy (EEEE)').format(shownDate);
   await Hive.close();
   await Hive.openBox(currentDate);
   _todoBox = Hive.box(currentDate);
   setState(() {
    currentDate;
    shownDate;
   });
  }

  void _prevDay(DateTime shownDate) async {
   shownDate = format.parse(currentDate);
   shownDate = shownDate.subtract(const Duration(days: 1));
   currentDate = DateFormat('dd-MMM yyyy (EEEE)').format(shownDate);
   await Hive.close();
   await Hive.openBox(currentDate);
   _todoBox = Hive.box(currentDate);
   setState(() {
    currentDate;
    shownDate;
   });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'To-Do List',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
          )
        ),
        centerTitle: true,
        bottom: PreferredSize(
         preferredSize: Size.fromHeight(kToolbarHeight),
         child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                  icon: Icon(Icons.arrow_left_rounded),
                    iconSize: 44,
                  onPressed: () => _prevDay(shownDate),
              ),
            Text(
                currentDate,
                style: TextStyle(
                  fontSize: 19),
             ),
            IconButton(
                  icon: Icon(Icons.arrow_right_rounded),
                    iconSize: 44,
                  onPressed: () => _nextDay(shownDate),
              ),
          ]
         )
      ),
      ),
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Add a new task',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addTask,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _tasks.isEmpty
                  ? Center(child: Text('No tasks added yet!'))
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return ListTile(
                          leading: Checkbox(
                            value: task['isDone'],
                            onChanged: (_) => _toggleTaskStatus(index),
                          ),
                          title: Text(
                            task['task'],
                            style: TextStyle(
                              decoration: task['isDone']
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteTask(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
