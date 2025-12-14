import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.title,
    this.backgroundColor = Colors.transparent, // Default color
    this.borderColor,
    required this.onPress, // <<<<< MODIFIED: Now accepts VoidCallback?
    this.textStyle = const TextStyle(
      color: Color(0xff2D2D2D), // Default text color if button is active
      fontSize: 16,
      fontWeight: FontWeight.w700,
    ),
  });

  final String title;
  final Color backgroundColor;
  final Color? borderColor;
  final TextStyle textStyle;
  final VoidCallback? onPress; // <<<<< MODIFIED: Made this nullable

  @override
  Widget build(BuildContext context) {
    bool isEnabled = onPress != null; // Check if the button is enabled

    // Adjust colors and splash for disabled state
    Color effectiveBackgroundColor = isEnabled ? backgroundColor : Colors.grey.shade300;
    TextStyle effectiveTextStyle = isEnabled
        ? textStyle
        : textStyle.copyWith(color: Colors.grey.shade600); // Dim text when disabled
    Color splashColor = isEnabled ? Colors.white.withAlpha(128) : Colors.transparent; // No splash when disabled

    return Material(
      color: effectiveBackgroundColor, // Use effective color
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        splashColor: splashColor, // Use effective splash color
        borderRadius: BorderRadius.circular(8),
        onTap: onPress, // This will correctly do nothing if onPress is null
        child: Center(
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border:
              borderColor != null ? Border.all(color: isEnabled ? borderColor! : Colors.grey.shade400) : null, // Dim border when disabled
            ),
            child: Center(child: Text(title, style: effectiveTextStyle)), // Use effective text style
          ),
        ),
      ),
    );
  }
}
