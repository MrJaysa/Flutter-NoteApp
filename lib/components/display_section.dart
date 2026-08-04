import 'package:flutter/material.dart';
import 'package:notich/modals/theme_modal.dart' show showThemeDialog;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart'; // Import where themeNotifier is declared

class DisplaySection extends StatefulWidget {
  const DisplaySection({super.key});

  @override
  State<DisplaySection> createState() => _DisplaySectionState();
}

class _DisplaySectionState extends State<DisplaySection> {
  String _theme = 'System Default';

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('theme') ?? 'system';

    if (!mounted) return;

    setState(() {
      _theme = switch (value) {
        'light' => 'Light',
        'dark' => 'Dark',
        _ => 'System Default',
      };
    });
  }

  Future<void> _showThemeDialog() async {
    final prefs = await SharedPreferences.getInstance();

    String? selected = prefs.getString('theme') ?? 'system';
    if (!mounted) return;

    final result = await showThemeDialog(context, selectedTheme: selected);

    if (result == null) return;

    await prefs.setString('theme', result);

    themeNotifier.value = switch (result) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    setState(() {
      _theme = switch (result) {
        'light' => 'Light',
        'dark' => 'Dark',
        _ => 'System Default',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Display',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
        ),
        InkWell(
          onTap: _showThemeDialog,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                const Icon(
                  Icons.brightness_6_outlined,
                  size: 24,
                  color: Colors.blueGrey,
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Theme',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      _theme,
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Divider(color: Color.fromARGB(67, 96, 125, 139)),
      ],
    );
  }
}
