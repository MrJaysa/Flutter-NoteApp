import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notich/helpers/notification.dart';
import 'package:notich/models/model.dart';
import 'package:notich/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  await Database.instance.init();
  await NotificationService().init();

  switch (prefs.getString('theme')) {
    case 'light':
      themeNotifier.value = ThemeMode.light;
      break;
    case 'dark':
      themeNotifier.value = ThemeMode.dark;
      break;
    default:
      themeNotifier.value = ThemeMode.system;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        final platformBrightness = MediaQuery.platformBrightnessOf(context);

        final isDark = switch (themeMode) {
          ThemeMode.dark => true,
          ThemeMode.light => false,
          ThemeMode.system => platformBrightness == Brightness.dark,
        };

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarContrastEnforced: false,
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark
                ? Brightness.light
                : Brightness.dark,
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
                tertiary: const Color.fromARGB(137, 23, 37, 44),
                onTertiary: Colors.black,
                primaryContainer: const Color.fromARGB(255, 232, 232, 232),
                onSecondary: Colors.black87,
                secondaryContainer: Colors.white,
                outline: Colors.black87,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.white,
                brightness: Brightness.dark,
                primary: Colors.amber,
                tertiary: Colors.white,
                onTertiary: Colors.white,
                primaryContainer: const Color.fromARGB(255, 24, 24, 24),
                onSecondary: Colors.white70,
                secondaryContainer: const Color(0xFF2B2A2A),
                outline: Colors.grey,
              ),
            ),
            themeMode: themeMode,
            routerConfig: appRouter,
          ),
        );
      },
    );
  }
}
