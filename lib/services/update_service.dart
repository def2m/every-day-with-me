import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../utils/constants.dart';

class UpdateService {
  static const String _githubOwner = 'def2m';
  static const String _githubRepo = 'every-day-with-me';
  static const String _apiUrl =
      'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest';

  /// Check GitHub for a newer release. Returns update info or null.
  static Future<Map<String, String>?> checkForUpdate() async {
    try {
      final response = await http
          .get(Uri.parse(_apiUrl), headers: {'Accept': 'application/vnd.github.v3+json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final Map<String, dynamic> release = json.decode(response.body);
      final String tagName = release['tag_name'] ?? '';
      final String releaseName = release['name'] ?? tagName;
      final String body = release['body'] ?? '';

      // Extract version from tag (e.g. "v1.0.3" → "1.0.3")
      final remoteVersion = tagName.replaceAll(RegExp(r'^v'), '');

      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. "1.0.0"

      if (!_isNewer(remoteVersion, currentVersion)) return null;

      // Find the APK asset download URL
      final List<dynamic> assets = release['assets'] ?? [];
      String? apkUrl;
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String?;
          break;
        }
      }

      if (apkUrl == null) return null;

      return {
        'version': remoteVersion,
        'tag': tagName,
        'name': releaseName,
        'body': body,
        'apkUrl': apkUrl,
      };
    } catch (e) {
      // Network error, timeout, etc. – silently ignore
      debugPrint('Update check failed: $e');
      return null;
    }
  }

  /// Compare two semver strings. Returns true if remote > current.
  static bool _isNewer(String remote, String current) {
    try {
      final rParts = remote.split('.').map(int.parse).toList();
      final cParts = current.split('.').map(int.parse).toList();

      // Pad to equal length
      while (rParts.length < 3) rParts.add(0);
      while (cParts.length < 3) cParts.add(0);

      for (int i = 0; i < 3; i++) {
        if (rParts[i] > cParts[i]) return true;
        if (rParts[i] < cParts[i]) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Download the APK to a temp directory and trigger install.
  static Future<void> downloadAndInstall(
    String apkUrl,
    BuildContext context, {
    ValueChanged<double>? onProgress,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/gun365-update.apk';
      final file = File(filePath);

      // Stream download with progress
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(apkUrl));
      final streamedResponse = await client.send(request);
      final contentLength = streamedResponse.contentLength ?? 0;

      final sink = file.openWrite();
      int received = 0;

      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (contentLength > 0 && onProgress != null) {
          onProgress(received / contentLength);
        }
      }
      await sink.close();
      client.close();

      // Open APK for installation
      final result = await OpenFilex.open(filePath, type: 'application/vnd.android.package-archive');
      if (result.type != ResultType.done) {
        debugPrint('Could not open APK: ${result.message}');
      }
    } catch (e) {
      debugPrint('Download failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Güncelleme indirirken hata oluştu: $e'),
            backgroundColor: const Color(0xFFE11D48),
          ),
        );
      }
    }
  }

  /// Show a beautiful update dialog.
  static void showUpdateDialog(BuildContext context, Map<String, String> info) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _UpdateDialog(info: info),
    );
  }
}

class _UpdateDialog extends StatefulWidget {
  final Map<String, String> info;
  const _UpdateDialog({required this.info});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  bool _downloading = false;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppConstants.spaceSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.accentGold.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.system_update_rounded,
                color: AppConstants.accentGold, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Yeni Güncelleme Mevcut!',
              style: TextStyle(
                color: AppConstants.textLight,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppConstants.spaceCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppConstants.accentGold.withOpacity(0.4)),
            ),
            child: Text(
              '✨ Sürüm ${widget.info['version']}',
              style: const TextStyle(
                color: AppConstants.accentGold,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.info['name'] ?? '',
            style: const TextStyle(
              color: AppConstants.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          if (!_downloading)
            const Text(
              'Uygulamanın yeni bir sürümü yayınlandı. Şimdi güncellemek ister misin?',
              style: TextStyle(
                color: AppConstants.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          if (_downloading) ...[
            const SizedBox(height: 8),
            const Text(
              'Güncelleme indiriliyor...',
              style: TextStyle(
                color: AppConstants.textLight,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppConstants.spaceCard,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppConstants.accentGold),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '%${(_progress * 100).toStringAsFixed(0)} tamamlandı',
              style: const TextStyle(
                color: AppConstants.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
      actions: _downloading
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Daha Sonra',
                    style: TextStyle(color: AppConstants.textMuted)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _downloading = true);
                  UpdateService.downloadAndInstall(
                    widget.info['apkUrl']!,
                    context,
                    onProgress: (p) {
                      if (mounted) setState(() => _progress = p);
                    },
                  ).then((_) {
                    if (mounted) Navigator.of(context).pop();
                  });
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Güncelle'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.accentGold,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
    );
  }
}
