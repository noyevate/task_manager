import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  final _uuid = Uuid();

  TaskBloc({required this.repository}) : super(TaskInitial()) {
    on<TaskLoadRequested>(_onLoad);
    on<TaskRefreshed>(_onRefresh);
    on<TaskAdded>(_onAdd);
    on<TaskUpdated>(_onUpdate);
    on<TaskDeleted>(_onDelete);
  }

  Future<void> _onLoad(TaskLoadRequested event, Emitter<TaskState> emit) async {
    emit(TaskLoadInProgress());
    try {
      final tasks = await repository.getTasks();
      emit(TaskLoadSuccess(tasks: tasks));
    } catch (e) {
      emit(TaskLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onRefresh(TaskRefreshed event, Emitter<TaskState> emit) async {
    try {
      final tasks = await repository.getTasks(forceRefresh: true);
      emit(TaskLoadSuccess(tasks: tasks));
    } catch (e) {
      emit(TaskLoadFailure(error: e.toString()));
    }
  }

  Future<void> _onAdd(TaskAdded event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final cur = (state as TaskLoadSuccess).tasks;
      final newTask = event.task.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        isSynced: false,
      );
      final updated = List<Task>.from(cur)..insert(0, newTask);
      emit(TaskLoadSuccess(tasks: updated));
      await repository.addTask(newTask);
    }
  }

  Future<void> _onUpdate(TaskUpdated event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final cur = (state as TaskLoadSuccess).tasks;
      final idx = cur.indexWhere((t) => t.id == event.task.id);
      if (idx == -1) return;
      final updatedList = List<Task>.from(cur)..[idx] = event.task;
      emit(TaskLoadSuccess(tasks: updatedList));
      await repository.updateTask(event.task);
    }
  }

  Future<void> _onDelete(TaskDeleted event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final cur = (state as TaskLoadSuccess).tasks;
      final updated = cur.where((t) => t.id != event.id).toList();
      emit(TaskLoadSuccess(tasks: updated));
      await repository.deleteTask(event.id);
    }
  }
}
