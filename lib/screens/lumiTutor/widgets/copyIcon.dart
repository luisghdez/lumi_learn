import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopyButton extends StatefulWidget {
  final String text;
  final String label; // e.g. "Copy code", "Copy math", "Copy all"

  const CopyButton({
    Key? key,
    required this.text,
    this.label = "Copy",
  }) : super(key: key);

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _copy,
      borderRadius: BorderRadius.circular(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Icon(
              _copied ? Icons.check : Icons.copy,
              size: 16,
              color: _copied
                  ? const Color.fromARGB(255, 145, 105, 240) // ✅ purple icon
                  : Colors.white70,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            _copied ? "Copied!" : widget.label,
            style: TextStyle(
              color: _copied
                  ? const Color.fromARGB(255, 145, 105, 240) // ✅ purple text
                  : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
