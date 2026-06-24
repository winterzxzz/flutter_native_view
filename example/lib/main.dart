import 'package:flutter/material.dart';
import 'package:flutter_native_view/flutter_native_view.dart';

void main() => runApp(const TodoApp());

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoPage(),
    );
  }
}

class Todo {
  Todo(this.title, {this.done = false});
  final String title;
  bool done;
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Todo> _todos = <Todo>[
    Todo('Try Liquid Glass'),
    Todo('Ship the plugin', done: true),
  ];

  void _add() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _todos.insert(0, Todo(text));
      _controller.clear();
    });
  }

  void _remove(int index) => setState(() => _todos.removeAt(index));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF0F2027), Color(0xFF2C5364), Color(0xFFFF6E7F)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Glass Todos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _InputBar(controller: _controller, onAdd: _add),
                const SizedBox(height: 20),
                Expanded(
                  child: _todos.isEmpty
                      ? const _EmptyState()
                      : ListView.separated(
                          itemCount: _todos.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (BuildContext context, int i) {
                            final Todo todo = _todos[i];
                            return _TodoCard(
                              todo: todo,
                              onToggle: (bool v) => setState(() => todo.done = v),
                              onDelete: () => _remove(i),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onAdd});

  final TextEditingController controller;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: LiquidGlass(
            style: const GlassStyle(cornerRadius: 18),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: controller,
              onSubmitted: (_) => onAdd(),
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                hintText: 'Add a task…',
                hintStyle: TextStyle(color: Colors.white60),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        LiquidGlassButton(
          onPressed: onAdd,
          style: const GlassStyle(cornerRadius: 18),
          padding: const EdgeInsets.all(16),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  final Todo todo;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return LiquidGlass(
      style: const GlassStyle(cornerRadius: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              todo.title,
              style: TextStyle(
                fontSize: 17,
                decoration: todo.done ? TextDecoration.lineThrough : null,
                color: todo.done ? Colors.white54 : Colors.white,
              ),
            ),
          ),
          LiquidGlassSwitch(value: todo.done, onChanged: onToggle),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.close, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No tasks yet',
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }
}
