import 'package:flutter/material.dart';
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
  final List<Todo> _todos = [
    Todo(
      title: 'Hello world',
      dateCreated: DateTime.now(),
    ),
    Todo(
      title: 'Hello world 2',
      dateCreated: DateTime.now().subtract(
        const Duration(days: 1),
      ),
    ),
  ];

  void _addTodo(Todo newTodo) {
    setState(() {
      _todos.add(newTodo);
    });
  }

  void _removeTodo(String id) {
    setState(() {
      _todos.removeWhere((element) => element.id == id);
    });
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
      body: _todos.isEmpty
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
                );
              },
            ),
    );
  }
}

class AddTodoPage extends StatefulWidget {
  const AddTodoPage({super.key});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  String _title = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add todo'),
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
            child: const Text('Add'),
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
    final newTodo = Todo(
      title: _title,
    );
    Navigator.of(context).pop(newTodo);
  }
}
