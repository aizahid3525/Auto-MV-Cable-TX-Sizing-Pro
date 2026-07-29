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
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
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
                    const Text(
                      'Controlled engineering data could not be loaded.',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                    ),
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

class _AppDestination {
  const _AppDestination({
    required this.label,
    required this.shortLabel,
    required this.subtitle,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String shortLabel;
  final String subtitle;
  final IconData icon;
  final IconData selectedIcon;
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
  int _databaseRevision = 0;
  DatabaseFilterTransfer? _databaseTransfer;

  static const _destinations = <_AppDestination>[
    _AppDestination(
      label: 'Dashboard',
      shortLabel: 'Dashboard',
      subtitle: 'MV cable and transformer engineering hub',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    _AppDestination(
      label: 'MV Cable Design',
      shortLabel: 'MV Cable',
      subtitle: 'Ampacity, voltage drop and fault withstand',
      icon: Icons.cable_outlined,
      selectedIcon: Icons.cable_rounded,
    ),
    _AppDestination(
      label: 'Transformer Design',
      shortLabel: 'Transformer',
      subtitle: 'Demand, loading, losses and fault duty',
      icon: Icons.electrical_services_outlined,
      selectedIcon: Icons.electrical_services_rounded,
    ),
    _AppDestination(
      label: 'Cable + TX Coordination',
      shortLabel: 'Coordination',
      subtitle: 'Coordinated transformer and MV feeder workflow',
      icon: Icons.account_tree_outlined,
      selectedIcon: Icons.account_tree_rounded,
    ),
    _AppDestination(
      label: 'Protection & Switchgear',
      shortLabel: 'Protection',
      subtitle: 'VCB, fuse, ACB, CT and relay screening',
      icon: Icons.security_outlined,
      selectedIcon: Icons.security_rounded,
    ),
    _AppDestination(
      label: 'Engineering Database',
      shortLabel: 'Database',
      subtitle: 'Search controlled cable, transformer and protection records',
      icon: Icons.storage_outlined,
      selectedIcon: Icons.storage_rounded,
    ),
    _AppDestination(
      label: 'Standards & Sources',
      shortLabel: 'Standards',
      subtitle: 'IEC, MS, ST, TNB and supplementary references',
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
    ),
  ];

  static const _bottomPageIndices = <int>[0, 1, 2, 5];

  List<Widget> get _pages => [
        DashboardScreen(
          onOpenPage: _openPage,
          onOpenDatabase: _openDatabaseFromCoverage,
        ),
        const CableDesignScreen(),
        const TransformerDesignScreen(),
        const CoordinatedDesignScreen(),
        const ProtectionDesignScreen(),
        DatabaseScreen(
          key: ValueKey<int>(_databaseRevision),
          initialTransfer: _databaseTransfer,
        ),
        const StandardsScreen(),
      ];

  void _openPage(int index) {
    if (index < 0 || index >= _destinations.length) {
      return;
    }
    setState(() => _index = index);
  }

  void _openDatabaseFromCoverage(DashboardDatabaseFilter filter) {
    setState(() {
      _databaseTransfer = DatabaseFilterTransfer(
        tabIndex: filter.tabIndex,
        group: filter.group,
        label: filter.label,
      );
      _databaseRevision += 1;
      _index = 5;
    });
  }

  int get _bottomSelectedIndex {
    final index = _bottomPageIndices.indexOf(_index);
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope<Object?>(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _index != 0) {
          setState(() => _index = 0);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          final content = IndexedStack(index: _index, children: _pages);
          return Scaffold(
            drawer: _AppNavigationDrawer(
              selectedIndex: _index,
              destinations: _destinations,
              onSelectPage: _openPage,
              onToggleTheme: widget.onToggleTheme,
              onShowAbout: _showAbout,
              onShowFaq: _showFaq,
            ),
            appBar: AppBar(
              toolbarHeight: 82,
              leadingWidth: 72,
              leading: Builder(
                builder: (context) => IconButton(
                  tooltip: 'Open navigation menu',
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded, size: 31),
                ),
              ),
              titleSpacing: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _destinations[_index].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _destinations[_index].subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  tooltip: isDark ? 'Use light theme' : 'Use dark theme',
                  onPressed: widget.onToggleTheme,
                  icon: Icon(
                    isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_rounded,
                    size: 28,
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
                        onDestinationSelected: _openPage,
                        labelType: NavigationRailLabelType.all,
                        leading: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              'assets/icons/app_icon_512.png',
                              width: 62,
                              height: 62,
                            ),
                          ),
                        ),
                        destinations: [
                          for (final destination in _destinations)
                            NavigationRailDestination(
                              icon: Icon(destination.icon),
                              selectedIcon: Icon(destination.selectedIcon),
                              label: Text(destination.shortLabel),
                            ),
                        ],
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: content),
                    ],
                  )
                : content,
            bottomNavigationBar: wide
                ? null
                : NavigationBar(
                    selectedIndex: _bottomSelectedIndex,
                    onDestinationSelected: (bottomIndex) {
                      _openPage(_bottomPageIndices[bottomIndex]);
                    },
                    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                    destinations: [
                      for (final pageIndex in _bottomPageIndices)
                        NavigationDestination(
                          icon: Icon(_destinations[pageIndex].icon),
                          selectedIcon: Icon(_destinations[pageIndex].selectedIcon),
                          label: _destinations[pageIndex].shortLabel,
                        ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Future<void> _showAbout() {
    final repo = EngineeringRepository.instance;
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            'assets/icons/app_icon_512.png',
            width: 72,
            height: 72,
          ),
        ),
        title: const Text('Auto MV Cable & TX Sizing Pro'),
        content: Text(
          'Modern preliminary MV engineering workflow by AiZahid.\n\n'
          '${repo.cables.length} MV cable records • '
          '${repo.transformers.length} transformer records • '
          '${repo.protectionDevices.length} protection records.\n\n'
          'Version 1.1.0+4 • MVTX-CALC-V1 • MVTX-PROTECTION-V1',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFaq() {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('FAQ & design safeguards'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogFaq(
                question: 'Is this a final design approval tool?',
                answer: 'No. It is a preliminary engineering assistant. Final issue requires competent engineering review and project-specific verification.',
              ),
              _DialogFaq(
                question: 'Why do input fields show a question mark?',
                answer: 'The question mark opens controlled field guidance. Information icons are reserved for calculated results and database-derived outputs.',
              ),
              _DialogFaq(
                question: 'Can the radial chart open matching records?',
                answer: 'Yes. Select an MV cable or transformer family and use View records to open the database with the matching filter.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _AppNavigationDrawer extends StatelessWidget {
  const _AppNavigationDrawer({
    required this.selectedIndex,
    required this.destinations,
    required this.onSelectPage,
    required this.onToggleTheme,
    required this.onShowAbout,
    required this.onShowFaq,
  });

  final int selectedIndex;
  final List<_AppDestination> destinations;
  final ValueChanged<int> onSelectPage;
  final VoidCallback onToggleTheme;
  final VoidCallback onShowAbout;
  final VoidCallback onShowFaq;

  void _openPage(BuildContext context, int index) {
    Navigator.of(context).pop();
    onSelectPage(index);
  }

  void _openDialog(BuildContext context, VoidCallback callback) {
    Navigator.of(context).pop();
    callback();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(
      width: mathMin(MediaQuery.sizeOf(context).width * 0.84, 380),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.navy, AppTheme.blue, AppTheme.cyan],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Image.asset(
                      'assets/icons/app_icon_512.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto MV Cable & TX Sizing Pro',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            height: 1.08,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Engineering hub',
                          style: TextStyle(
                            color: Color(0xFFDDEBFF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
              child: Text(
                'Destinations',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            for (var index = 0; index < destinations.length; index++)
              _DrawerDestinationTile(
                selected: selectedIndex == index,
                icon: destinations[index].icon,
                selectedIcon: destinations[index].selectedIcon,
                title: destinations[index].label,
                subtitle: destinations[index].subtitle,
                onTap: () => _openPage(context, index),
              ),
            const Divider(height: 26),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
              child: Text(
                'App options',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            _SimpleDrawerTile(
              icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              title: isDark ? 'Use light theme' : 'Use dark theme',
              subtitle: 'Change and save the app appearance',
              onTap: () => _openDialog(context, onToggleTheme),
            ),
            _SimpleDrawerTile(
              icon: Icons.info_outline_rounded,
              title: 'About',
              subtitle: 'App purpose, database status and version',
              onTap: () => _openDialog(context, onShowAbout),
            ),
            _SimpleDrawerTile(
              icon: Icons.quiz_outlined,
              title: 'FAQ',
              subtitle: 'Common workflow and helper-icon questions',
              onTap: () => _openDialog(context, onShowFaq),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: Text(
                'Version 1.1.0 (4)\nFuchsia UI, scrollable database and live engineering helpers\nDesign-assist only. Verify final issue against applicable standards, utility requirements and exact manufacturer data.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                  height: 1.42,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerDestinationTile extends StatelessWidget {
  const _DrawerDestinationTile({
    required this.selected,
    required this.icon,
    required this.selectedIcon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final IconData selectedIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.cyanDark : Theme.of(context).colorScheme.onSurfaceVariant;
    return ListTile(
      selected: selected,
      selectedTileColor: AppTheme.cyan.withValues(alpha: 0.08),
      leading: Icon(selected ? selectedIcon : icon, color: color, size: 29),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: selected ? AppTheme.cyanDark : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
        color: color,
      ),
      onTap: onTap,
    );
  }
}

class _SimpleDrawerTile extends StatelessWidget {
  const _SimpleDrawerTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 29),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _DialogFaq extends StatelessWidget {
  const _DialogFaq({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(answer),
        ],
      ),
    );
  }
}

double mathMin(double a, double b) => a < b ? a : b;
