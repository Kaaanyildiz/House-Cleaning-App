import 'package:flutter/material.dart';
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:provider/provider.dart'; 
import 'package:house_cleaning/services/user_provider.dart'; 
import 'package:hive_flutter/hive_flutter.dart';
import 'package:house_cleaning/screens/profile_page.dart'; // Sadece ProfilePage'i içe aktar

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  int _selectedColorIndex = 0;
  bool _soundEffectsEnabled = true;
  String _selectedLanguage = 'Türkçe';
  
  final List<String> _languages = ['Türkçe', 'English', 'Deutsch', 'Español'];
  
  final List<Color> _themeColors = [
    AppTheme.primaryColor, // Varsayılan yeşil
    Colors.purple,
    Colors.blue,
    Colors.orange,
    Colors.teal,
  ];

  @override  void initState() {
    super.initState();
    
    // Hive'dan açılış ayarlarını yükle
    _loadSettings();
  }
  
  // Mevcut ayarları yükle
  void _loadSettings() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Tema ayarlarını yükle
    _isDarkMode = AppTheme.instance.isDark;
    
    // Mevcut renk temasını bul
    final currentTheme = AppTheme.instance.currentThemeOption;
    _selectedColorIndex = AppTheme.themeOptions.indexWhere(
      (option) => option.primary == currentTheme.primary
    );
    if (_selectedColorIndex < 0) _selectedColorIndex = 0;
    
    // Bildirim ayarlarını yükle
    final settingsBox = await Hive.openBox('settings');
    _notificationsEnabled = settingsBox.get('notificationsEnabled', defaultValue: true);
    _soundEffectsEnabled = settingsBox.get('soundEffectsEnabled', defaultValue: true);
    
    setState(() {});
  }
  // Not: Bu metod artık doğrudan kullanılmıyor, saveSettings için Provider kullanılıyor

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // Tema Ayarları
          _buildSectionHeader('Tema Ayarları'),          _buildSettingSwitch(
            title: 'Karanlık Mod',
            subtitle: 'Uygulamayı koyu renk temasıyla görüntüle',
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              // Tema değiştirme fonksiyonunu çağır
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.saveSettings({'isDarkMode': value});
            },
          ),
          _buildColorSelector(),
          
          const Divider(),
          
          // Bildirimler
          _buildSectionHeader('Bildirim Ayarları'),
          _buildSettingSwitch(
            title: 'Bildirimler',
            subtitle: 'Görev hatırlatmaları ve motivasyon mesajları al',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              
              // Bildirim ayarlarını kaydet
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.saveNotificationSettings(notificationsEnabled: value);
            },
          ),          _buildSettingSwitch(
            title: 'Ses Efektleri',
            subtitle: 'Görev tamamlama ve rozet kazanma sesi',
            value: _soundEffectsEnabled,
            onChanged: (value) {
              setState(() {
                _soundEffectsEnabled = value;
              });
              
              // Ses ayarlarını kaydet
              final userProvider = Provider.of<UserProvider>(context, listen: false);              userProvider.saveNotificationSettings(
                notificationsEnabled: _notificationsEnabled,
                soundEnabled: value
              );
            },
          ),
          ListTile(
            title: const Text('Görev Hatırlatmaları'),
            subtitle: const Text('Günlük hatırlatıcıların sıklığını ayarlayın'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showReminderDialog();
            },
          ),
          
          const Divider(),
          
          // Kişiselleştirme
          _buildSectionHeader('Kişiselleştirme'),
          _buildLanguageSelector(),
          ListTile(
            title: const Text('Görev Zorluk Seviyesi'),
            subtitle: const Text('Görevlerin varsayılan zorluk düzeyini ayarlayın'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showDifficultySelector();
            },
          ),
          
          const Divider(),
          
          // Hesap ve Gizlilik
          _buildSectionHeader('Hesap ve Gizlilik'),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Profil Bilgileri'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Profil sayfasına yönlendir
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Veri Yedekleme'),
            subtitle: const Text('Görevleri ve ilerleme durumunu yedekle'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showBackupDialog();
            },
          ),
          
          const Divider(),
          
          // Hakkında
          _buildSectionHeader('Hakkında'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Uygulama Hakkında'),
            onTap: () {
              _showAboutDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Yardım ve Destek'),
            onTap: () {
              // Yardım sayfasına git
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Uygulamayı Puanla'),
            onTap: () {
              // Puanlama sayfasına git
            },
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildColorSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Renk Teması',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              _themeColors.length,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorIndex = index;
                  });
                  // Tema rengi değiştirme fonksiyonu çağır
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  userProvider.saveSettings({'themeIndex': index});
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _themeColors[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColorIndex == index
                          ? Colors.white
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      if (_selectedColorIndex == index)
                        BoxShadow(
                          color: _themeColors[index].withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 8,
                        ),
                    ],
                  ),
                  child: _selectedColorIndex == index
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return ListTile(
      title: const Text('Dil'),
      subtitle: Text(_selectedLanguage),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        isDense: true,
        underline: Container(),
        onChanged: (String? value) {
          if (value != null) {
            setState(() {
              _selectedLanguage = value;
            });
          }
        },
        items: _languages.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  void _showReminderDialog() {
    // Mevcut ayarı al
    String reminderFrequency = Provider.of<UserProvider>(context, listen: false)
        .reminderFrequency;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görev Hatırlatmaları'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Her saat'),
              leading: Radio<String>(
                value: 'hourly',
                groupValue: reminderFrequency,
                onChanged: (value) {
                  if (value != null) {
                    Provider.of<UserProvider>(context, listen: false)
                        .saveNotificationSettings(
                      notificationsEnabled: _notificationsEnabled,
                      reminderFrequency: value,
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Günde 3 kez'),
              leading: Radio<String>(
                value: 'frequent',
                groupValue: reminderFrequency,
                onChanged: (value) {
                  if (value != null) {
                    Provider.of<UserProvider>(context, listen: false)
                        .saveNotificationSettings(
                      notificationsEnabled: _notificationsEnabled,
                      reminderFrequency: value,
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Günde 1 kez'),
              leading: Radio<String>(
                value: 'daily',
                groupValue: reminderFrequency,
                onChanged: (value) {
                  if (value != null) {
                    Provider.of<UserProvider>(context, listen: false)
                        .saveNotificationSettings(
                      notificationsEnabled: _notificationsEnabled,
                      reminderFrequency: value,
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Sadece önemli görevler'),
              leading: Radio<String>(
                value: 'important_only',
                groupValue: reminderFrequency,
                onChanged: (value) {
                  if (value != null) {
                    Provider.of<UserProvider>(context, listen: false)
                        .saveNotificationSettings(
                      notificationsEnabled: _notificationsEnabled,
                      reminderFrequency: value,
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showDifficultySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Varsayılan Zorluk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Kolay'),
              leading: Radio<int>(
                value: 1,
                groupValue: 0,
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Orta'),
              leading: Radio<int>(
                value: 2,
                groupValue: 0,
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Zor'),
              leading: Radio<int>(
                value: 3,
                groupValue: 0,
                onChanged: (value) {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veri Yedekleme'),
        content: const Text('Şu anda tüm verileriniz yerel olarak saklanıyor. '
            'Çevrimiçi yedekleme özelliği yakında eklenecek.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Temizlik Asistanı',
        applicationVersion: '1.0.0',
        applicationIcon: const Icon(
          Icons.cleaning_services,
          color: AppTheme.primaryColor,
          size: 40,
        ),
        children: const [
          SizedBox(height: 16),
          Text(
            'Temizlik Asistanı, ev işlerinizi eğlenceli hale getirmek ve '
            'motivasyonunuzu artırmak için tasarlanmış bir uygulamadır.',
          ),
          SizedBox(height: 8),
          Text(
            'Copyright © 2025',
          ),
        ],
      ),
    );
  }
}
