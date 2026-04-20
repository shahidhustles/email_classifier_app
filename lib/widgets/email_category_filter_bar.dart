import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../providers/email_provider.dart';

class EmailCategoryFilterBar extends StatelessWidget {
  const EmailCategoryFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final EmailFilter selectedFilter;
  final ValueChanged<EmailFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: EmailFilter.values.map((EmailFilter filter) {
          final bool selected = filter == selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: InkWell(
              onTap: () => onFilterSelected(filter),
              borderRadius: BorderRadius.circular(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected ? AppColors.textPrimary : AppColors.border,
                      width: selected ? 2 : 1,
                    ),
                  ),
                ),
                child: Text(
                  filter.label,
                  style: textTheme.bodyMedium?.copyWith(
                    color: selected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}
