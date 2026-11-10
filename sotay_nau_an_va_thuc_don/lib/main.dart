import 'package:flutter/material.dart';
import 'l10n/app_strings.dart';
import 'screens/auth_screen.dart';
import 'screens/bmi_advisor_screen.dart';
import 'screens/checklist_screen.dart';
import 'screens/home_recipe_screen.dart';
import 'screens/meal_planner_screen.dart';
import 'screens/team_settings_screen.dart';
import 'state/app_state_controller.dart';

void main() {
  runApp(const RecipePlannerApp());
}

class RecipePlannerApp extends StatefulWidget {
  const RecipePlannerApp({super.key});

  @override
  State<RecipePlannerApp> createState() => _RecipePlannerAppState();
}

class _RecipePlannerAppState extends State<RecipePlannerApp> {
  final AppStateController _stateController = AppStateController();

  @override
  void dispose() {
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _stateController,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: AppStrings.tr(
            'app_title',
            _stateController.languageCode,
          ),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1D4ED8),
            ),
            useMaterial3: true,
          ),

          home: _stateController.currentUser == null
              ? AuthScreen(state: _stateController)
              : MainAppShell(state: _stateController),
        );
      },
    );
  }
}

class MainAppShell extends StatefulWidget {
  final AppStateController state;

  const MainAppShell({super.key, required this.state});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final lang = widget.state.languageCode;

    final screens = [
      HomeRecipeScreen(state: widget.state),
      MealPlannerScreen(state: widget.state),
      BmiAdvisorScreen(state: widget.state),
      ChecklistScreen(state: widget.state),
      TeamSettingsScreen(state: widget.state),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.tr('app_title', lang),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: ActionChip(
              avatar: const Icon(Icons.language, size: 16),
              label: Text(
                lang.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: widget.state.toggleLanguage,
            ),
          ),
          IconButton(
            tooltip: AppStrings.tr('logout_btn', lang),
            icon: const Icon(Icons.logout),
            onPressed: widget.state.logout,
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) =>
            setState(() => _selectedIndex = idx),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: AppStrings.tr('nav_recipes', lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month),
            label: AppStrings.tr('nav_planner', lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.monitor_weight_outlined),
            selectedIcon: const Icon(Icons.monitor_weight),
            label: AppStrings.tr('nav_bmi', lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.fact_check_outlined),
            selectedIcon: const Icon(Icons.fact_check),
            label: AppStrings.tr('nav_checklist', lang),
          ),
          NavigationDestination(
            icon: const Icon(Icons.group_outlined),
            selectedIcon: const Icon(Icons.group),
            label: AppStrings.tr('nav_team', lang),
          ),
        ],
      ),
    );
  }
}
