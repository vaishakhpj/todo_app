import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/database_helper.dart';
import '../models/task_model.dart';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final DatabaseHelper _databaseHelper;
  List<Task> _allTasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  TaskSort _currentSort = TaskSort.byDate;
  String _currentQuery = '';


  TaskBloc(this._databaseHelper) : super(TasksInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskStatus>(_onToggleTaskStatus);
    on<FilterTasks>(_onFilterTasks);
    on<SearchTasks>(_onSearchTasks);
    on<SortTasks>(_onSortTasks);
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TasksLoading());
    try {
      _allTasks = await _databaseHelper.readAllTasks();
      _applyFiltersAndSort(emit);
    } catch (e) {
      emit(TasksError("Failed to load tasks: ${e.toString()}"));
    }
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      await _databaseHelper.createTask(event.task);
      add(LoadTasks());
    } catch (e) {
      emit(TasksError("Failed to add task: ${e.toString()}"));
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    try {
      await _databaseHelper.updateTask(event.task);
      add(LoadTasks());
    } catch (e) {
      emit(TasksError("Failed to update task: ${e.toString()}"));
    }
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    try {
      await _databaseHelper.deleteTask(event.id);
      add(LoadTasks());
    } catch (e) {
      emit(TasksError("Failed to delete task: ${e.toString()}"));
    }
  }

  void _onToggleTaskStatus(ToggleTaskStatus event, Emitter<TaskState> emit) async {
    try {
      final updatedTask = event.task.copyWith(isCompleted: !event.task.isCompleted);
      await _databaseHelper.updateTask(updatedTask);
      add(LoadTasks());
    } catch (e) {
      emit(TasksError("Failed to update task status: ${e.toString()}"));
    }
  }

  void _onFilterTasks(FilterTasks event, Emitter<TaskState> emit) {
    _currentFilter = event.filter;
    _applyFiltersAndSort(emit);
  }

  void _onSearchTasks(SearchTasks event, Emitter<TaskState> emit) {
    _currentQuery = event.query;
    _applyFiltersAndSort(emit);
  }

  void _onSortTasks(SortTasks event, Emitter<TaskState> emit) {
    _currentSort = event.sort;
    _applyFiltersAndSort(emit);
  }

  void _applyFiltersAndSort(Emitter<TaskState> emit) {
    List<Task> filteredTasks = List.from(_allTasks);

    // Filtering
    if (_currentFilter == TaskFilter.pending) {
      filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
    } else if (_currentFilter == TaskFilter.completed) {
      filteredTasks = filteredTasks.where((task) => task.isCompleted).toList();
    }

    // Searching
    if (_currentQuery.isNotEmpty) {
      filteredTasks = filteredTasks
          .where((task) =>
      task.title.toLowerCase().contains(_currentQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_currentQuery.toLowerCase()))
          .toList();
    }

    // Sorting
    if (_currentSort == TaskSort.byPriority) {
      filteredTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    } else {
      filteredTasks.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    }

    if (filteredTasks.isEmpty) {
      emit(TasksEmpty());
    } else {
      emit(TasksLoaded(filteredTasks));
    }
  }
}

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Task task;
  const AddTask(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final Task task;
  const UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTask extends TaskEvent {
  final int id;
  const DeleteTask(this.id);

  @override
  List<Object> get props => [id];
}

class ToggleTaskStatus extends TaskEvent {
  final Task task;
  const ToggleTaskStatus(this.task);

  @override
  List<Object> get props => [task];
}

class FilterTasks extends TaskEvent {
  final TaskFilter filter;
  const FilterTasks(this.filter);

  @override
  List<Object> get props => [filter];
}

class SearchTasks extends TaskEvent {
  final String query;
  const SearchTasks(this.query);

  @override
  List<Object> get props => [query];
}

class SortTasks extends TaskEvent {
  final TaskSort sort;
  const SortTasks(this.sort);

  @override
  List<Object> get props => [sort];
}

// Enums for filtering and sorting
enum TaskFilter { all, pending, completed }
enum TaskSort { byDate, byPriority }

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