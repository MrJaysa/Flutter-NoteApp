import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChecklistNoteScreen extends StatefulWidget {
  const ChecklistNoteScreen({super.key});

  @override
  State<ChecklistNoteScreen> createState() => _ChecklistNoteScreenState();
}

class ChecklistItem {
  final TextEditingController controller;
  final FocusNode focusNode;
  bool checked;

  ChecklistItem({String text = '', this.checked = false})
    : controller = TextEditingController(text: text),
      focusNode = FocusNode();

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class _ChecklistNoteScreenState extends State<ChecklistNoteScreen> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  bool checklistMode = false;

  final List<ChecklistItem> items = [];

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();

    for (final item in items) {
      item.dispose();
    }

    super.dispose();
  }

  void enableChecklist() {
    if (checklistMode) return;

    setState(() {
      checklistMode = true;

      if (items.isEmpty) {
        items.add(ChecklistItem());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      items.first.focusNode.requestFocus();
    });
  }

  void addItem(int index) {
    final item = ChecklistItem();

    setState(() {
      items.insert(index + 1, item);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      item.focusNode.requestFocus();
    });
  }

  void removeItem(int index) {
    if (items.length == 1) {
      items[index].controller.clear();
      return;
    }

    final previous = index > 0
        ? items[index - 1].focusNode
        : items[1].focusNode;

    items[index].dispose();

    setState(() {
      items.removeAt(index);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      previous.requestFocus();
    });
  }

  Widget buildChecklistItem(int index) {
    final item = items[index];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: item.checked,
          activeColor: Colors.amber,
          onChanged: (value) {
            setState(() {
              item.checked = value ?? false;
            });
          },
        ),

        Expanded(
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) {
                return KeyEventResult.ignored;
              }

              if (event.logicalKey == LogicalKeyboardKey.enter) {
                addItem(index);
                return KeyEventResult.handled;
              }

              if (event.logicalKey == LogicalKeyboardKey.backspace &&
                  item.controller.text.isEmpty) {
                removeItem(index);
                return KeyEventResult.handled;
              }

              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: item.controller,
              focusNode: item.focusNode,
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'List item',
              ),
              style: TextStyle(
                fontSize: 18,
                decoration: item.checked ? TextDecoration.lineThrough : null,
                color: item.checked ? Colors.grey : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("New Note"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_box_outlined),
            onPressed: enableChecklist,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "Title",
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: checklistMode
                  ? ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (_, index) => buildChecklistItem(index),
                    )
                  : TextField(
                      controller: bodyController,
                      expands: true,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Note",
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
