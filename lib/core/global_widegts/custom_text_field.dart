import 'package:flutter/material.dart';

import '../style/global_text_style.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final String? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? title;
  final IconData? icon; // Title row icon (not prefixIcon inside field)

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.obscureText = false,
    this.title,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(
            children: [
              if (icon != null) Icon(icon, size: 18, color: Colors.black),
              if (icon != null) const SizedBox(width: 5),
              Text(
                title!,
                style: globalTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF212529),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: controller,
          style: globalTextStyle(fontSize: 16),
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixText: prefixText,
            prefixStyle: const TextStyle(color: Colors.black),
            hintText: hintText,
            hintStyle: globalTextStyle(
              color: const Color(0xFFA9A9A9),
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xffE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xffE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xffE2E8F0)),
            ),
            prefixIcon: prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Image.asset(prefixIcon!, width: 20),
                  )
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
