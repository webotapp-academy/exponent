import 'package:flutter/material.dart';
import '../screens/my_courses_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/store_screen.dart';
import '../screens/home_screen.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNavBar({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == widget.currentIndex) return;

    // Trigger animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                HomeScreen(userData: const {}),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const MyCoursesScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const StoreScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ProfileScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
        break;
    }
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final Color activeColor = Theme.of(context).primaryColor;
    final Color inactiveColor = Colors.grey[600]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? activeColor.withOpacity(0.15) // Use primaryColor for active bg
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.all(isSelected ? 3 : 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor
                      .withOpacity(0.22) // Use primaryColor for active icon bg
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? activeColor : inactiveColor,
              size: isSelected ? 20 : 16,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: isSelected ? 11 : 9,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
            child: Text(label),
          ),
          const SizedBox(height: 1),
          // Active indicator dot
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSelected ? 4 : 0,
            height: isSelected ? 4 : 0,
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -3),
            spreadRadius: 0,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          // <-- Use SizedBox instead of Container for fixed height
          height: 60, // Reduced from 70 to 60 to avoid overflow
          child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 4, horizontal: 4), // Reduce vertical padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => _onItemTapped(context, 0),
                  child: ScaleTransition(
                    scale: widget.currentIndex == 0
                        ? _scaleAnimation
                        : const AlwaysStoppedAnimation(1.0),
                    child: _buildNavItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      label: 'Home',
                      index: 0,
                      isSelected: widget.currentIndex == 0,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _onItemTapped(context, 1),
                  child: ScaleTransition(
                    scale: widget.currentIndex == 1
                        ? _scaleAnimation
                        : const AlwaysStoppedAnimation(1.0),
                    child: _buildNavItem(
                      icon: Icons.menu_book_outlined,
                      activeIcon: Icons.menu_book,
                      label: 'My Courses',
                      index: 1,
                      isSelected: widget.currentIndex == 1,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _onItemTapped(context, 2),
                  child: ScaleTransition(
                    scale: widget.currentIndex == 2
                        ? _scaleAnimation
                        : const AlwaysStoppedAnimation(1.0),
                    child: _buildNavItem(
                      icon: Icons.store_outlined,
                      activeIcon: Icons.store,
                      label: 'Store',
                      index: 2,
                      isSelected: widget.currentIndex == 2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _onItemTapped(context, 3),
                  child: ScaleTransition(
                    scale: widget.currentIndex == 3
                        ? _scaleAnimation
                        : const AlwaysStoppedAnimation(1.0),
                    child: _buildNavItem(
                      icon: Icons.person_outline,
                      activeIcon: Icons.person,
                      label: 'Profile',
                      index: 3,
                      isSelected: widget.currentIndex == 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
