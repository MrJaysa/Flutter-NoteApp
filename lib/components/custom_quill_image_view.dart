import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class CustomImageEmbedBuilder extends quill.EmbedBuilder {
  final quill.QuillController controller;

  CustomImageEmbedBuilder({required this.controller});

  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, quill.EmbedContext embedContext) {
    final imageUrl = embedContext.node.value.data as String;

    return GestureDetector(
      onTap: () {
        final allImages = _extractImagesFromDocument();
        _openGalleryViewer(context, allImages, imageUrl);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 4),
        child: imageUrl.startsWith('http')
            ? Image.network(imageUrl, fit: BoxFit.contain)
            : Image.file(File(imageUrl), fit: BoxFit.contain),
      ),
    );
  }

  List<String> _extractImagesFromDocument() {
    final List<String> imageUrls = [];

    for (final node in controller.document.root.children) {
      if (node is quill.Line) {
        for (final leaf in node.children) {
          if (leaf is quill.Embed && leaf.value.type == 'image') {
            final data = leaf.value.data;
            if (data is String && data.isNotEmpty) {
              imageUrls.add(data);
            }
          }
        }
      }
    }
    return imageUrls;
  }

  void _openGalleryViewer(
    BuildContext context,
    List<String> images,
    String currentImage,
  ) {
    final int startingPage = images.indexOf(currentImage);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          body: PageView.builder(
            itemCount: images.length,
            controller: PageController(
              initialPage: startingPage >= 0 ? startingPage : 0,
            ),
            itemBuilder: (context, index) {
              final path = images[index];
              return Center(
                child: path.startsWith('http')
                    ? Image.network(path, fit: BoxFit.contain)
                    : Image.file(File(path), fit: BoxFit.contain),
              );
            },
          ),
        ),
      ),
    );
  }
}
