import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/providers/task_bloc.dart';
import 'package:task_manager/screens/task_detail_screen.dart';
import 'package:task_manager/widgets/stat_tile.dart';
import '../models/task.dart';
import '../widgets/task_item.dart'; 

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Task Stats')),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskLoadFailure) {
            return Center(child: Text('Failed to load stats: ${state.error}'));
          }

          if (state is TaskLoadSuccess) {
            final List<Task> tasks = state.tasks;
            final total = tasks.length;
            final completed = tasks.where((t) => t.completed).toList();
            final pending = tasks.where((t) => !t.completed).toList();
            final percent = total == 0 ? 0.0 : (completed.length / total);

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top stat tiles row
                  Row(
                    children: [
                      Expanded(child: StatTile(label: 'Total', value: '$total')),
                      const SizedBox(width: 12),
                      Expanded(child: StatTile(label: 'Completed', value: '${completed.length}')),
                      const SizedBox(width: 12),
                      Expanded(child: StatTile(label: 'Pending', value: '${pending.length}')),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Completion percentage with progress bar
                  Text('Completion', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 8,
                          backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.06),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${(percent * 100).round()}%'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Expanded(
                    child: ListView(
                      children: [
                        ExpansionTile(
                          initiallyExpanded: pending.isNotEmpty,
                          leading: Icon(Icons.pending_actions, color: Theme.of(context).colorScheme.primary),
                          title: Text('Pending (${pending.length})'),
                          children: pending.isEmpty
                              ? [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text('No pending tasks', style: Theme.of(context).textTheme.bodyMedium),
                                  )
                                ]
                              : pending.map((t) {
                                  // Use a compact ListTile for grouped view.
                                  return ListTile(
                                    title: Text(t.title),
                                    subtitle: t.description.isNotEmpty ? Text(t.description, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                                    trailing: Text(
                                      _formatDate(t.createdAt),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => TaskDetailScreen(task: t)),
                                      );
                                    },
                                  );
                                }).toList(),
                        ),

                        ExpansionTile(
                          initiallyExpanded: completed.isNotEmpty,
                          leading: Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.secondary),
                          title: Text('Completed (${completed.length})'),
                          children: completed.isEmpty
                              ? [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text('No completed tasks', style: Theme.of(context).textTheme.bodyMedium),
                                  )
                                ]
                              : completed.map((t) {
                                  return ListTile(
                                    title: Text(
                                      t.title,
                                      style: TextStyle(decoration: TextDecoration.lineThrough),
                                    ),
                                    subtitle: t.description.isNotEmpty ? Text(t.description, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                                    trailing: Text(
                                      _formatDate(t.createdAt),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => TaskDetailScreen(task: t)),
                                      );
                                    },
                                  );
                                }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          // default (initial)
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // small date formatter
  static String _formatDate(DateTime d) {
    // simple formatting: dd/mm
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm';
  }
}
