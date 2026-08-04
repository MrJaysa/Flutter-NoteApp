import 'package:isar_community/isar.dart';

part 'note_db.g.dart';

@collection
class NoteData {
  Id id = Isar.autoIncrement;

  String? title;

  String? contentDelta;

  String? contentText;

  @Index(type: IndexType.value, caseSensitive: false)
  List<String> get contentWords =>
      contentText == null ? [] : Isar.splitWords(contentText!);

  @Index(type: IndexType.value)
  DateTime updatedAt;

  NoteData({
    this.title,
    this.contentDelta,
    this.contentText,
    required this.updatedAt,
  });
}
