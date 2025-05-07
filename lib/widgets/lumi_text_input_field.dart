import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 📸 optional plugin for camera/gallery

class LumiTextInputField extends StatefulWidget {
  final void Function(String text) onSend;
  final String hintText;

  const LumiTextInputField({
    Key? key,
    required this.onSend,
    this.hintText = "Type your message...",
  }) : super(key: key);

  @override
  State<LumiTextInputField> createState() => _LumiTextInputFieldState();
}

class _LumiTextInputFieldState extends State<LumiTextInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  Future<void> _handleAttachment() async {
    final picker = ImagePicker();

    // You can offer a UI choice here (camera vs gallery vs files)
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print("📎 Picked file: ${pickedFile.path}");
      // Here you'd pass this to your GPT input or upload logic
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // 📎 Left icon (upload / camera)
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.white60, size: 22),
            onPressed: _handleAttachment,
            tooltip: 'Attach file or image',
          ),

          // 📝 Text input
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(color: Colors.white54),
                border: InputBorder.none,
                isDense: true,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
            ),
          ),

          // ✈️ Send button
          IconButton(
            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            onPressed: _handleSend,
            tooltip: 'Send message',
          ),
        ],
      ),
    );
  }
}
