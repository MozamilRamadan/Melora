import 'package:flutter/material.dart';
import 'package:music_player/core/theme/app_style.dart';

class SortButton extends StatelessWidget {
  final String selectedSort;
  final ValueChanged<String> onSortChanged;

  const SortButton({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.sort,
        color: AppStyle.textColor,
      ),
      color: AppStyle.surfaceColor,
      initialValue: selectedSort,
      onSelected: onSortChanged,
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'title',
          child: Text('Name'),
        ),
        PopupMenuItem(
          value: 'duration',
          child: Text('Duration'),
        ),
      ],
    );
  }
}