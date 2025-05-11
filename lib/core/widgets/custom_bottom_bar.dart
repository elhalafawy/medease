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
    return Container(
      height: 68,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, "assets/icons/ic_home.png", "Home", 0),
          _buildNavItem(context, "assets/icons/ic_upload.png", "Upload", 1),
          _buildNavItem(context, "assets/icons/ic_appointment.png", "Appointment", 2),
          _buildNavItem(context, "assets/icons/ic_profile.png", "Profile", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, String iconPath, String label, int index) {
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
            color: isSelected ? AppTheme.primaryColor : AppTheme.greyColor,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.primaryColor : AppTheme.greyColor,
            ),
          ),
        ],
      ),
    );
  }
}
