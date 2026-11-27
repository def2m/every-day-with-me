import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/day_entry.dart';
import '../services/storage_service.dart';
import '../services/update_service.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  final Map<int, DayEntry> entries;
  final VoidCallback onReload;

  const SettingsScreen({
    super.key,
    required this.entries,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.spaceDarkBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            const Text(
              'Ayarlar & Yedekleme',
              style: TextStyle(
                color: AppConstants.textLight,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Verilerini güvende tut ve yönet',
              style: TextStyle(
                color: AppConstants.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.spaceSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  _statItem('Toplam Not', '${entries.length} Gün', Icons.star_rounded, AppConstants.accentGold),
                  _divider(),
                  _statItem('Boş Gün', '${365 - entries.length}', Icons.nightlight_outlined, AppConstants.emptyDotColor),
                  _divider(),
                  _statItem('Doluluk', '%${((entries.length / 365) * 100).toStringAsFixed(0)}', Icons.pie_chart_outline_rounded, const Color(0xFF34D399)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Backup Actions
            _sectionHeader('YEDEKLEME & VERİ'),
            _menuTile(
              icon: Icons.file_download_outlined,
              title: 'Yedek Al (JSON Kopyala)',
              subtitle: 'Tüm notlarını ve şekillerini metin olarak kopyalar',
              onTap: () async {
                final jsonStr = await StorageService.exportBackupJson();
                await Clipboard.setData(ClipboardData(text: jsonStr));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Yedek verisi panoya kopyalandı! Güvenli bir yere yapıştırabilirsin. 📋'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
            ),
            _menuTile(
              icon: Icons.file_upload_outlined,
              title: 'Yedek Geri Yükle',
              subtitle: 'Önceden aldığın JSON yedeğini geri yükle',
              onTap: () {
                final controller = TextEditingController();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppConstants.spaceSurface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    title: const Text('Yedek Yükle', style: TextStyle(color: AppConstants.textLight)),
                    content: TextField(
                      controller: controller,
                      maxLines: 5,
                      style: const TextStyle(color: AppConstants.textLight, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Yedek JSON metnini buraya yapıştır...',
                        hintStyle: TextStyle(color: AppConstants.textMuted),
                        filled: true,
                        fillColor: AppConstants.spaceCard,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('İptal', style: TextStyle(color: AppConstants.textMuted)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final ok = await StorageService.importBackupJson(controller.text.trim());
                          if (ctx.mounted) Navigator.of(ctx).pop();
                          if (ok) {
                            onReload();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Yedek başarıyla yüklendi! ✨')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppConstants.accentGold),
                        child: const Text('Yükle', style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                );
              },
            ),
            _menuTile(
              icon: Icons.auto_awesome,
              title: 'Örnek Verileri Yükle',
              subtitle: 'Gökyüzünün nasıl parıldadığını görmek için birkaç örnek gün ekle',
              onTap: () async {
                await StorageService.loadSampleData();
                onReload();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Örnek yıldızlar yüklendi! ⭐')),
                  );
                }
              },
            ),
            _menuTile(
              icon: Icons.delete_forever_rounded,
              title: 'Tüm Günlüğü Sıfırla',
              subtitle: 'Tüm notları ve şekilleri kalıcı olarak siler',
              isDestructive: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppConstants.spaceSurface,
                    title: const Text('Tüm Verileri Sıfırla?', style: TextStyle(color: AppConstants.textLight)),
                    content: const Text(
                      'Tüm 365 gün kayıtların silinecek. Bu işlem geri alınamaz!',
                      style: TextStyle(color: AppConstants.textMuted),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Vazgeç', style: TextStyle(color: AppConstants.textMuted)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await StorageService.clearAll();
                          onReload();
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE11D48)),
                        child: const Text('Sıfırla', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // About / GitHub APK info
            _sectionHeader('GÜNCELLEME & HAKKINDA'),
            _menuTile(
              icon: Icons.system_update_rounded,
              title: 'Güncellemeleri Kontrol Et',
              subtitle: 'GitHub üzerinden yeni sürüm olup olmadığını denetle',
              onTap: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Güncellemeler kontrol ediliyor... 🔍'),
                    duration: Duration(seconds: 1),
                  ),
                );
                final info = await UpdateService.checkForUpdate();
                if (!context.mounted) return;
                if (info != null) {
                  UpdateService.showUpdateDialog(context, info);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Uygulamanız zaten en güncel sürümde! ✨'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
            ),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppConstants.spaceSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '365 Gün - Gökyüzü Günlüğüm',
                    style: TextStyle(
                      color: AppConstants.textLight,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Her güne bir şekil ve anı bıraktığın, yılını ışıl ışıl bir takımyıldızına dönüştüren kişisel günlüğün. Tamamen çevrimdışı ve gizlidir, tüm veriler telefonunda saklanır.',
                    style: TextStyle(
                      color: AppConstants.textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.android_rounded, color: Color(0xFF34D399), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Android APK • GitHub Actions CI/CD Destekli',
                        style: TextStyle(
                          color: AppConstants.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppConstants.textLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppConstants.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white12,
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppConstants.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppConstants.spaceSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive ? const Color(0x22E11D48) : AppConstants.spaceCard,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? const Color(0xFFFB7185) : AppConstants.textLight,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? const Color(0xFFFB7185) : AppConstants.textLight,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppConstants.textMuted,
            fontSize: 11,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppConstants.textMuted, size: 20),
      ),
    );
  }
}
