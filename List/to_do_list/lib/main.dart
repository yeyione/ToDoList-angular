import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To Do List',
      theme: ThemeData(
        colorSchemeSeed: const Color.fromARGB(255, 186, 33, 127),
        useMaterial3: true,
      ),
      home: const TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<String> _tasks = [
    'Limpiar la casa',
    'Hacer la compra',
    'Pasear al perro',
    'Estudiar Flutter',
    'Llamar a mi madre',
  ];
  final TextEditingController _controller = TextEditingController();

  bool _taskExists(String text, {int? ignoreIndex}) {
    for (int i = 0; i < _tasks.length; i++) {
      if (i == ignoreIndex) continue;
      if (_tasks[i].trim().toLowerCase() == text.trim().toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  void _addTask() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_taskExists(text)) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Esa tarea ya existe')));
      return;
    }

    setState(() {
      _tasks.add(text);
      _controller.clear();
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _editTask(int index) {
    final TextEditingController editController = TextEditingController(
      text: _tasks[index],
    );
    String? errorText;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar tarea'),
          content: TextField(
            controller: editController,
            autofocus: true,
            decoration: InputDecoration(errorText: errorText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final newText = editController.text.trim();

                if (newText.isEmpty) {
                  setDialogState(() {
                    errorText = 'La tarea no puede estar vacía';
                  });
                  return;
                }

                if (_taskExists(newText, ignoreIndex: index)) {
                  setDialogState(() {
                    errorText = 'Esa tarea ya existe';
                  });
                  return;
                }

                setState(() {
                  _tasks[index] = newText;
                });
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'To Do List',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 201, 119, 183),
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa una tarea...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Color.fromARGB(255, 197, 66, 166),
                  ),
                  onPressed: _addTask,
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return Dismissible(
                  key: Key(task + index.toString()),
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _editTask(index);
                      return false;
                    }
                    return true;
                  },
                  onDismissed: (direction) {
                    _deleteTask(index);
                  },
                  child: ListTile(
                    title: Text(task),
                    trailing: const Icon(Icons.drag_handle),
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
