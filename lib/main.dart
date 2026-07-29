import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'data_repository.dart';
import 'screens/cable_design_screen.dart';
import 'screens/coordinated_design_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/database_screen.dart';
import 'screens/protection_design_screen.dart';
import 'screens/standards_screen.dart';
import 'screens/transformer_design_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final themeMode = preferences.getBool('dark_mode') == true
      ? ThemeMode.dark
      : ThemeMode.light;
  runApp(AutoMvCableTxApp(initialThemeMode: themeMode));
}

class AutoMvCableTxApp extends StatefulWidget {
  const AutoMvCableTxApp({super.key, this.initialThemeMode = ThemeMode.light});

  final ThemeMode initialThemeMode;

  @override
  State<AutoMvCableTxApp> createState() => _AutoMvCableTxAppState();
}

class _AutoMvCableTxAppState extends State<AutoMvCableTxApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  Future<void> _toggleTheme() async {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('dark_mode', _themeMode == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto MV Cable & TX Sizing Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      home: AppBootstrap(
        themeMode: _themeMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = EngineeringRepository.instance.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 12),
                    const Text('Controlled engineering data could not be loaded.'),
                    const SizedBox(height: 8),
                    Text(snapshot.error.toString(), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          );
        }
        return AppShell(
          themeMode: widget.themeMode,
          onToggleTheme: widget.onToggleTheme,
        );
      },
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.themeMode,
    required this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback onToggleTheme;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
    NavigationDestination(icon: Icon(Icons.cable_outlined), selectedIcon: Icon(Icons.cable), label: 'MV Cable'),
    NavigationDestination(icon: Icon(Icons.electrical_services_outlined), selectedIcon: Icon(Icons.electrical_services), label: 'Transformer'),
    NavigationDestination(icon: Icon(Icons.account_tree_outlined), selectedIcon: Icon(Icons.account_tree), label: 'Coordination'),
    NavigationDestination(icon: Icon(Icons.security_outlined), selectedIcon: Icon(Icons.security), label: 'Protection'),
    NavigationDestination(icon: Icon(Icons.storage_outlined), selectedIcon: Icon(Icons.storage), label: 'Database'),
    NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Standards'),
  ];

  List<Widget> get _pages => [
        DashboardScreen(onOpenPage: (index) => setState(() => _index = index)),
        const CableDesignScreen(),
        const TransformerDesignScreen(),
        const CoordinatedDesignScreen(),
        const ProtectionDesignScreen(),
        const DatabaseScreen(),
        const StandardsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final content = IndexedStack(index: _index, children: _pages);
        return Scaffold(
          appBar: AppBar(
            title: Text(_destinations[_index].label),
            actions: [
              IconButton(
                tooltip: widget.themeMode == ThemeMode.dark ? 'Use light theme' : 'Use dark theme',
                onPressed: widget.onToggleTheme,
                icon: Icon(
                  widget.themeMode == ThemeMode.dark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: wide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _index,
                      onDestinationSelected: (index) => setState(() => _index = index),
                      labelType: NavigationRailLabelType.all,
                      leading: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Image.asset(
                          'assets/icons/app_icon_512.png',
                          width: 64,
                          height: 64,
                        ),
                      ),
                      destinations: _destinations
                          .map((destination) => NavigationRailDestination(
                                icon: destination.icon,
                                selectedIcon: destination.selectedIcon,
                                label: Text(destination.label),
                              ))
                          .toList(),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: content),
                  ],
                )
              : content,
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (index) => setState(() => _index = index),
                  labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
                  destinations: _destinations,
                ),
        );
      },
    );
  }
}
