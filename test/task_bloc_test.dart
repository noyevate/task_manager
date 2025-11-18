// test/task_bloc_test.dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager/providers/task_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:task_manager/models/task.dart';
import 'package:task_manager/repositories/task_repository.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class FakeTask extends Fake implements Task {}

void main() {
  late MockTaskRepository mockRepo;
  late TaskBloc bloc;

  // Sample tasks
  final sampleTask1 = Task(
    id: const Uuid().v4(),
    title: 'First Task',
    description: 'desc 1',
    completed: false,
    createdAt: DateTime.now(),
    isSynced: true,
  );

  final sampleTask2 = Task(
    id: const Uuid().v4(),
    title: 'Second Task',
    description: 'desc 2',
    completed: true,
    createdAt: DateTime.now(),
    isSynced: true,
  );

  setUpAll(() {
    registerFallbackValue(FakeTask());
  });

  setUp(() {
    mockRepo = MockTaskRepository();

    when(() => mockRepo.getTasks(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async => <Task>[]);
    when(() => mockRepo.addTask(any())).thenAnswer((inv) async => inv.positionalArguments[0] as Task);
    when(() => mockRepo.updateTask(any())).thenAnswer((inv) async => inv.positionalArguments[0] as Task);
    when(() => mockRepo.deleteTask(any())).thenAnswer((_) async => Future.value());

    bloc = TaskBloc(repository: mockRepo);
  });

  tearDown(() {
    bloc.close();
  });

  group('TaskBloc - load', () {
    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoadInProgress, TaskLoadSuccess] when repository returns tasks',
      build: () {
        when(() => mockRepo.getTasks(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => [sampleTask1, sampleTask2]);
        return TaskBloc(repository: mockRepo);
      },
      act: (b) => b.add(TaskLoadRequested()),
      expect: () => [
        isA<TaskLoadInProgress>(),
        isA<TaskLoadSuccess>().having((s) => s.tasks.length, 'tasks length', 2),
      ],
      verify: (_) {
        verify(() => mockRepo.getTasks(forceRefresh: any(named: 'forceRefresh'))).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'emits [TaskLoadInProgress, TaskLoadFailure] when repository throws',
      build: () {
        when(() => mockRepo.getTasks(forceRefresh: any(named: 'forceRefresh')))
            .thenThrow(Exception('fetch failed'));
        return TaskBloc(repository: mockRepo);
      },
      act: (b) => b.add(TaskLoadRequested()),
      expect: () => [
        isA<TaskLoadInProgress>(),
        isA<TaskLoadFailure>().having((s) => s.error, 'error', contains('fetch failed')),
      ],
    );
  });

  group('TaskBloc - CRUD operations (optimistic updates)', () {
    blocTest<TaskBloc, TaskState>(
      'adds a task optimistically when TaskAdded is added',
      build: () {
        when(() => mockRepo.getTasks(forceRefresh: any(named: 'forceRefresh')))
            .thenAnswer((_) async => []);
        return TaskBloc(repository: mockRepo);
      },
      seed: () => TaskLoadSuccess(tasks: []),
      act: (b) {
        final taskToAdd = Task(
          id: '', 
          title: 'New',
          description: 'new desc',
          completed: false,
          createdAt: DateTime.now(),
        );
        b.add(TaskAdded(taskToAdd));
      },
      wait: const Duration(milliseconds: 200),
      expect: () => [
        isA<TaskLoadSuccess>().having((s) => s.tasks.length, 'contains one task', 1),
      ],
      verify: (_) {
        verify(() => mockRepo.addTask(any())).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'updates a task when TaskUpdated is added',
      build: () {
        return TaskBloc(repository: mockRepo);
      },
      seed: () => TaskLoadSuccess(tasks: [sampleTask1]),
      act: (b) {
        final updated = sampleTask1.copyWith(title: 'Updated title', completed: true);
        b.add(TaskUpdated(updated));
      },
      expect: () => [
        isA<TaskLoadSuccess>().having((s) => s.tasks.first.title, 'updated title', 'Updated title'),
      ],
      verify: (_) {
        verify(() => mockRepo.updateTask(any())).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'removes a task when TaskDeleted is added',
      build: () => TaskBloc(repository: mockRepo),
      seed: () => TaskLoadSuccess(tasks: [sampleTask1]),
      act: (b) {
        b.add(TaskDeleted(sampleTask1.id));
      },
      expect: () => [
        isA<TaskLoadSuccess>().having((s) => s.tasks.length, 'zero after deletion', 0),
      ],
      verify: (_) {
        verify(() => mockRepo.deleteTask(sampleTask1.id)).called(1);
      },
    );
  });
}
