import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';


part 'task.g.dart';


@HiveType(typeId: 0)
class Task extends Equatable {
@HiveField(0)
final String id; 
@HiveField(1)
final String title;
@HiveField(2)
final String description;
@HiveField(3)
final bool completed;
@HiveField(4)
final DateTime createdAt;
@HiveField(5)
final bool isSynced;


const Task({
required this.id,
required this.title,
this.description = '',
this.completed = false,
required this.createdAt,
this.isSynced = false,
});


Task copyWith({
String? id,
String? title,
String? description,
bool? completed,
DateTime? createdAt,
bool? isSynced,
}) {
return Task(
id: id ?? this.id,
title: title ?? this.title,
description: description ?? this.description,
completed: completed ?? this.completed,
createdAt: createdAt ?? this.createdAt,
isSynced: isSynced ?? this.isSynced,
);
}


factory Task.fromJson(Map<String, dynamic> json) => Task(
id: json['id'].toString(),
title: json['title'] ?? '',
description: '',
completed: json['completed'] ?? false,
createdAt: DateTime.now(),
isSynced: true,
);


Map<String, dynamic> toJson() => {
'id': id,
'title': title,
'completed': completed,
};


@override
List<Object?> get props => [id, title, description, completed, createdAt, isSynced];
}