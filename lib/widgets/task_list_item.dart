import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/task_bloc.dart';
import '../models/task_model.dart';
import '../screens/add_edit_task_screen.dart';

class TaskListItem extends StatelessWidget {
  final Task task;

  const TaskListItem({Key? key, required this.task}) : super(key: key);

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high: return Colors.red.shade700;
      case Priority.medium: return Colors.orange.shade700;
      case Priority.low: return Colors.green.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) {
            context.read<TaskBloc>().add(ToggleTaskStatus(task));
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) Text(task.description),
            const SizedBox(height: 4),
            Row(
              children: [
                if (task.dueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      DateFormat.yMMMd().format(task.dueDate!),
                      style: TextStyle(
                        color: task.dueDate!.isBefore(DateTime.now()) && !task.isCompleted
                            ? Colors.red
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                if (task.category != null && task.category!.isNotEmpty)
                  Chip(
                    label: Text(task.category!),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
        ),
        trailing: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getPriorityColor(task.priority),
            shape: BoxShape.circle,
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddEditTaskScreen(task: task),
            ),
          );
        },
      ),
    );
  }
}