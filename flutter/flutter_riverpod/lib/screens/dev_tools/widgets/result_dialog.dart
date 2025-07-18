import 'dart:convert';
import 'package:flutter/material.dart';

void showResultDialog(BuildContext context, String title, dynamic result) {
  showDialog(
    context: context,
    builder: (context) => ResultDialog(title: title, result: result),
  );
}

class ResultDialog extends StatelessWidget {
  final String title;
  final dynamic result;
  
  const ResultDialog({
    Key? key,
    required this.title,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resultString = _formatResult(result);
    
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  resultString,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (result is Map && result.containsKey('error'))
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '错误: ${result['error']}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
        TextButton(
          onPressed: () {
            final data = ClipboardData(text: resultString);
            Clipboard.setData(data);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('已复制到剪贴板')),
            );
          },
          child: const Text('复制'),
        ),
      ],
    );
  }
  
  String _formatResult(dynamic result) {
    if (result == null) {
      return 'null';
    }
    
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(result);
    } catch (e) {
      return result.toString();
    }
  }
} 