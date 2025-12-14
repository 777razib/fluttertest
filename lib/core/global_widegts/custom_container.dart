import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final String imageUrl;
  final String text;
  VoidCallback onTap;
  Color? bgColor;
  double? borderWidth;
  Color? borderColor;
  TextAlign? align;

  CustomContainer({
    required this.imageUrl,
    required this.text,
    required this.onTap,
    this.bgColor,
    this.borderWidth,
    this.borderColor,
    this.align,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => onTap,
      child: Container(
        width: size.width,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            width: borderWidth ?? 1.0,
            color: borderColor ?? Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Image.asset(imageUrl, fit: BoxFit.contain, width: 35, height: 35),

            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
