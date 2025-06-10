import 'package:flutter/material.dart';

/// 显示一个对话框，用于为选定的文本添加笔记。
///
/// [context] BuildContext.
/// [selectedText] 用户选中的文本，将显示在对话框中。
///
/// 返回一个 `Future<String?>`，如果用户确认添加，则返回笔记内容，否则返回 `null`。
Future<String?> showArticleAddNoteDialog({
  required BuildContext context,
  required String selectedText,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      final TextEditingController noteController = TextEditingController();
      
      return AlertDialog(
        title: const Text('添加笔记'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选中文字:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                selectedText,
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '笔记内容:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '请输入笔记内容...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final noteText = noteController.text.trim();
              if (noteText.isNotEmpty) {
                Navigator.of(context).pop(noteText);
              }
            },
            child: const Text('添加'),
          ),
        ],
      );
    },
  );
} 