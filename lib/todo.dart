import 'package:uuid/uuid.dart';

class Todo {
  String title;
  DateTime dateCreated;
  DateTime? dateCompleted;
  final String id;

  Todo({
    required this.title,
    DateTime? dateCreated,
    this.dateCompleted,
    String? id,
  })  : id = id ?? const Uuid().v4(),
        dateCreated = dateCreated ?? DateTime.now();

  bool get isCompleted => dateCompleted != null;

  String get createdDateString =>
      '${dateCreated.day}/${dateCreated.month}/${dateCreated.year}';

  @override
  String toString() =>
      '${super.toString()}: id: $id, title: $title, dateCreated: $dateCreated, dateCompleted: $dateCompleted';

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        title: json['title'] as String,
        dateCreated: DateTime.parse(json['dateCreated'] as String),
        dateCompleted:
            DateTime.tryParse((json['dateCompleted'] as String?) ?? ''),
        id: json['id'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'dateCreated': dateCreated.toIso8601String(),
        'dateCompleted': dateCompleted?.toIso8601String(),
        'title': title,
      };
}
