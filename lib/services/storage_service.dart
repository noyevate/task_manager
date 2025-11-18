import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class StorageService {
  static const String boxName = 'tasks_box';

  late final Box<Task> _box;

  StorageService._create(); 

  static Future<StorageService> init() async {
    await Hive.initFlutter();

    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }

    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Task>(boxName);
    }

    final svc = StorageService._create();
    svc._box = Hive.box<Task>(boxName);
    return svc;
  }

  List<Task> loadTasks() {
    return _box.values.toList();
  }

  Future<void> saveTask(Task task) async {
    await _box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  Future<void> saveAll(List<Task> tasks) async {
    final map = <String, Task>{for (var t in tasks) t.id: t};
    await _box.putAll(map);
  }

  bool get isBoxOpen => Hive.isBoxOpen(boxName);

  Future<void> close() async {
    if (_box.isOpen) await _box.close();
  }
}
