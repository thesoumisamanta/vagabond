import 'package:flutter/material.dart';
import 'package:vagabond/features/chat/presentation/widgets/whatsapp_theme.dart';

class MessageStatusTick extends StatelessWidget {
  final String status;
  final double size;

  const MessageStatusTick({
    super.key,
    required this.status,
    this.size = 15,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'sent':
        return Icon(Icons.check, color: WhatsAppTheme.greyTick, size: size);
      case 'delivered':
        return Icon(Icons.done_all, color: WhatsAppTheme.greyTick, size: size);
      case 'read':
        return Icon(Icons.done_all, color: WhatsAppTheme.blueTick, size: size);
      case 'sending':
      default:
        return Icon(Icons.access_time, color: WhatsAppTheme.greyTick, size: size - 2);
    }
  }
}

