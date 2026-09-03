import 'package:flutter/material.dart';
import 'package:vagabond/core/constants/app_strings.dart';

class ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onPickMedia;
  final VoidCallback onSendMessage;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.onTextChanged,
    required this.onPickMedia,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
            onPressed: onPickMedia,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: controller,
                onChanged: onTextChanged,
                style: const TextStyle(color: Colors.white),
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: const InputDecoration(
                  hintText: AppStrings.chatTypeMessageHint,
                  hintStyle: TextStyle(color: Colors.white30),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF6366F1)),
            onPressed: onSendMessage,
          ),
        ],
      ),
    );
  }
}
