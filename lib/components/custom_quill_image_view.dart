import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class CustomImageEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, quill.EmbedContext embedContext) {
    final imageUrl = embedContext.node.value.data as String;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 4),
      child: imageUrl.startsWith('http')
          ? Image.network(imageUrl, fit: BoxFit.contain)
          : Image.file(File(imageUrl), fit: BoxFit.contain),
    );
  }
}
