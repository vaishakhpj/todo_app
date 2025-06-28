import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/task_bloc.dart';
import '../widgets/task_list.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TasksError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is TasksLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is TasksLoaded) {
            final pendingTasks = state.tasks.where((task) => !task.isCompleted).length;
            final completedTasks = state.tasks.length - pendingTasks;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Pending: $pendingTasks | Completed: $completedTasks'),
                ),
                Expanded(child: TaskList(tasks: state.tasks)),
              ],
            );
          }
          if (state is TasksEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  Text('No tasks found!', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            );
          }
          return const Center(child: Text('Add a task to get started!'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Search tasks...',
          border: InputBorder.none,
        ),
        onChanged: (query) {
          context.read<TaskBloc>().add(SearchTasks(query));
        },
      )
          : const Text('Smart Todo List'),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
                context.read<TaskBloc>().add(const SearchTasks(''));
              }
            });
          },
        ),
        PopupMenuButton<TaskFilter>(
          onSelected: (filter) {
            context.read<TaskBloc>().add(FilterTasks(filter));
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: TaskFilter.all, child: Text('All')),
            const PopupMenuItem(value: TaskFilter.pending, child: Text('Pending')),
            const PopupMenuItem(value: TaskFilter.completed, child: Text('Completed')),
          ],
          icon: const Icon(Icons.filter_list),
        ),
        PopupMenuButton<TaskSort>(
          onSelected: (sort) {
            context.read<TaskBloc>().add(SortTasks(sort));
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: TaskSort.byDate, child: Text('Sort by Date')),
            const PopupMenuItem(value: TaskSort.byPriority, child: Text('Sort by Priority')),
          ],
          icon: const Icon(Icons.sort),
        ),
      ],
    );
  }
}