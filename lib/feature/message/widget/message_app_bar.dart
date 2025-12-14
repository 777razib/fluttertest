// lib/widget/message_app_bar.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MessageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MessageAppBar({
    super.key,
    required this.imageUrl,
    required this.title,
    this.subtitle,
    this.isActive = false,
    required this.onAudioCall,
    required this.onVideoCall,
    this.onBack,
  });

  final String imageUrl;
  final String title;
  final String? subtitle;
  final bool isActive;
  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 50,
      toolbarHeight:100, // এটা রাখতেই হবে      backgroundColor: Colors.white,
      elevation: 0.3,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
        onPressed: onBack ?? () => Navigator.maybePop(context),
      ),
      title: Row(
        children: [
          // ====== প্রোফাইল পিকচার + অ্যানিমেটেড অনলাইন ডট ======
          Hero(
            tag: 'chat_avatar_$imageUrl',
            child: Stack(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 500),
                      placeholder: (_, __) => Container(
                        color: Colors.grey.shade300,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(strokeWidth: 3),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade400,
                        child: const Icon(Icons.person, color: Colors.white70, size: 28),
                      ),
                    ),
                  ),
                ),

                // Active Dot - Bottom Right
                if (isActive)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: AnimatedScale(
                      scale: 1.0,
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.elasticOut,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF00),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FF00).withOpacity(0.8),
                              blurRadius: 10,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // নাম + স্ট্যাটাস
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  isActive ? "Active now" : (subtitle ?? "Tap for contact info"),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isActive ? const Color(0xFF00C853) : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      actions: [
        IconButton(
          onPressed: onVideoCall,
          icon: const Icon(Icons.videocam_rounded, size: 27),
          color: Colors.black87,
        ),
        IconButton(
          onPressed: onAudioCall,
          icon: const Icon(Icons.phone_rounded, size: 27),
          color: Colors.black87,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}