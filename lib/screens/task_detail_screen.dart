import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/providers/task_bloc.dart';
import 'package:task_manager/widgets/theme_toggle.dart';
import '../models/task.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task? task;
  const TaskDetailScreen({super.key, this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  bool _completed = false;
  bool _isValid = false;


  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _completed = widget.task?.completed ?? false;


    _titleController.addListener(_validate);
  _descController.addListener(_validate);

  _validate();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final task =
        widget.task?.copyWith(
          title: _titleController.text,
          description: _descController.text,
          completed: _completed,
        ) ??
        Task(
          id: '',
          title: _titleController.text,
          description: _descController.text,
          completed: _completed,
          createdAt: DateTime.now(),
        );
    if (widget.task == null) {
      context.read<TaskBloc>().add(TaskAdded(task));
    } else {
      context.read<TaskBloc>().add(TaskUpdated(task));
    }
    Navigator.pop(context);
  }


  void _validate() {
  setState(() {
    _isValid = _titleController.text.trim().length >= 3;
  });
}

    Future<void> _delete() async {
    if (widget.task == null) return; // shouldn’t happen
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      context.read<TaskBloc>().add(TaskDeleted(widget.task!.id));
      Navigator.pop(context); // close details page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(widget.task == null ? 'Create Task' : 'Edit Task'),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => (v == null || v.trim().length < 3)
                      ? 'Title must be at least 3 characters'
                      : null,
                ),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: null,
                ),
                SwitchListTile(
                  value: _completed,
                  onChanged: (v) => setState(() => _completed = v),
                  title: const Text('Completed'),
                ),
                const SizedBox(height: 20),
                widget.task != null ?  Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                onPressed: _isValid ? _save : null, child: Text('Save', style: TextStyle(color: !_isValid ? Colors.black26 :Colors.blue),)),
                      SizedBox(width: 20,),
                      ElevatedButton(onPressed: _isValid ? _delete : null, style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ), child:  Text('Delete', style: TextStyle(color: !_isValid ? Colors.black26 :Colors.white))) 
                    ],
                  ),
                ) : ElevatedButton(onPressed: _isValid ? _save : null, child: Text('Save', style: TextStyle(color: !_isValid ? Colors.black26 :Colors.blue),)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
