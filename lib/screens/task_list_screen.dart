import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/providers/task_bloc.dart';
import 'package:task_manager/repositories/task_repository.dart';
import 'package:task_manager/screens/statistic_screen.dart';
import 'package:task_manager/screens/task_detail_screen.dart';
import 'package:task_manager/widgets/error_view.dart';
import 'package:task_manager/widgets/fa_b.dart';
import 'package:task_manager/widgets/offline_banner.dart';
import 'package:task_manager/widgets/task_item.dart';
import 'package:task_manager/widgets/theme_toggle.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
       OfflineBanner(),
        Expanded(
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              // backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              title: const Text('Tasks'),
              actions:  [Padding(
                padding: EdgeInsets.only(right: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => StatisticsScreen()));
                  },
                  child: Text('Stats')
                ),
              ), ThemeToggle()],
            ),
            body: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is TaskLoadFailure) {
                  return ErrorView(
                    message: state.error,
                    onRetry: () => context.read<TaskBloc>().add(TaskLoadRequested()),
                  );
                }
          
                if (state is TaskLoadSuccess) {
                  // final tasks = state.tasks;
                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<TaskBloc>().add(TaskRefreshed()),
                    child: ListView.builder(
                      itemCount: state.tasks.length,
                      itemBuilder: (context, index) {
                        final t = state.tasks[index];
                        return Dismissible(
                          key: Key(t.id),
                          direction: DismissDirection.horizontal,
                          confirmDismiss: (direction) async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete task'),
                                content: const Text(
                                  'Are you sure you want to delete this task?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            return shouldDelete ?? false;
                          },
                          onDismissed: (direction) {
                            final removedTask = t;
                            context.read<TaskBloc>().add(TaskDeleted(removedTask.id));
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Task deleted'),
                                action: SnackBarAction(
                                  label: 'UNDO',
                                  onPressed: () async {
                                    try {
                                      final repo =
                                          RepositoryProvider.of<TaskRepository>(
                                            context,
                                            listen: false,
                                          );
                                      await repo.addTask(removedTask);
                                      context.read<TaskBloc>().add(TaskRefreshed());
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to restore task: $e'),
                                        ),
                                      );
                                    }
                                  },
                                ),
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          },
                          background: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Container(
                                color: Theme.of(context).colorScheme.error.withOpacity(0.12),
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete_outline),
                                    const SizedBox(width: 8),
                                    Text('Delete task', style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                          ),
            secondaryBackground: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            color: Theme.of(context).colorScheme.error.withOpacity(0.12),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Delete', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 8),
                const Icon(Icons.delete),
              ],
            ),
          ),
            ),
                          child: TaskItem(
                            task: t,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(task: t),
                                // TaskDetailScreen(task: t),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
            floatingActionButton: FaB(),
          ),
        ),
      ],
    );
  }
}
