import 'package:blue_core/blue_core.dart';
import 'package:flutter/material.dart';

import 'src/home_page.dart';
import 'src/theme.dart';

export 'src/home_page.dart' show HomePage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BlueCore.init();
  runApp(const BlueCoreExampleApp());
}

class BlueCoreExampleApp extends StatefulWidget {
  const BlueCoreExampleApp({super.key});

  @override
  State<BlueCoreExampleApp> createState() => _BlueCoreExampleAppState();
}

class _BlueCoreExampleAppState extends State<BlueCoreExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    final isDark = switch (_themeMode) {
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark,
      ThemeMode.dark => true,
      ThemeMode.light => false,
    };
    setState(() => _themeMode = isDark ? ThemeMode.light : ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return ExampleTheme(
      toggle: _toggleTheme,
      child: MaterialApp(
        title: 'blue_core Example',
        debugShowCheckedModeBanner: false,
        theme: buildExampleTheme(Brightness.light),
        darkTheme: buildExampleTheme(Brightness.dark),
        themeMode: _themeMode,
        home: const HomePage(),
      ),
    );
  }
}
