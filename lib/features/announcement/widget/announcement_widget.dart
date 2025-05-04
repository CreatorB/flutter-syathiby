import 'dart:ui';
import 'dart:math' as math;
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
import 'package:package_info_plus/package_info_plus.dart';

class AnnouncementWidget extends StatefulWidget {
  final Announcement announcement;
  final VoidCallback? onDismiss;

  const AnnouncementWidget({
    super.key,
    required this.announcement,
    this.onDismiss,
  });

  @override
  State<AnnouncementWidget> createState() => _AnnouncementWidgetState();
}

class _AnnouncementWidgetState extends State<AnnouncementWidget> {
  bool _needsUpdate = false;
  bool _isCheckingVersion = true;
  bool _markedForRemoval = false;

  @override
  void initState() {
    super.initState();
    if (widget.announcement.type == 'app_update' && widget.announcement.version != null) {
      _checkAppVersion();
    } else {
      _isCheckingVersion = false;
    }
  }

  Future<void> _checkAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final requiredVersion = widget.announcement.version;

      if (requiredVersion != null) {
        // Compare versions
        final needsUpdate = _compareVersions(currentVersion, requiredVersion);
        
        if (mounted) {
          setState(() {
            _needsUpdate = needsUpdate;
            _isCheckingVersion = false;
          });
          
          // Handle auto-dismissal for up-to-date versions
          if (!needsUpdate) {
            _scheduleDismissal();
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _needsUpdate = true; // Default to showing update if no version specified
            _isCheckingVersion = false;
          });
        }
      }
    } catch (e) {
      LoggerUtil.error('Error checking app version', e);
      if (mounted) {
        setState(() {
          _needsUpdate = true; // Default to showing update on error
          _isCheckingVersion = false;
        });
      }
    }
  }
  
  // Schedule dismissal to happen safely after the widget is built
  void _scheduleDismissal() {
    if (_markedForRemoval) return; // Prevent multiple calls
    
    _markedForRemoval = true;
    
    // Use the next frame callback to ensure safe dismissal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.onDismiss != null) {
        widget.onDismiss?.call();
      }
    });
  }

  // Returns true if current version is older than required version
  bool _compareVersions(String currentVersion, String requiredVersion) {
    final currentParts = currentVersion.split('.');
    final requiredParts = requiredVersion.split('.');
    
    // Compare major, minor, patch versions
    for (int i = 0; i < math.min(currentParts.length, requiredParts.length); i++) {
      final current = int.tryParse(currentParts[i]) ?? 0;
      final required = int.tryParse(requiredParts[i]) ?? 0;
      
      if (current < required) {
        return true; // Needs update
      } else if (current > required) {
        return false; // Current version is newer
      }
    }
    
    // If all comparable parts are equal, check if required has more version parts
    return requiredParts.length > currentParts.length;
  }

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
${widget.announcement.title}

${widget.announcement.content.replaceAll(RegExp(r'<[^>]*>'), '')}

${widget.announcement.linkUrl ?? ''}
''';

    try {
      await Share.share(
        shareText,
        subject: widget.announcement.title,
      );
    } catch (e) {
      LoggerUtil.error('Error sharing announcement', e);
    }
  }

  void _copyToClipboard(BuildContext context) async {
    final shareText = '''
${widget.announcement.title}

${widget.announcement.content.replaceAll(RegExp(r'<[^>]*>'), '')}

${widget.announcement.linkUrl ?? ''}
''';

    await Clipboard.setData(ClipboardData(text: shareText));
    _showSnackBar(context, 'Teks berhasil disalin');
  }

  @override
  Widget build(BuildContext context) {
    // If widget is marked for removal or doesn't need update, return a placeholder
    if (_markedForRemoval || 
        (widget.announcement.type == 'app_update' && 
         !_isCheckingVersion && 
         !_needsUpdate)) {
      return SizedBox.shrink(); // Empty widget that doesn't disrupt layout
    }
    
    // For app updates still checking version or needing update, or for other announcement types
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        type: MaterialType.transparency,
        child: Dismissible(
          key: ValueKey('announcement-${widget.announcement.id}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            if (widget.onDismiss != null) {
              widget.onDismiss!();
            }
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.close, color: Colors.white),
          ),
          child: Container(
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
                        widget.announcement.title,
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
                            _copyToClipboard(context);
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
                  data: widget.announcement.content,
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
                if (widget.announcement.linkUrl != null) _buildActionButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (widget.announcement.type == 'app_update') {
      if (_isCheckingVersion) {
        return Container(
          margin: const EdgeInsets.only(top: 8),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        );
      }
      
      if (!_needsUpdate) {
        return const SizedBox.shrink();
      }
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: switch (widget.announcement.type) {
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
    if (widget.announcement.linkUrl == null) return;

    try {
      final url = Uri.parse(widget.announcement.linkUrl!);

      final mode = switch (widget.announcement.linkType) {
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