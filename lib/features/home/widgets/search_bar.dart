import 'package:flutter/material.dart';
import 'package:music_player/core/theme/app_style.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: const TextStyle(color: AppStyle.textColor),
      decoration: InputDecoration(
        hintText: 'Search songs...',
        hintStyle: const TextStyle(
          color: AppStyle.secondaryTextColor,
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: AppStyle.secondaryTextColor,
        ),
        filled: true,
        fillColor: AppStyle.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppStyle.borderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}