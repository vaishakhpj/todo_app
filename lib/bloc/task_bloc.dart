import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/database_helper.dart';
import '../models/task_model.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final DatabaseHelper _databaseHelper;

  TaskBloc(this._databaseHelper) : super(TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    // ... register other event handlers
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TasksLoading());
    try {
      final tasks = await _databaseHelper.readAllTasks();
      if (tasks.isEmpty) {
        emit(TasksEmpty());
      } else {
        emit(TasksLoaded(tasks));
      }
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await _databaseHelper.createTask(event.task);
      add(LoadTasks()); // Reload tasks after adding
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

  void _onDeleteTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await _databaseHelper.deleteTask(event.task.id!);
      add(LoadTasks()); // Reload tasks after adding
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }

// Implement other event handlers for UpdateTask, DeleteTask, etc.
}

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {}
class AddTask extends TaskEvent {
  final Task task;
  const AddTask(this.task);
}

class DeleteTask extends TaskEvent {
  final Task task;
  const DeleteTask(this.task);
}
// ... other events like UpdateTask, DeleteTask, FilterTasks, etc.

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object> get props => [];
}

class TasksInitial extends TaskState {}
class TasksLoading extends TaskState {}
class TasksLoaded extends TaskState {
  final List<Task> tasks;
  const TasksLoaded(this.tasks);
}
class TasksError extends TaskState {
  final String message;
  const TasksError(this.message);
}
class TasksEmpty extends TaskState {}