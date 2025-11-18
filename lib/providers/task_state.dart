part of 'task_bloc.dart';


abstract class TaskState extends Equatable {
const TaskState();
@override
List<Object?> get props => [];
}


class TaskInitial extends TaskState {}
class TaskLoadInProgress extends TaskState {}
class TaskLoadSuccess extends TaskState { final List<Task> tasks; const TaskLoadSuccess({this.tasks = const []}); @override List<Object?> get props => [tasks]; }
class TaskLoadFailure extends TaskState { final String error; const TaskLoadFailure({required this.error}); @override List<Object?> get props => [error]; }