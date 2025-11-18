import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/providers/task_bloc.dart';
import 'package:task_manager/services/format_time.dart';
import '../models/task.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  const TaskItem({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
          margin:
              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: task.completed ? Colors.lightBlueAccent.withOpacity(0.3) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(.1),
                    offset: const Offset(0, 4),
                    blurRadius: 10)
              ]),
          duration: const Duration(milliseconds: 600),
          child: ListTile(
            leading: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              // toggle completed and dispatch an update via Bloc
              final toggled = task.copyWith(completed: !task.completed);
              context.read<TaskBloc>().add(TaskUpdated(toggled));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 360),
              width: 30,
              height: 30,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: task.completed ? Colors.lightBlue : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black45, width: .8),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: ScaleTransition(scale: anim, child: child)),
                child: task.completed
                    ? Icon(Icons.check, key: const ValueKey('checked'), color: Colors.white, size: 15)
                    : Icon(Icons.check, key: const ValueKey('unchecked'), color: Colors.transparent, size: 15),
              ),
            ),
          ),
            title: Text(
               task.title.toString(),
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  decoration: task.completed ?TextDecoration.lineThrough : null),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                   task.description,
                  style: TextStyle(
                      color: task.completed ?Colors.grey: Colors.black87,
                      fontWeight: FontWeight.w300),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 5, top: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          formatDateTime(task.createdAt, includeTime: true),
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                    
                        Text(
                          task.completed ?  "Completed" : "Pending",
                          style: TextStyle(
                              fontSize: 12, color: task.completed ? Colors.grey: Colors.lightBlueAccent),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
