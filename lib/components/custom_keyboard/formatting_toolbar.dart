import 'package:Notich/components/custom_keyboard/background_palette.dart';
import 'package:Notich/components/custom_keyboard/color_palette.dart';
import 'package:Notich/components/custom_keyboard/editor_colors.dart';
import 'package:Notich/components/custom_keyboard/toolbar_btn.dart';
import 'package:Notich/components/custom_keyboard/toolbar_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show QuillController, Attribute, IndentAttribute;

class FormattingToolbar extends StatefulWidget {
  final QuillController controller;

  const FormattingToolbar({super.key, required this.controller});

  @override
  State<FormattingToolbar> createState() => _FormattingToolbarState();
}

class _FormattingToolbarState extends State<FormattingToolbar> {
  QuillController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    controller.removeListener(_controllerListener);
    super.dispose();
  }

  void _controllerListener() {
    if (mounted) {
      setState(() {});
    }
  }

  Map<String, Attribute> get _attrs =>
      controller.getSelectionStyle().attributes;

  bool _isActive(Attribute attribute) => _attrs.containsKey(attribute.key);

  dynamic _value(Attribute attribute) => _attrs[attribute.key]?.value;

  bool _isValueActive(Attribute attribute, dynamic value) {
    return _value(attribute) == value;
  }

  void _toggle(Attribute attribute) {
    controller.formatSelection(
      _isActive(attribute) ? Attribute.clone(attribute, null) : attribute,
      // ignore: experimental_member_use
      shouldNotifyListeners: false,
    );
    setState(() {});
  }

  void _toggleValue(
    Attribute keyAttribute,
    dynamic activeValue,
    Attribute applyAttribute,
  ) {
    final isActive = _isValueActive(keyAttribute, activeValue);

    controller.formatSelection(
      isActive ? Attribute.clone(keyAttribute, null) : applyAttribute,
      // ignore: experimental_member_use
      shouldNotifyListeners: false,
    );
  }

  void _clearAttribute(Attribute attribute) {
    if (_value(attribute) == null) {
      return;
    }

    controller.formatSelection(
      Attribute.clone(attribute, null),
      // ignore: experimental_member_use
      shouldNotifyListeners: false,
    );
  }

  bool get _canIncreaseIndent => ((_value(Attribute.indent) as int?) ?? 0) < 5;

  bool get _canDecreaseIndent => ((_value(Attribute.indent) as int?) ?? 0) > 0;

  void _changeIndent(bool increase) {
    final current = (_value(Attribute.indent) as int?) ?? 0;

    if (increase) {
      if (current >= 5) return;

      controller.formatSelection(
        IndentAttribute(level: current + 1),
        // ignore: experimental_member_use
        shouldNotifyListeners: false,
      );
    } else {
      if (current <= 0) return;

      controller.formatSelection(
        current == 1
            ? Attribute.clone(Attribute.indent, null)
            : IndentAttribute(level: current - 1),
        // ignore: experimental_member_use
        shouldNotifyListeners: false,
      );
    }

    setState(() {});
  }

  void _toggleList(Attribute listAttribute) {
    final current = _value(Attribute.list);

    controller.formatSelection(
      current == listAttribute.value
          ? Attribute.clone(Attribute.list, null)
          : listAttribute,
      // ignore: experimental_member_use
      shouldNotifyListeners: false,
    );
  }

  void _setAlignment(Attribute? attribute) {
    final current = _value(Attribute.align);

    controller.formatSelection(
      current == attribute?.value
          ? Attribute.clone(Attribute.align, 'left')
          : (attribute ?? Attribute.clone(Attribute.align, null)),
      // ignore: experimental_member_use
      shouldNotifyListeners: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: EditorColors.background,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ToolbarGroup(
            height: 56,
            children: [
              ToolbarBtn(
                onTap: () => _toggleValue(Attribute.header, 1, Attribute.h1),
                backgroundColor: _isValueActive(Attribute.header, 1)
                    ? EditorColors.panelActive
                    : Colors.transparent,
                child: const Text(
                  "H1",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 21),
                ),
              ),
              ToolbarBtn(
                onTap: () => _toggleValue(Attribute.header, 2, Attribute.h2),
                backgroundColor: _isValueActive(Attribute.header, 2)
                    ? EditorColors.panelActive
                    : Colors.transparent,
                child: const Text(
                  "H2",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                ),
              ),
              ToolbarBtn(
                onTap: () => _toggleValue(Attribute.header, 3, Attribute.h3),
                backgroundColor: _isValueActive(Attribute.header, 3)
                    ? EditorColors.panelActive
                    : Colors.transparent,
                child: const Text(
                  "H3",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 19),
                ),
              ),
              ToolbarBtn(
                onTap: () => _toggleValue(Attribute.header, 4, Attribute.h4),
                backgroundColor: _isValueActive(Attribute.header, 4)
                    ? EditorColors.panelActive
                    : Colors.transparent,
                child: const Text(
                  "H4",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                ),
              ),
              ToolbarBtn(
                onTap: () => _clearAttribute(Attribute.header),
                backgroundColor: _value(Attribute.header) == null
                    ? EditorColors.panelActive
                    : Colors.transparent,
                child: const Text(
                  "body",
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: ToolbarGroup(
                  height: 52,
                  children: [
                    ToolbarBtn(
                      onTap: () => _toggle(Attribute.bold),
                      backgroundColor: _isActive(Attribute.bold)
                          ? EditorColors.panelActive
                          : Colors.transparent,
                      child: const Icon(Icons.format_bold),
                    ),
                    ToolbarBtn(
                      onTap: () => _toggle(Attribute.italic),
                      backgroundColor: _isActive(Attribute.italic)
                          ? EditorColors.panelActive
                          : Colors.transparent,
                      child: const Icon(Icons.format_italic),
                    ),
                    ToolbarBtn(
                      onTap: () => _toggle(Attribute.underline),
                      backgroundColor: _isActive(Attribute.underline)
                          ? EditorColors.panelActive
                          : Colors.transparent,
                      child: const Icon(Icons.format_underline),
                    ),
                    ToolbarBtn(
                      onTap: () => _toggle(Attribute.strikeThrough),
                      backgroundColor: _isActive(Attribute.strikeThrough)
                          ? EditorColors.panelActive
                          : Colors.transparent,
                      child: const Icon(Icons.format_strikethrough),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                flex: 2,
                child: ToolbarGroup(
                  height: 52,
                  children: [
                    ToolbarBtn(
                      onTap: _canIncreaseIndent
                          ? () => _changeIndent(true)
                          : null,
                      backgroundColor: Colors.transparent,
                      child: Icon(
                        Icons.format_indent_increase,
                        color: _canIncreaseIndent
                            ? Colors.white
                            : const Color.fromARGB(255, 83, 83, 83),
                      ),
                    ),
                    ToolbarBtn(
                      onTap: _canDecreaseIndent
                          ? () => _changeIndent(false)
                          : null,
                      backgroundColor: Colors.transparent,
                      child: Transform.flip(
                        flipX: true,
                        child: Icon(
                          Icons.format_indent_increase,
                          color: _canDecreaseIndent
                              ? Colors.white
                              : const Color.fromARGB(255, 83, 83, 83),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: ToolbarGroup(
                  height: 52,
                  children: [
                    ToolbarBtn(
                      onTap: () => _toggleList(Attribute.ol),
                      backgroundColor:
                          _isValueActive(Attribute.list, Attribute.ol.value)
                          ? EditorColors.panelActive
                          : Colors.transparent,
                      child: const Icon(Icons.format_list_numbered),
                    ),
                    ToolbarBtn(
                      onTap: () => _toggleList(Attribute.ul),
                      backgroundColor:
                          _isValueActive(Attribute.list, Attribute.ul.value)
                          ? EditorColors.panelActive
                          : Colors.transparent,
                      child: const Icon(Icons.format_list_bulleted),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                flex: 3,
                child: ToolbarGroup(
                  height: 52,
                  children: [
                    ToolbarBtn(
                      onTap: () => _setAlignment(Attribute.leftAlignment),
                      backgroundColor:
                          _isValueActive(
                            Attribute.align,
                            _value(Attribute.align) != null
                                ? Attribute.leftAlignment.value
                                : null,
                          )
                          ? EditorColors.panelActive
                          : Colors.transparent,
                      child: const Icon(Icons.format_align_left),
                    ),
                    ToolbarBtn(
                      onTap: () => _setAlignment(Attribute.centerAlignment),
                      backgroundColor:
                          _isValueActive(
                            Attribute.align,
                            Attribute.centerAlignment.value,
                          )
                          ? EditorColors.panelActive
                          : Colors.transparent,
                      child: const Icon(Icons.format_align_center),
                    ),
                    ToolbarBtn(
                      onTap: () => _setAlignment(Attribute.justifyAlignment),
                      backgroundColor:
                          _isValueActive(
                            Attribute.align,
                            Attribute.justifyAlignment.value,
                          )
                          ? EditorColors.panelActive
                          : Colors.transparent,
                      child: const Icon(Icons.format_align_justify),
                    ),
                    ToolbarBtn(
                      onTap: () => _setAlignment(Attribute.rightAlignment),
                      backgroundColor:
                          _isValueActive(
                            Attribute.align,
                            Attribute.rightAlignment.value,
                          )
                          ? EditorColors.panelActive
                          : Colors.transparent,
                      child: const Icon(Icons.format_align_right),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: EditorColors.panel,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ColorPalette(
                    colors: EditorColors.textColors,
                    selectedColor: Color(
                      int.parse(
                        (_value(Attribute.color) ?? '0xffffffff').replaceFirst(
                          '#',
                          '0xff',
                        ),
                      ),
                    ),
                    onSelected: (color) {
                      final hex =
                          '#${color.toARGB32().toRadixString(16).substring(2)}';

                      controller.formatSelection(
                        Attribute.fromKeyValue('color', hex),
                        // ignore: experimental_member_use
                        shouldNotifyListeners: false,
                      );

                      setState(() {});
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: EditorColors.panel,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: BackgroundPalette(
                    colors: EditorColors.backgroundColors,
                    selectedColor:
                        (_value(Attribute.background) as String?) == null
                        ? null
                        : Color(
                            int.parse(
                              (_value(Attribute.background) as String)
                                  .replaceFirst('#', '0xff'),
                            ),
                          ),
                    onSelected: (bg) {
                      final current = _value(Attribute.background) as String?;
                      final hex =
                          '#${bg.toARGB32().toRadixString(16).substring(2)}';

                      controller.formatSelection(
                        current == hex
                            ? Attribute.clone(Attribute.background, null)
                            : Attribute.fromKeyValue(
                                Attribute.background.key,
                                hex,
                              ),
                        // ignore: experimental_member_use
                        shouldNotifyListeners: false,
                      );

                      setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
