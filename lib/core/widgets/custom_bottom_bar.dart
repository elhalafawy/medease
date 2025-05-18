import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTabChange;

  const CustomBottomBar({
    super.key, 
    required this.currentIndex,
    this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 68,
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, "assets/icons/ic_home.png", "Home", 0, theme),
          _buildNavItem(context, "assets/icons/ic_upload.png", "Upload", 1, theme),
          _buildNavItem(context, "assets/icons/ic_appointment.png", "Appointment", 2, theme),
          _buildNavItem(context, "assets/icons/ic_profile.png", "Profile", 3, theme),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String iconPath, String label, int index, ThemeData theme) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (onTabChange != null) {
          onTabChange!(index);
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/',
            (route) => false,
            arguments: {'initialTab': index},
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            height: 24,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(120),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withAlpha(120),
            ),
          ),
        ],
      ),
    );
  }
}
