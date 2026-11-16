
import 'package:flutter/material.dart';
import 'package:music_player/core/theme/app_style.dart';

class FolderFilter extends StatelessWidget {
  final List<String> folders;
  final String selectedFolder;
  final ValueChanged<String> onChanged;

  const FolderFilter({
    super.key,
    required this.folders,
    required this.selectedFolder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedFolder,
      dropdownColor: AppStyle.surfaceColor,
      isExpanded: true,
      underline: const SizedBox(),
      style: const TextStyle(color: AppStyle.textColor),
      items: [
        const DropdownMenuItem(
          value: 'All',
          child: Text('All Folders'),
        ),
        ...folders.map(
          (folder) => DropdownMenuItem(
            value: folder,
            child: Text(folder),
          ),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
