import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  final String type;
  const SearchScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30,
        toolbarHeight: 68,

        title: Hero(
          tag: type,
          child: Material(
            type: MaterialType.transparency,
            child: SearchBar(
              autoFocus: true,
              hintText: 'Search',
              hintStyle: WidgetStateProperty.all(
                const TextStyle(
                  color: Colors.white38,
                  fontWeight: FontWeight.w400,
                ),
              ),
              leading: const Icon(
                Icons.search,
                color: Color.fromARGB(255, 106, 104, 104),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              constraints: const BoxConstraints(minHeight: 50, maxHeight: 50),
            ),
          ),
        ),
      ),
    );
  }
}
