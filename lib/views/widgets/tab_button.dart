import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

class TabButton extends StatelessWidget {
  final String tabKey;
  final String label;
  final String currentTab;
  final ValueChanged<String> onTap;

  const TabButton({
    super.key,
    required this.tabKey,
    required this.label,
    required this.currentTab,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentTab == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(tabKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentSky : AppColors.darkSlateBlue,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.accentSky
                  : AppColors.accentSky.withValues(alpha: 0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.deepNavy : AppColors.textLight,
            ),
          ),
        ),
      ),
    );
  }
}
