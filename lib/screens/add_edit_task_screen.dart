import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/task_bloc.dart';
import '../models/task_model.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late Priority _priority;
  late DateTime? _dueDate;
  late String? _category;

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _priority = widget.task?.priority ?? Priority.medium;
    _dueDate = widget.task?.dueDate;
    _category = widget.task?.category;
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final taskToSave = Task(
        id: widget.task?.id,
        title: _title,
        description: _description,
        isCompleted: widget.task?.isCompleted ?? false,
        priority: _priority,
        dueDate: _dueDate,
        category: _category,
        creationDate: widget.task?.creationDate ?? DateTime.now(),
      );

      if (widget.task == null) {
        context.read<TaskBloc>().add(AddTask(taskToSave));
      } else {
        context.read<TaskBloc>().add(UpdateTask(taskToSave));
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submit,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                  validator: (value) => value!.trim().isEmpty ? 'Please enter a title' : null,
                  onSaved: (value) => _title = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 3,
                  onSaved: (value) => _description = value ?? '',
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Priority>(
                  value: _priority,
                  decoration: const InputDecoration(labelText: 'Priority', border: OutlineInputBorder()),
                  items: Priority.values.map((priority) {
                    return DropdownMenuItem(
                      value: priority,
                      child: Text(priority.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _priority = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                  onSaved: (value) => _category = value,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dueDate == null ? 'No due date set' : 'Due: ${DateFormat.yMMMd().format(_dueDate!)}',
                      ),
                    ),
                    TextButton(
                      onPressed: _selectDueDate,
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Text(widget.task == null ? 'Add Task' : 'Update Task'),
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