enum NotePreviewType { checkbox, list, image, text, title }

class NotePreview {
  final NotePreviewType type;
  final String title;
  final String text;
  final String? image;

  const NotePreview({
    required this.type,
    required this.title,
    required this.text,
    this.image,
  });
}

NotePreview getNotePreview(String? title, List<dynamic> delta) {
  bool hasCheckbox = false;
  bool hasList = false;
  bool hasImage = false;
  bool hasPlainText = false;

  String firstText = '';
  String imageUrl = '';

  String currentLineText = '';

  for (final op in delta) {
    final insert = op['insert'];
    final attributes = op['attributes'];

    if (insert is String) {
      if (insert.contains('\n')) {
        final lines = insert.split('\n');

        currentLineText += lines.first;
        if (currentLineText.trim().isNotEmpty && firstText.isEmpty) {
          firstText = currentLineText.trim();
        }

        if (attributes != null &&
            (attributes['list'] == 'checked' ||
                attributes['list'] == 'unchecked')) {
          hasCheckbox = true;
        } else if (attributes != null && attributes['list'] != null) {
          hasList = true;
        } else if (currentLineText.trim().isNotEmpty) {
          hasPlainText = true;
        }

        for (int i = 1; i < lines.length - 1; i++) {
          if (lines[i].trim().isNotEmpty) {
            hasPlainText = true;
            if (firstText.isEmpty) firstText = lines[i].trim();
          }
        }

        currentLineText = lines.last;
        if (currentLineText.trim().isNotEmpty && firstText.isEmpty) {
          firstText = currentLineText.trim();
        }
      } else {
        currentLineText += insert;
        if (insert.trim().isNotEmpty && firstText.isEmpty) {
          firstText = insert.trim();
        }
      }
    } else if (insert is Map && insert.containsKey('image')) {
      hasImage = true;
      if (imageUrl.isEmpty) {
        imageUrl = insert['image'].toString();
      }
    }
  }

  if (currentLineText.trim().isNotEmpty) {
    hasPlainText = true;
  }

  if (title != null && title.isNotEmpty) {
    return NotePreview(
      type: NotePreviewType.title,
      title: title,
      text: firstText,
      image: imageUrl.isNotEmpty ? imageUrl : null,
    );
  }

  int activeTypesCount = 0;
  if (hasCheckbox) activeTypesCount++;
  if (hasList) activeTypesCount++;
  if (hasImage) activeTypesCount++;
  if (hasPlainText) activeTypesCount++;

  if (activeTypesCount > 1) {
    hasCheckbox = false;
    hasList = false;
    hasImage = false;
    hasPlainText = true;
  }

  if (hasCheckbox) {
    return NotePreview(
      type: NotePreviewType.checkbox,
      title: 'Check List',
      text: firstText,
    );
  }

  if (hasList) {
    return NotePreview(
      type: NotePreviewType.list,
      title: 'Item List',
      text: firstText,
    );
  }

  if (hasImage) {
    return NotePreview(
      type: NotePreviewType.image,
      title: 'Image Note',
      text: firstText,
      image: imageUrl,
    );
  }

  return NotePreview(
    type: NotePreviewType.text,
    title: firstText,
    text: "",
    image: imageUrl,
  );
}
