import 'dart:io';
import 'package:flutter/material.dart';

/// Shows a vertical list of files with a remove icon.
class FileList extends StatelessWidget {
  final List<File> files;
  final void Function(int index) onRemove;

  const FileList({
    Key? key,
    required this.files,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: BoxConstraints(maxHeight: files.length * 40.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: files.length,
        itemBuilder: (context, i) {
          final name = files[i].path.split('/').last;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, size: 16, color: Colors.white),
                    onPressed: () => onRemove(i),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
