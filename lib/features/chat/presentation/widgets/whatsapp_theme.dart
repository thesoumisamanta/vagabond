import 'package:flutter/material.dart';

class WhatsAppTheme {
  WhatsAppTheme._();

  // Backgrounds
  static const Color darkBackground = Color(0xFF0B141B);
  static const Color headerBackground = Color(0xFF1F2C34);
  static const Color cardBackground = Color(0xFF111B21);

  // Message Bubbles
  static const Color myMessageBubble = Color(0xFF005C4B);       // Dark green sent bubble
  static const Color otherMessageBubble = Color(0xFF202C33);    // Dark slate received bubble
  static const Color replyQuoteBackground = Color(0xFF182229);  // Quoted reply box inside bubble
  static const Color replyStripMy = Color(0xFF25D366);          // Green accent strip
  static const Color replyStripOther = Color(0xFF53BDEB);       // Cyan/blue accent strip

  // Accents & WhatsApp Branding
  static const Color primaryGreen = Color(0xFF00A884);
  static const Color brightGreen = Color(0xFF25D366);
  static const Color unreadBadgeGreen = Color(0xFF00A884);
  static const Color blueTick = Color(0xFF53BDEB);              // WhatsApp double blue tick
  static const Color greyTick = Color(0xFF8696A0);

  // Input & Buttons
  static const Color inputBackground = Color(0xFF202C33);
  static const Color sendFabGreen = Color(0xFF00A884);
  static const Color iconGrey = Color(0xFF8696A0);

  // Typography
  static const Color textPrimary = Color(0xFFE9EDEF);
  static const Color textSecondary = Color(0xFF8696A0);
  static const Color datePillBackground = Color(0xFF182229);
  static const Color datePillText = Color(0xFF8696A0);
}

