import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class MainLayout extends StatefulWidget {
  final Widget child;

  const MainLayout({Key? key, required this.child}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  void _onItemTapped(int index, BuildContext context) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/super-admin');
        break;
      case 1:
        context.go('/ai-hub');
        break;
      case 2:
        context.go('/alerts');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to extend behind BottomAppBar
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(1, context),
        backgroundColor: _currentIndex == 1
            ? AppTheme.primaryGreen
            : Colors.grey.shade800,
        elevation: 8,
        shape: const CircleBorder(),
        child: Icon(
          FontAwesomeIcons.brain,
          color: _currentIndex == 1 ? Colors.white : Colors.white70,
          size: 26,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF1E1E2C).withOpacity(0.95),
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0,
        elevation: 10,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.dashboard_rounded, 'Manage', 0, context),
              const SizedBox(width: 60), // Space for centered FAB
              _buildNavItem(Icons.notifications_rounded, 'Alerts', 2, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    int index,
    BuildContext context,
  ) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppTheme.primaryGreen : Colors.white54;

    return InkWell(
      onTap: () => _onItemTapped(index, context),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
