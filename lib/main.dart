import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/day_entry.dart';
import 'services/storage_service.dart';
import 'services/update_service.dart';
import 'utils/constants.dart';
import 'screens/constellation_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/today_screen.dart';
import 'screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppConstants.spaceDarkBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const Gun365App());
}

class Gun365App extends StatelessWidget {
  const Gun365App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '365 Gün',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppConstants.spaceDarkBg,
        primaryColor: AppConstants.accentGold,
        colorScheme: const ColorScheme.dark(
          primary: AppConstants.accentGold,
          surface: AppConstants.spaceSurface,
        ),
        fontFamily: 'Roboto',
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  Map<int, DayEntry> _entries = {};
  Map<int, List<DailyTask>> _tasks = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    await Future.delayed(const Duration(seconds: 2));
    final updateInfo = await UpdateService.checkForUpdate();
    if (updateInfo != null && mounted) {
      UpdateService.showUpdateDialog(context, updateInfo);
    }
  }

  Future<void> _loadData() async {
    final entries = await StorageService.loadEntries();
    final tasks = await StorageService.loadTasks();

    if (mounted) {
      setState(() {
        _entries = entries;
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  void _saveEntry(DayEntry entry) async {
    await StorageService.saveEntry(entry);
    setState(() {
      _entries[entry.dayNumber] = entry;
    });
  }

  void _deleteEntry(int dayNumber) async {
    await StorageService.deleteEntry(dayNumber);
    setState(() {
      _entries.remove(dayNumber);
    });
  }

  void _saveTasks(int dayNumber, List<DailyTask> dayTasks) async {
    await StorageService.saveTasksForDay(dayNumber, dayTasks);
    setState(() {
      if (dayTasks.isEmpty) {
        _tasks.remove(dayNumber);
      } else {
        _tasks[dayNumber] = dayTasks;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppConstants.spaceDarkBg,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.accentGold),
          ),
        ),
      );
    }

    final screens = [
      ConstellationScreen(
        entries: _entries,
        onSaveEntry: _saveEntry,
        onDeleteEntry: _deleteEntry,
      ),
      NotesScreen(
        entries: _entries,
        onSaveEntry: _saveEntry,
        onDeleteEntry: _deleteEntry,
      ),
      TodayScreen(
        entries: _entries,
        tasks: _tasks,
        onSaveEntry: _saveEntry,
        onDeleteEntry: _deleteEntry,
        onSaveTasks: _saveTasks,
      ),
      SettingsScreen(
        entries: _entries,
        onReload: _loadData,
      ),
    ];

    return Scaffold(
      backgroundColor: AppConstants.spaceDarkBg,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppConstants.spaceSurface,
          border: const Border(
            top: BorderSide(color: Colors.white12, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppConstants.accentGold,
          unselectedItemColor: AppConstants.textMuted,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.blur_on_rounded),
              activeIcon: Icon(Icons.grain_rounded),
              label: '365 Gün',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              activeIcon: Icon(Icons.auto_stories_rounded),
              label: 'Notlarım',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wb_twilight_rounded),
              activeIcon: Icon(Icons.star_rounded),
              label: 'Bugün',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Ayarlar',
            ),
          ],
        ),
      ),
    );
  }
}
