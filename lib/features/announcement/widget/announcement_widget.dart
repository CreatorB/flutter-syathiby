import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syathiby/core/constants/color_constants.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/features/announcement/model/announcement_model.dart';
import 'package:syathiby/features/theme/bloc/theme_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';

class AnnouncementWidget extends StatelessWidget {
  final Announcement announcement;
  final VoidCallback? onDismiss;

  const AnnouncementWidget({
    super.key,
    required this.announcement,
    this.onDismiss,
  });

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareAnnouncement() async {
    final shareText = '''
${announcement.title}

${announcement.content.replaceAll(RegExp(r'<[^>]*>'), '')}

${announcement.linkUrl ?? ''}
''';

    try {
      await Share.share(
        shareText,
        subject: announcement.title,
      );
    } catch (e) {
      LoggerUtil.error('Error sharing announcement', e);
    }
  }

  void _copyToClipboard(BuildContext context) async {
    final shareText = '''
${announcement.title}

${announcement.content.replaceAll(RegExp(r'<[^>]*>'), '')}

${announcement.linkUrl ?? ''}
''';

    await Clipboard.setData(ClipboardData(text: shareText));
    _showSnackBar(context, 'Teks berhasil disalin');
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(announcement.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.close, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    announcement.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.share),
                  onSelected: (value) {
                    switch (value) {
                      case 'share':
                        _shareAnnouncement();
                        break;
                      case 'copy':
                        _copyToClipboard(context); // Pass context
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('Bagikan'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          Icon(Icons.copy),
                          SizedBox(width: 8),
                          Text('Salin'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Html(
              data: announcement.content,
              style: {
                "body": Style(
                  margin: Margins.all(0),
                  padding: HtmlPaddings.all(0),
                ),
                "p": Style(
                  margin: Margins.all(0),
                  padding: HtmlPaddings.all(0),
                ),
              },
              shrinkWrap: true,
              onLinkTap: (url, _, __) async {
                if (url != null) {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
            ),
            if (announcement.linkUrl != null) _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: switch (announcement.type) {
        'app_update' => ElevatedButton.icon(
            onPressed: _handleLink,
            icon: const Icon(Icons.system_update),
            label: const Text('Update Aplikasi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        'link' => TextButton.icon(
            onPressed: _handleLink,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Buka Link'),
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }

  Future<void> _handleLink() async {
    if (announcement.linkUrl == null) return;

    try {
      final url = Uri.parse(announcement.linkUrl!);

      final mode = switch (announcement.linkType) {
        'browser' => LaunchMode.externalApplication,
        'app' => LaunchMode.platformDefault,
        'deeplink' => LaunchMode.platformDefault,
        _ => LaunchMode.platformDefault,
      };

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: mode);
      }
    } catch (e) {
      LoggerUtil.error('Error handling link', e);
    }
  }
}
