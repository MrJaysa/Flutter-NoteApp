import 'package:isar_community/isar.dart';

part 'todo_db.g.dart';

@collection
class TodoData {
  Id id = Isar.autoIncrement;

  String? title;

  @Index(type: IndexType.value, caseSensitive: false)
  List<String> get titleWords => title == null ? [] : Isar.splitWords(title!);

  DateTime? time;

  @Index(type: IndexType.value)
  bool completed;

  @Index(type: IndexType.value)
  DateTime updatedAt;

  TodoData({
    required this.title,
    this.time,
    required this.completed,
    required this.updatedAt,
  });
}
