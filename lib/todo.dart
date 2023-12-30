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
  })  : id = const Uuid().v4(),
        dateCreated = dateCreated ?? DateTime.now();

  bool get isCompleted => dateCompleted != null;

  String get createdDateString =>
      '${dateCreated.day}/${dateCreated.month}/${dateCreated.year}';

  @override
  String toString() =>
      '${super.toString()}: id: $id, title: $title, dateCreated: $dateCreated, dateCompleted: $dateCompleted';
}
