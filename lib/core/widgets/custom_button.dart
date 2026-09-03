import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final List<Color>? gradientColors;
  final Color? shadowColor;
  final double borderRadius;
  final double verticalPadding;
  final double fontSize;
  final Color textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.gradientColors,
    this.shadowColor,
    this.borderRadius = 16,
    this.verticalPadding = 16,
    this.fontSize = 16,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [const Color(0xFF6366F1), const Color(0xFF3B82F6)];

    final shadow = shadowColor ?? const Color(0xFF6366F1);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: onPressed == null ? null : LinearGradient(colors: colors),
        color: onPressed == null ? Colors.white.withOpacity(0.1) : null,
        boxShadow: onPressed == null
            ? null
            : [BoxShadow(color: shadow.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: textColor),
              ),
      ),
    );
  }
}
