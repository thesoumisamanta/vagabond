import 'package:flutter/material.dart';
import 'package:vagabond/features/chat/domain/entities/chat.dart';
import 'package:vagabond/features/chat/presentation/widgets/chat_emoji_picker.dart';
import 'package:vagabond/features/chat/presentation/widgets/reply_preview_card.dart';
import 'package:vagabond/features/chat/presentation/widgets/whatsapp_theme.dart';

class ChatInputArea extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onPickGallery;
  final VoidCallback onPickCamera;
  final VoidCallback onPickVideo;
  final VoidCallback onSendMessage;
  final ReplyMessage? replyingTo;
  final VoidCallback? onCancelReply;

  const ChatInputArea({
    super.key,
    required this.controller,
    required this.onTextChanged,
    required this.onPickGallery,
    required this.onPickCamera,
    required this.onPickVideo,
    required this.onSendMessage,
    this.replyingTo,
    this.onCancelReply,
  });

  @override
  State<ChatInputArea> createState() => _ChatInputAreaState();
}

class _ChatInputAreaState extends State<ChatInputArea> {
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_textListener);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiPicker) {
        setState(() => _showEmojiPicker = false);
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_textListener);
    _focusNode.dispose();
    super.dispose();
  }

  void _textListener() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      setState(() => _showEmojiPicker = false);
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
      setState(() => _showEmojiPicker = true);
    }
  }

  void _onEmojiSelected(String emoji) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    int start = selection.start;
    int end = selection.end;

    if (start < 0 || end < 0) {
      start = text.length;
      end = text.length;
    }

    final newText = text.replaceRange(start, end, emoji);
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
    widget.onTextChanged(newText);
  }

  void _onBackspace() {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    int start = selection.start;
    int end = selection.end;

    if (start < 0 || end < 0) {
      start = text.length;
      end = text.length;
    }

    if (start == 0 && end == 0) return;

    if (start != end) {
      final newText = text.replaceRange(start, end, '');
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start),
      );
      widget.onTextChanged(newText);
    } else {
      final beforeCursor = text.substring(0, start).characters;
      if (beforeCursor.isNotEmpty) {
        final lastChar = beforeCursor.last;
        final newStart = start - lastChar.length;
        final newText = text.replaceRange(newStart, start, '');
        widget.controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: newStart),
        );
        widget.onTextChanged(newText);
      }
    }
  }

  void _showAttachmentSheet() {
    if (_showEmojiPicker) {
      setState(() => _showEmojiPicker = false);
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: WhatsAppTheme.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Wrap(
            spacing: 24,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildAttachmentOption(
                icon: Icons.photo_library_rounded,
                color: const Color(0xFF7C3AED),
                label: 'Gallery',
                onTap: () {
                  Navigator.pop(context);
                  widget.onPickGallery();
                },
              ),
              _buildAttachmentOption(
                icon: Icons.camera_alt_rounded,
                color: const Color(0xFFEC4899),
                label: 'Camera',
                onTap: () {
                  Navigator.pop(context);
                  widget.onPickCamera();
                },
              ),
              _buildAttachmentOption(
                icon: Icons.videocam_rounded,
                color: const Color(0xFF06B6D4),
                label: 'Video',
                onTap: () {
                  Navigator.pop(context);
                  widget.onPickVideo();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: WhatsAppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return PopScope(
      canPop: !_showEmojiPicker,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showEmojiPicker) {
          setState(() => _showEmojiPicker = false);
        }
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 8,
                right: 8,
                top: 4,
                bottom: _showEmojiPicker ? 4 : (8 + bottomPadding),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // WhatsApp Quoted Reply Bar
                  if (widget.replyingTo != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4, bottom: 6),
                      child: ReplyPreviewCard(
                        reply: widget.replyingTo!,
                        isInsideBubble: false,
                        isMyMessage: false,
                        onCancel: widget.onCancelReply,
                      ),
                    ),

                  // Input Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Text Field Pill
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: WhatsAppTheme.inputBackground,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Emoji / Keyboard Switch Icon
                              IconButton(
                                icon: Icon(
                                  _showEmojiPicker
                                      ? Icons.keyboard_alt_outlined
                                      : Icons.emoji_emotions_outlined,
                                  color: WhatsAppTheme.iconGrey,
                                ),
                                onPressed: _toggleEmojiPicker,
                              ),

                              // Input Field
                              Expanded(
                                child: TextField(
                                  controller: widget.controller,
                                  focusNode: _focusNode,
                                  onChanged: widget.onTextChanged,
                                  onTap: () {
                                    if (_showEmojiPicker) {
                                      setState(() => _showEmojiPicker = false);
                                    }
                                  },
                                  minLines: 1,
                                  maxLines: 5,
                                  style: const TextStyle(color: WhatsAppTheme.textPrimary, fontSize: 16),
                                  decoration: const InputDecoration(
                                    hintText: 'Message',
                                    hintStyle: TextStyle(color: WhatsAppTheme.textSecondary, fontSize: 16),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),

                              // Attachment Button
                              IconButton(
                                icon: Transform.rotate(
                                  angle: -0.785,
                                  child: const Icon(Icons.attach_file, color: WhatsAppTheme.iconGrey),
                                ),
                                onPressed: _showAttachmentSheet,
                              ),

                              // Camera Button (shown if text is empty)
                              if (!_hasText)
                                IconButton(
                                  icon: const Icon(Icons.camera_alt_rounded, color: WhatsAppTheme.iconGrey),
                                  onPressed: widget.onPickCamera,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // WhatsApp Circular Green FAB
                      GestureDetector(
                        onTap: _hasText ? widget.onSendMessage : null,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: WhatsAppTheme.sendFabGreen,
                          child: Icon(
                            _hasText ? Icons.send : Icons.mic,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // WhatsApp Style Emoji Picker Drawer
            if (_showEmojiPicker)
              ChatEmojiPicker(
                onEmojiSelected: _onEmojiSelected,
                onBackspace: _onBackspace,
              ),
          ],
        ),
      ),
    );
  }
}
