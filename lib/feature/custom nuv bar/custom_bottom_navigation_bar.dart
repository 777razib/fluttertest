import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../favourite/screen/favourite_page.dart';
import '../home/screen/home_screen.dart';
import '../message/screen/message_screen.dart';
import '../profile/screen/profile_screen.dart';

class UserNavBar extends StatefulWidget {
  final int initialIndex;

  const UserNavBar({super.key, this.initialIndex = 0});

  @override
  State<UserNavBar> createState() => _UserNavBarState();
}

class _UserNavBarState extends State<UserNavBar> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    HomeScreen(),
    FavouritePage(),
    MessagePage(),
    ProfilePage(),
  ];

  final List<String> _labels = ['Home', 'Favourites', 'Messages', 'Profile'];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final items = List.generate(4, (index) {
      return Icon(
        [
          Icons.home,
          Icons.favorite,
         Icons.message,
         Icons.person
        ][index],
        size: 25,
        color: _selectedIndex == index ? Colors.black : Colors.white,
      );
    });

    const double navHeight = 75;
    const double extraBottom = 18;

    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: navHeight + extraBottom,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CurvedNavigationBar(
                index: _selectedIndex,
                color: const Color(0xFF9F9F9F),
                buttonBackgroundColor: Colors.pinkAccent.shade200,
                backgroundColor: Colors.transparent,
                height: navHeight,
                animationDuration: const Duration(milliseconds: 300),
                animationCurve: Curves.easeInOut,
                items: items,
                onTap: (index) {
                  setState(() => _selectedIndex = index);
                },
              ),
            ),
            Positioned.fill(
              child: LayoutBuilder(builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                final itemCount = items.length;
                final itemWidth = totalWidth / itemCount;
                final selectedCenterX = itemWidth * _selectedIndex + itemWidth / 2;

                final text = _labels[_selectedIndex];
                final textStyle = const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                );
                final TextPainter tp = TextPainter(
                  text: TextSpan(text: text, style: textStyle),
                  textDirection: TextDirection.ltr,
                )..layout();

                final textWidth = tp.width;
                final leftForText = selectedCenterX - textWidth / 2;

                return IgnorePointer(
                  ignoring: true,
                  child: Stack(
                    children: [
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        left: leftForText.clamp(0.0, totalWidth - textWidth),
                        bottom: navHeight - 68,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (child, anim) {
                            return FadeTransition(opacity: anim, child: child);
                          },
                          child: Text(
                            text,
                            key: ValueKey<int>(_selectedIndex),
                            style: textStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
