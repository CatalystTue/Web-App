import 'package:catalyst_flutter_app/core/constants/config.dart';
import 'package:flutter/material.dart';

class HomeNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onChangedMenu;

  const HomeNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onChangedMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onChangedMenu,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppConfig().colors.primaryColor,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          elevation: 0,
          items: [
            _buildNavItem(Icons.settings, "Settings", 0),
            _buildNavItem(Icons.lightbulb_outline_rounded, "My Ideas", 1),
            _buildNavItem(Icons.home_filled, "Home", 2),
            _buildNavItem(Icons.link, "Matches", 3),
            //_buildNavItem(Icons.chat, "Chat", 4), //TODO chat functionality should not be available for the prototype
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: currentIndex == index
              ? AppConfig().colors.secondaryColor
              : Colors.transparent,
        ),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}
