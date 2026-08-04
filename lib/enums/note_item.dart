class NoteItemData {
  final String id;
  final String? title;
  final List<dynamic> content;
  final DateTime time;

  const NoteItemData({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
  });
}
