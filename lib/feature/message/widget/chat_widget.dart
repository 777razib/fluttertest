import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({
    super.key,
    this.text,
    this.fileUrl,
    this.fileType,
    required this.isMe,
    this.time,
    this.fileName,
  });

  final String? text;
  final String? fileUrl;
  final String? fileType;
  final bool isMe;
  final String? time;
  final String? fileName;

  bool get hasMedia => fileUrl != null && fileUrl!.isNotEmpty;

  // স্মার্ট URL লঞ্চার — অ্যাপ খুলবে, না পারলে ব্রাউজার
  Future<void> _launchSmartUrl(String url) async {
    Uri? appUri;
    Uri webUri = Uri.parse(url);

    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      // YouTube App Deep Link
      final videoId = url.contains('youtu.be')
          ? url.split('/').last.split('?').first
          : Uri.parse(url).queryParameters['v'];
      if (videoId != null) {
        appUri = Uri(scheme: 'vnd.youtube', path: videoId);
      }
    }
    else if (url.contains('instagram.com')) {
      // Instagram Deep Link
      appUri = Uri(scheme: 'instagram', host: 'stories');
      if (url.contains('/p/') || url.contains('/reel/')) {
        final code = url.split('/p/').last.split('/').first;
        final reelCode = url.split('/reel/').last.split('/').first;
        appUri = Uri.parse("instagram://media?id=${code.isEmpty ? reelCode : code}");
      }
    }
    else if (url.contains('facebook.com') || url.contains('fb.com')) {
      // Facebook App
      appUri = Uri.parse("fb://facewebmodal/f?href=$url");
    }
    else if (url.contains('tiktok.com')) {
      appUri = Uri.parse(url.replaceFirst('https://', 'tiktok://'));
    }
    else if (url.contains('twitter.com') || url.contains('x.com')) {
      appUri = Uri.parse("twitter://status");
      webUri = Uri.parse(url.replaceFirst('x.com', 'twitter.com'));
    }
    else if (url.contains('wa.me') || url.contains('whatsapp.com')) {
      appUri = Uri.parse(url.replaceFirst('https://', 'whatsapp://'));
    }

    // প্রথমে অ্যাপে খোলার চেষ্টা
    if (appUri != null) {
      final bool launched = await launchUrl(appUri, mode: LaunchMode.externalNonBrowserApplication);
      if (launched) return;
    }

    // অ্যাপ না থাকলে ব্রাউজারে
    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> urls = _extractUrls(text ?? '');
    final bool hasLink = urls.isNotEmpty;
    final String? firstUrl = hasLink ? urls.first : null;

    final bool isImage = fileType == 'image';
    final bool isVideo = fileType == 'video';
    final bool isFile = fileType == 'file';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18)),
          if (!isMe) const SizedBox(width: 8),

          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (isImage && hasMedia) _buildImagePreview(fileUrl!),
                  if (isVideo && hasMedia) _buildVideoPreview(fileUrl!, context),
                  if (isFile && hasMedia) _buildFilePreview(),
                  if (hasLink && firstUrl != null) _buildLinkPreview(firstUrl, context),
                  if (text != null && text!.isNotEmpty)
                    Padding(
                      padding: hasLink || hasMedia ? const EdgeInsets.only(top: 8) : EdgeInsets.zero,
                      child: SelectableText( // লিংক সিলেক্ট করা যাবে
                        text!,
                        style: const TextStyle(fontSize: 15.5, height: 1.4),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(time ?? "", style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        if (isMe) ...[const SizedBox(width: 4), Icon(Icons.done_all, size: 16, color: Colors.blue.shade700)],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildLinkPreview(String url, BuildContext context) {
    final String domain = Uri.tryParse(url)?.host ?? '';
    String title = "Link";
    String? thumbnail;

    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      title = "YouTube Video";
      final videoId = url.contains('youtu.be')
          ? url.split('/').last.split('?').first
          : Uri.parse(url).queryParameters['v'];
      thumbnail = videoId != null ? "https://img.youtube.com/vi/$videoId/maxresdefault.jpg" : null;
    } else if (url.contains('instagram.com')) {
      title = "Instagram Post";
    } else if (url.contains('facebook.com') || url.contains('fb.com')) {
      title = "Facebook";
    } else if (url.contains('tiktok.com')) {
      title = "TikTok Video";
    } else if (url.contains('x.com') || url.contains('twitter.com')) {
      title = "X Post";
    } else {
      title = domain.replaceAll('www.', '').split('.').first;
      title = title.isEmpty ? "Website" : title[0].toUpperCase() + title.substring(1);
    }

    return GestureDetector(
      onTap: () => _launchSmartUrl(url),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              if (thumbnail != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: thumbnail,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey.shade200),
                    errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200, child: const Icon(Icons.play_arrow)),
                  ),
                ),
              if (thumbnail != null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                    const SizedBox(height: 4),
                    Text(url, style: TextStyle(fontSize: 11.5, color: Colors.blue.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade600),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _extractUrls(String text) {
    final RegExp urlRegExp = RegExp(r'(https?://[^\s]+)');
    return urlRegExp.allMatches(text).map((m) => m.group(0)!).toList();
  }

  Widget _buildImagePreview(String url) => ClipRRect(borderRadius: BorderRadius.circular(12), child: CachedNetworkImage(imageUrl: url, width: 240, fit: BoxFit.cover));
  Widget _buildVideoPreview(String url, context) => GestureDetector(onTap: () => _launchSmartUrl(url), child: _videoThumbnail(url));
  Widget _videoThumbnail(String url) => ClipRRect(borderRadius: BorderRadius.circular(12), child: Container(width: 240, height: 300, color: Colors.black, child: Stack(alignment: Alignment.center, children: [CachedNetworkImage(imageUrl: url, fit: BoxFit.cover), const Icon(Icons.play_circle_fill, size: 70, color: Colors.white)])));

  Widget _buildFilePreview() => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(_getFileIcon(fileName ?? ''), size: 38, color: _getFileColor(fileName ?? '')), const SizedBox(width: 12), Expanded(child: Text(fileName ?? "File", style: const TextStyle(fontWeight: FontWeight.w600))), const Icon(Icons.download_rounded)]));

  IconData _getFileIcon(String name) => name.toLowerCase().endsWith('.pdf') ? Icons.picture_as_pdf : Icons.insert_drive_file;
  Color _getFileColor(String name) => name.toLowerCase().endsWith('.pdf') ? Colors.red.shade600 : Colors.grey.shade700;
}