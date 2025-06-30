import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';


DateTime shownDate = DateTime.now();
String currentDate = DateFormat('dd-MMM yyyy (EEEE)').format(DateTime.now());
String currentMonth = DateFormat('MMM yyyy').format(DateTime.now());
DateFormat format = DateFormat("dd-MMM yyyy (EEEE)");
bool cat = false;

enum typesTask {basic, counter, reminder, timer}
typesTask selectedItem = typesTask.basic;

void main() async {
	await Hive.initFlutter(); 
	await Hive.openBox(currentDate); 
	await Hive.openBox(currentMonth);

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
	int _currentPageIndex = 0; // Track which page is active
	Box _dailyBox = Hive.box(currentDate);
	Box _monthlyBox = Hive.box(currentMonth);
	String dateToBeShown = currentDate;
	final TextEditingController _taskController = TextEditingController();
	typesTask selectedItem = typesTask.basic;

	List<Map<String, dynamic>> get _dailyTasks {
		return List<Map<String, dynamic>>.from(
			_dailyBox.get('tasks', defaultValue: []).map((task) => Map<String, dynamic>.from(task)),
		);
	}

	List<Map<String, dynamic>> get _monthlyTasks {
		return List<Map<String, dynamic>>.from(
			_monthlyBox.get('tasks', defaultValue: []).map((task) => Map<String, dynamic>.from(task)),
		);
	}
	

	 void _saveTasks(List<Map<String, dynamic>> tasks, bool isMonthly) {
		if (isMonthly) {
			_monthlyBox.put('tasks', tasks);
		} else {
			_dailyBox.put('tasks', tasks);
		}
	}

	void _addTask(bool isMonthly) {
		if (_taskController.text.isNotEmpty) {
			final newTask =
			 {'task': _taskController.text,
			 'isDone': false,
			 'type': selectedItem};
			final updatedTasks = isMonthly ? [..._monthlyTasks, newTask] : [..._dailyTasks, newTask];

			setState(() {
				_saveTasks(updatedTasks, isMonthly);
				_taskController.clear();
			});
		}
	}

	void _toggleTaskStatus(int index, bool isMonthly) {
		final updatedTasks = isMonthly ? List<Map<String, dynamic>>.from(_monthlyTasks) : List<Map<String, dynamic>>.from(_dailyTasks);
		updatedTasks[index]['isDone'] = !updatedTasks[index]['isDone'];

		setState(() {
			_saveTasks(updatedTasks, isMonthly);
		});
	}

	void _deleteTask(int index, bool isMonthly) {
		final updatedTasks = isMonthly ? List<Map<String, dynamic>>.from(_monthlyTasks) : List<Map<String, dynamic>>.from(_dailyTasks);
		updatedTasks.removeAt(index);

		setState(() {
			_saveTasks(updatedTasks, isMonthly);
		});
	}

	void _nextDay(DateTime shownDate) async {
	 	if (_currentPageIndex == 0) {
			shownDate = format.parse(currentDate);
			shownDate = shownDate.add(const Duration(days: 1));
			currentDate = DateFormat('dd-MMM yyyy (EEEE)').format(shownDate);
			currentMonth = DateFormat('MMM yyyy').format(shownDate);
			await Hive.close();
			await Hive.openBox(currentDate);
			await Hive.openBox(currentMonth);
			_dailyBox = Hive.box(currentDate);
			_monthlyBox = Hive.box(currentMonth);
			setState(() {
				currentDate;
				currentMonth;
				shownDate;
			});
		}
	}

	void _prevDay(DateTime shownDate) async {
		if (_currentPageIndex == 0) {
			shownDate = format.parse(currentDate);
			shownDate = shownDate.subtract(const Duration(days: 1));
			currentDate = DateFormat('dd-MMM yyyy (EEEE)').format(shownDate);
			currentMonth = DateFormat('MMM yyyy').format(shownDate);
			await Hive.close();
			await Hive.openBox(currentDate);
			await Hive.openBox(currentMonth);
			_dailyBox = Hive.box(currentDate);
			_monthlyBox = Hive.box(currentMonth);
			setState(() {
				currentDate;
				currentMonth;
				shownDate;
			});
		}
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
				 child: Builder(
							builder: (context) {
								if (_currentPageIndex == 0) {
									return Row(
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
														fontSize: 19, fontWeight: FontWeight.w500),
											),
											IconButton(
														icon: Icon(Icons.arrow_right_rounded),
															iconSize: 44,
														onPressed: () => _nextDay(shownDate),
											),
										],
									);
								} else {
									return Row(
										mainAxisAlignment: MainAxisAlignment.center, 
										children: [
											SizedBox(height: 60),
											Icon(
												Icons.calendar_month,
													size: 36,
											),
											Text(
												dateToBeShown,
												style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
											),
											
										],
									);
								}
							}
						),
			),
			),
			
			body: CarouselSlider(
				options: CarouselOptions(
					height: MediaQuery.of(context).size.height * 0.8,
					enlargeCenterPage: true,
					viewportFraction: 1.0,
					onPageChanged: (index, reason) {
						setState(() {
							_currentPageIndex = index;
						});
					},
				),
				items: [
					_buildTaskList(isMonthly: false), // Daily tasks
					_buildTaskList(isMonthly: true),  // Monthly tasks
				],
			),
		);
	}
	Widget _buildTaskList({required bool isMonthly}) {
		if (_currentPageIndex == 1) {
			dateToBeShown = currentMonth;
			setState(() {
				dateToBeShown;
			});
		} else {
			dateToBeShown = currentDate;
			setState(() {
				dateToBeShown;
			});
		}
		return Padding(
			padding: const EdgeInsets.all(16.0),
			child: Builder(
				builder: (context) {
					if (selectedItem.index == 0) {
						return Column(
							children: [
								TextField(
									controller: _taskController,
									decoration: InputDecoration(
										labelText: 'Add a new task',
										prefix: PopupMenuButton<typesTask>(
											initialValue: selectedItem,
											onSelected: (typesTask item) {
												setState(() {
													selectedItem = item;
												});
											},
											itemBuilder: (BuildContext context) => <PopupMenuEntry<typesTask>>[
												const PopupMenuItem<typesTask>(
													value: typesTask.basic,
													child: Text('Normal'),
												),
												const PopupMenuItem<typesTask>(
													value: typesTask.counter,
													child: Text('Counter'),
												),
												const PopupMenuItem<typesTask>(
													value: typesTask.reminder,
													child: Text('Reminder'),
												),
												const PopupMenuItem<typesTask>(
													value: typesTask.timer,
													child: Text('Timer'),
												),
											],
										),
										suffix: IconButton(
											icon: Icon(Icons.add),
											onPressed: () => _addTask(isMonthly),
										),
									),
								),
								SizedBox(height: 20),
								Expanded(
									child: ValueListenableBuilder(
										valueListenable: isMonthly ? _monthlyBox.listenable() : _dailyBox.listenable(),
										builder: (context, Box box, _) {
											final tasks = isMonthly ? _monthlyTasks : _dailyTasks;

											if (tasks.isEmpty) {
												return Center(child: Text('No tasks added yet!'));
											}

											return ListView.builder(
												itemCount: tasks.length,
												itemBuilder: (context, index) {
													final task = tasks[index];
													return ListTile(
														leading: Checkbox(
															value: task['isDone'],
															onChanged: (_) => _toggleTaskStatus(index, isMonthly),
														),
														title: Text(
															task['task'],
															style: TextStyle(
																decoration: task['isDone'] ? TextDecoration.lineThrough : null,
															),
														),
														trailing: IconButton(
															icon: Icon(Icons.delete, color: Colors.red),
															onPressed: () => _deleteTask(index, isMonthly),
														),
													);
												},
											);
										},
									),
								),
							],
						);
					} else if (selectedItem.index == 1) {
						return Column(
							children: [
								TextField(
									controller: _taskController,
									decoration: InputDecoration(
										labelText: 'Add a new task',
										prefix: PopupMenuButton<typesTask>(
											initialValue: selectedItem,
											onSelected: (typesTask item) {
												setState(() {
													selectedItem = item;
												});
											},
											itemBuilder: (BuildContext context) => <PopupMenuEntry<typesTask>>[
												const PopupMenuItem<typesTask>(
													value: typesTask.basic,
													child: Text('Normal'),
												),
												const PopupMenuItem<typesTask>(
													value: typesTask.counter,
													child: Text('Counter'),
												),
												const PopupMenuItem<typesTask>(
													value: typesTask.reminder,
													child: Text('Reminder'),
												),
												const PopupMenuItem<typesTask>(
													value: typesTask.timer,
													child: Text('Timer'),
												),
											],
										),
										suffix: IconButton(
											icon: Icon(Icons.add),
											onPressed: () => _addTask(isMonthly),
										),
									),
								),
								SizedBox(height: 20),
								Expanded(
									child: ValueListenableBuilder(
										valueListenable: isMonthly ? _monthlyBox.listenable() : _dailyBox.listenable(),
										builder: (context, Box box, _) {
											final tasks = isMonthly ? _monthlyTasks : _dailyTasks;

											if (tasks.isEmpty) {
												return Center(child: Text('counter'));
											}

											return ListView.builder(
												itemCount: tasks.length,
												itemBuilder: (context, index) {
													final task = tasks[index];
													return ListTile(
														leading: Checkbox(
															value: task['isDone'],
															onChanged: (_) => _toggleTaskStatus(index, isMonthly),
														),
														title: Text(
															task['task'],
															style: TextStyle(
																decoration: task['isDone'] ? TextDecoration.lineThrough : null,
															),
														),
														trailing: IconButton(
															icon: Icon(Icons.delete, color: Colors.red),
															onPressed: () => _deleteTask(index, isMonthly),
														),
													);
												},
											);
										},
									),
								),
							],
						);
					} else if (selectedItem.index == 2) {
						return Column(
							children: [
								TextField(
									controller: _taskController,
									decoration: InputDecoration(
										labelText: 'Add a new task',
										prefix: PopupMenuButton<typesTask>(
											initialValue: selectedItem,
											onSelected: (typesTask item) {
												setState(() {
													selectedItem = item;
												});
											},
											itemBuilder: (BuildContext context) => <PopupMenuEntry<typesTask>>[
												const PopupMenuItem<typesTask>(
													value: typesTask.basic,
													child: Text('Normal'),
												),
												const PopupMenuItem<typesTask>(
													value: typesTask.counter,
													child: Text('Counter'),
												),
												const PopupMenuItem<typesTask>(
													value: typesTask.reminder,
													child: Text('Reminder'),
												),
												const PopupMenuItem<typesTask>(
													value: typesTask.timer,
													child: Text('Timer'),
												),
											],
										),
										suffix: IconButton(
											icon: Icon(Icons.add),
											onPressed: () => _addTask(isMonthly),
										),
									),
								),
								SizedBox(height: 20),
								Expanded(
									child: ValueListenableBuilder(
										valueListenable: isMonthly ? _monthlyBox.listenable() : _dailyBox.listenable(),
										builder: (context, Box box, _) {
											final tasks = isMonthly ? _monthlyTasks : _dailyTasks;

											if (tasks.isEmpty) {
												return Center(child: Text('reminder'));
											}

											return ListView.builder(
												itemCount: tasks.length,
												itemBuilder: (context, index) {
													final task = tasks[index];
													return ListTile(
														leading: Checkbox(
															value: task['isDone'],
															onChanged: (_) => _toggleTaskStatus(index, isMonthly),
														),
														title: Text(
															task['task'],
															style: TextStyle(
																decoration: task['isDone'] ? TextDecoration.lineThrough : null,
															),
														),
														trailing: IconButton(
															icon: Icon(Icons.delete, color: Colors.red),
															onPressed: () => _deleteTask(index, isMonthly),
														),
													);
												},
											);
										},
									),
								),
							],
						);
					}  else {
						return Column(
							children: [
								TextField(
									controller: _taskController,
									decoration: InputDecoration(
										labelText: 'Add a new task',
										prefix: PopupMenuButton<typesTask>(
											initialValue: selectedItem,
											onSelected: (typesTask item) {
												setState(() {
													selectedItem = item;
												});
											},
											itemBuilder: (BuildContext context) => <PopupMenuEntry<typesTask>>[
												const PopupMenuItem<typesTask>(
													value: typesTask.basic,
													child: Text('Normal'),
												),
												const PopupMenuItem<typesTask>(
													value: typesTask.counter,
													child: Text('Counter'),
												),
												const PopupMenuItem<typesTask>(
													value: typesTask.reminder,
													child: Text('Reminder'),
												),
												const PopupMenuItem<typesTask>(
													value: typesTask.timer,
													child: Text('Timer'),
												),
											],
										),
										suffix: IconButton(
											icon: Icon(Icons.add),
											onPressed: () => _addTask(isMonthly),
										),
									),
								),
								SizedBox(height: 20),
								Expanded(
									child: ValueListenableBuilder(
										valueListenable: isMonthly ? _monthlyBox.listenable() : _dailyBox.listenable(),
										builder: (context, Box box, _) {
											final tasks = isMonthly ? _monthlyTasks : _dailyTasks;

											if (tasks.isEmpty) {
												return Center(child: Text('timer'));
											}

											return ListView.builder(
												itemCount: tasks.length,
												itemBuilder: (context, index) {
													final task = tasks[index];
													return ListTile(
														leading: Checkbox(
															value: task['isDone'],
															onChanged: (_) => _toggleTaskStatus(index, isMonthly),
														),
														title: Text(
															task['task'],
															style: TextStyle(
																decoration: task['isDone'] ? TextDecoration.lineThrough : null,
															),
														),
														trailing: IconButton(
															icon: Icon(Icons.delete, color: Colors.red),
															onPressed: () => _deleteTask(index, isMonthly),
														),
													);
												},
											);
										},
									),
								),
							],
						);
					}
				}
			)
		);
	}
}