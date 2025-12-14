import 'package:flutter/material.dart';

import '../style/global_text_style.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onLeadingTap;

  const CustomAppBar({super.key, required this.title, this.onLeadingTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onLeadingTap,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/back_button2.png",
              height: 60,
              width: 60,
              fit: BoxFit.cover,
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 50),
              child: title.isEmpty
                  ? Text("")
                  : Text(
                      title,
                      style: globalTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF000000),
                      ),
                    ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
