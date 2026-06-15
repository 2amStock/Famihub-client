import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'parent_home_screen.dart';
import 'task_list_screen.dart';
import '../shared/meal_suggestion_screen.dart';
import 'parent_settings_screen.dart';
import '../../shared/widgets/widgets.dart';

class ParentMainScreen extends StatefulWidget {
  const ParentMainScreen({super.key});

  @override
  State<ParentMainScreen> createState() => _ParentMainScreenState();
}

class _ParentMainScreenState extends State<ParentMainScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    ParentHomeScreen(onNavigate: (index) => _onItemTapped(index)),
    const TaskListScreen(),
    const MealSuggestionScreen(),
    const ParentSettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWrapper(
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textHint,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_outlined),
                  activeIcon: Icon(Icons.assignment_rounded),
                  label: 'Nhiệm vụ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.auto_awesome_outlined),
                  activeIcon: Icon(Icons.auto_awesome_rounded),
                  label: 'Thực đơn AI',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Tài khoản',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
