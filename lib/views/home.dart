import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/config.dart';
import '../core/services/force_update.dart';
import '../viewmodels/providers/info_provider.dart';
import '../viewmodels/theme_provider.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import 'homepage.dart';
import 'search.dart';
import 'settings.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Homepage(),
    Search(),
    Settings(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timestamp) {
      if (Config.firebaseEnabled) {
        checkForcedUpdates();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final infoProvider = context.watch<InfoProvider>();
    return Scaffold(
      appBar: appBar(themeProvider, infoProvider),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages.map((widget) => widget).toList(),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onChanged: (index) {
          if (_currentIndex == index) return;
          _currentIndex = index;
          setState(() {});
        },
      ),
    );
  }

  AppBar appBar(ThemeProvider themeProvider, InfoProvider infoProvider) {
    return AppBar(
      backgroundColor: themeProvider.baseTheme.surface,
      title: FutureBuilder(
        future: infoProvider.fetchCountryInfo(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Text('Fetching Data...',
                style: TextStyle(color: themeProvider.baseTheme.primaryText));
          }
          return Text(snapshot.data ?? 'No Data',
              style: TextStyle(color: themeProvider.baseTheme.primaryText));
        },
      ),
    );
  }
}
