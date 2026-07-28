import 'package:isar_community/isar.dart';

part 'note_db.g.dart';

@collection
class NoteData {
  Id id = Isar.autoIncrement;

  @Index(type: IndexType.value)
  String? title;

  String? contentDelta;

  @Index(type: IndexType.value)
  String? contentText;

  @Index(type: IndexType.value)
  DateTime updatedAt;

  NoteData({
    this.title,
    this.contentDelta,
    this.contentText,
    required this.updatedAt,
  });
}
