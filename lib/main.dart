import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_app/models/model.dart';
import 'package:test_app/router.dart';

void main() async {
  await Database.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    final isDark = brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: MaterialApp.router(
        title: 'Notes & To-Dos App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white,
            brightness: Brightness.light,
            primary: Colors.amber,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.white,
            brightness: Brightness.dark,
            primary: Colors.amber,
          ),
        ),

        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }
}
