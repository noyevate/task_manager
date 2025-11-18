import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class TaskRepository {
  final ApiService apiService;
  final StorageService storageService;
  final Uuid _uuid = const Uuid();

  TaskRepository({required this.apiService, required this.storageService});

  Future<List<Task>> getTasks({bool forceRefresh = false}) async {
    final local = storageService.loadTasks();
    if (local.isNotEmpty && !forceRefresh) {
      return local;
    }

    try {
      final remote = await apiService.fetchTasks();
      final synced = remote.map((t) => t.copyWith(isSynced: true)).toList();
      await storageService.saveAll(synced);
      return synced;
    } catch (_) {
      return local;
    }
  }

  Future<Task> addTask(Task task) async {
    final localId = task.id.isNotEmpty ? task.id : _uuid.v4();
    final localTask = task.copyWith(id: localId, createdAt: task.createdAt, isSynced: false);
    await storageService.saveTask(localTask);

    try {
      final created = await apiService.createTask(localTask);
      final serverTask = created.copyWith(isSynced: true, createdAt: localTask.createdAt);
      await storageService.saveTask(serverTask);
      if (serverTask.id != localId) {
        await storageService.deleteTask(localId);
      }
      return serverTask;
    } catch (_) {
      return localTask;
    }
  }

  Future<Task> updateTask(Task task) async {
    final localCopy = task.copyWith(isSynced: false);
    await storageService.saveTask(localCopy);

    try {
      final updated = await apiService.updateTask(localCopy);
      final serverTask = updated.copyWith(isSynced: true, createdAt: localCopy.createdAt);
      await storageService.saveTask(serverTask);
      return serverTask;
    } catch (_) {
      return localCopy;
    }
  }

  Future<void> deleteTask(String id) async {
    await storageService.deleteTask(id);
    try {
      await apiService.deleteTask(id);
    } catch (_) {
    }
  }

  
  Future<void> syncPending() async {
    final all = storageService.loadTasks();
    for (final t in all) {
      if (t.isSynced == false) {
        try {
          if (_looksLikeUuid(t.id)) {
            final created = await apiService.createTask(t);
            final serverTask = created.copyWith(isSynced: true, createdAt: t.createdAt);
            await storageService.saveTask(serverTask);
            if (serverTask.id != t.id) {
              await storageService.deleteTask(t.id);
            }
          } else {
            final updated = await apiService.updateTask(t);
            final serverTask = updated.copyWith(isSynced: true, createdAt: t.createdAt);
            await storageService.saveTask(serverTask);
          }
        } catch (e) {
        }
      }
    }
  }

  bool _looksLikeUuid(String id) {
    final uuidRegex = RegExp(r'^[0-9a-fA-F\-]{36}$');
    return uuidRegex.hasMatch(id);
  }
}
