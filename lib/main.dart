import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_flutter/todo.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: false,
      ),
      title: 'Material App',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    SharedPreferences.getInstance().then((value) {
      _sharedPreferences = value;
      _getLocalData();
      isLoading = false;
    });
  }

  void _getLocalData() async {
    final stringData = _sharedPreferences.getString('todo_list') ?? '[]';
    final json = jsonDecode(stringData) as List;
    setState(() {
      _todos = json
          .map(
            (e) => Todo.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    });
  }

  void _saveLocalData() {
    final json = _todos.map((e) => e.toJson()).toList();
    final String stringData = jsonEncode(json);
    _sharedPreferences.setString('todo_list', stringData);
  }

  late final List<Todo> _todos;

  bool isLoading = false;

  late final SharedPreferences _sharedPreferences;

  void _addTodo(Todo newTodo) {
    setState(() {
      _todos.add(newTodo);
    });
    _saveLocalData();
  }

  void _removeTodo(String id) {
    setState(() {
      _todos.removeWhere((element) => element.id == id);
    });
    _saveLocalData();
  }

  void _updateTodo(Todo newTodo) {
    setState(() {
      final index = _todos.indexWhere((element) => element.id == newTodo.id);
      if (index == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No todo found'),
          ),
        );
        return;
      }
      _todos[index] = newTodo;
    });
    _saveLocalData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          IconButton(
            onPressed: () {
              // Todo(hank): Go to add todo page
              Navigator.of(context)
                  .push<Todo>(
                MaterialPageRoute<Todo>(
                  builder: (context) => const AddTodoPage(),
                ),
              )
                  .then(
                (value) {
                  if (value != null) {
                    _addTodo(value);
                  }
                },
              );
            },
            icon: const Icon(
              Icons.add,
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _todos.isEmpty
              ? const Center(
                  child: Text('No todo to show'),
                )
              : ListView.builder(
                  itemCount: _todos.length,
                  itemBuilder: (context, index) {
                    final todo = _todos[index];
                    return ListTile(
                      title: Text(todo.title),
                      subtitle: Text(todo.createdDateString),
                      leading: Checkbox(
                        value: todo.isCompleted,
                        onChanged: (value) {
                          todo.dateCompleted =
                              todo.isCompleted ? null : DateTime.now();
                          _updateTodo(todo);
                        },
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeTodo(todo.id),
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .push<Todo>(
                          MaterialPageRoute<Todo>(
                            builder: (context) => AddTodoPage(
                              todo: todo,
                            ),
                          ),
                        )
                            .then(
                          (value) {
                            if (value != null) {
                              _updateTodo(value);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({
    super.key,
    this.todo,
  });

  final Todo? todo;

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  @override
  void initState() {
    _title = widget.todo != null ? widget.todo!.title : '';
    super.initState();
  }

  late String _title;

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.todo != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit todo' : 'Add todo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            initialValue: _title,
            onChanged: onTitleChanged,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: const InputDecoration(
              hintText: 'Title',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This field must not be empty';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
            onPressed: _title.isEmpty ? null : _onAddTodo,
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void onTitleChanged(String value) {
    setState(() {
      _title = value;
    });
  }

  void _onAddTodo() {
    if (widget.todo != null) {
      final newTodo = widget.todo!;
      newTodo.title = _title;
      Navigator.of(context).pop(newTodo);
      return;
    }
    final newTodo = Todo(
      title: _title,
    );
    Navigator.of(context).pop(newTodo);
  }
}
