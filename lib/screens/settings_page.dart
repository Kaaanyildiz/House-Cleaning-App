import 'package:flutter/material.dart';
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:provider/provider.dart'; 
import 'package:house_cleaning/services/user_provider.dart'; 
import 'package:hive_flutter/hive_flutter.dart';
import 'package:house_cleaning/screens/profile_page.dart';
import 'package:house_cleaning/widgets/premium_effects.dart';

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
    // ThemeOption listesinden renkleri içeren bir liste
  List<Color> get _themeColors => 
    AppTheme.themeOptions.map((option) => option.primary).toList();  @override
  void initState() {
    super.initState();
    
    // Hive'dan açılış ayarlarını yükle
    _loadSettings();
  }
  
  // Mevcut ayarları yükle  
  void _loadSettings() async {
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
    
    // Hive'dan tema ayarlarını kontrol et ve senkronize et
    final savedThemeIndex = settingsBox.get('themeIndex');
    if (savedThemeIndex != null && 
        savedThemeIndex >= 0 && 
        savedThemeIndex < AppTheme.themeOptions.length && 
        savedThemeIndex != _selectedColorIndex) {
      _selectedColorIndex = savedThemeIndex;
      
      // Temayı güncelle
      AppTheme.instance.setThemeOption(AppTheme.themeOptions[_selectedColorIndex]);
    }
    
    final savedIsDarkMode = settingsBox.get('isDarkMode');
    if (savedIsDarkMode != null && savedIsDarkMode != _isDarkMode) {
      _isDarkMode = savedIsDarkMode;
      // Temayı güncelle
      AppTheme.instance.setDarkMode(_isDarkMode);
    }
    
    setState(() {});
  }
  // Not: Bu metod artık doğrudan kullanılmıyor, saveSettings için Provider kullanılıyor
  @override
  Widget build(BuildContext context) {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return Scaffold(
      body: Container(        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppTheme.instance.isDark
                ? [
                    const Color(0xFF1F2937),
                    const Color(0xFF111827),
                    const Color(0xFF0F172A),
                  ]
                : [
                    themeOption.surface,
                    Colors.white,
                    Colors.white,
                  ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),child: SafeArea(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            slivers: [
              // Premium App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: AnimatedGradientContainer(
                    colors: [
                      themeOption.primary,
                      themeOption.accent,
                      themeOption.secondary,
                    ],
                    duration: const Duration(seconds: 4),
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: const Text(
                      'Ayarlar ⚙️',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  centerTitle: false,
                  background: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              themeOption.primary.withOpacity(0.8),
                              themeOption.accent.withOpacity(0.6),
                              themeOption.secondary.withOpacity(0.4),
                            ],
                          ),
                        ),
                      ),
                      // Animated background patterns
                      Positioned.fill(
                        child: AnimatedGradientContainer(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.0),
                          ],
                          duration: const Duration(seconds: 6),
                          child: Container(),
                        ),
                      ),
                      // Floating shapes
                      Positioned(
                        top: 20,
                        right: 20,
                        child: ShimmerEffect(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.settings_rounded,
                              color: Colors.white.withOpacity(0.2),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tema Ayarları
                      _buildPremiumSectionHeader('Tema Ayarları', Icons.palette_rounded),
                      const SizedBox(height: 16),                      _buildPremiumSettingSwitch(
                        title: 'Karanlık Mod',
                        subtitle: 'Uygulamayı koyu renk temasıyla görüntüle',
                        value: _isDarkMode,
                        icon: Icons.dark_mode_rounded,
                        onChanged: (value) {
                          setState(() {
                            _isDarkMode = value;
                          });
                          
                          // Karanlık modu değiştir (notifyListeners çağrılacak)
                          AppTheme.instance.setDarkMode(value);
                          
                          // Ayarları kaydet
                          final userProvider = Provider.of<UserProvider>(context, listen: false);
                          userProvider.saveSettings({'isDarkMode': value});
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPremiumColorSelector(),
                      
                      const SizedBox(height: 32),
                      
                      // Bildirimler
                      _buildPremiumSectionHeader('Bildirim Ayarları', Icons.notifications_rounded),
                      const SizedBox(height: 16),
                      _buildPremiumSettingSwitch(
                        title: 'Bildirimler',
                        subtitle: 'Görev hatırlatmaları ve motivasyon mesajları al',
                        value: _notificationsEnabled,
                        icon: Icons.notifications_active_rounded,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                          final userProvider = Provider.of<UserProvider>(context, listen: false);
                          userProvider.saveNotificationSettings(notificationsEnabled: value);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPremiumSettingSwitch(
                        title: 'Ses Efektleri',
                        subtitle: 'Görev tamamlama ve rozet kazanma sesi',
                        value: _soundEffectsEnabled,
                        icon: Icons.volume_up_rounded,
                        onChanged: (value) {
                          setState(() {
                            _soundEffectsEnabled = value;
                          });
                          final userProvider = Provider.of<UserProvider>(context, listen: false);
                          userProvider.saveNotificationSettings(
                            notificationsEnabled: _notificationsEnabled,
                            soundEnabled: value
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPremiumSettingTile(
                        title: 'Görev Hatırlatmaları',
                        subtitle: 'Günlük hatırlatıcıların sıklığını ayarlayın',
                        icon: Icons.schedule_rounded,
                        onTap: () => _showReminderDialog(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Kişiselleştirme
                      _buildPremiumSectionHeader('Kişiselleştirme', Icons.tune_rounded),
                      const SizedBox(height: 16),
                      _buildPremiumLanguageSelector(),
                      const SizedBox(height: 16),
                      _buildPremiumSettingTile(
                        title: 'Görev Zorluk Seviyesi',
                        subtitle: 'Görevlerin varsayılan zorluk düzeyini ayarlayın',
                        icon: Icons.trending_up_rounded,
                        onTap: () => _showDifficultySelector(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Hesap ve Gizlilik
                      _buildPremiumSectionHeader('Hesap ve Gizlilik', Icons.security_rounded),
                      const SizedBox(height: 16),                      _buildPremiumSettingTile(
                        title: 'Profil Bilgileri',
                        subtitle: 'Kişisel bilgilerinizi görüntüle ve düzenle',
                        icon: Icons.account_circle_rounded,
                        onTap: () {
                          // pushReplacement kullanarak mevcut sayfayı yığından çıkarıyoruz
                          // böylece geri tuşuna basıldığında ayarlar sayfası tekrar görünmeyecek
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const ProfilePage()),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPremiumSettingTile(
                        title: 'Veri Yedekleme',
                        subtitle: 'Görevleri ve ilerleme durumunu yedekle',
                        icon: Icons.backup_rounded,
                        onTap: () => _showBackupDialog(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Hakkında
                      _buildPremiumSectionHeader('Hakkında', Icons.info_rounded),
                      const SizedBox(height: 16),
                      _buildPremiumSettingTile(
                        title: 'Uygulama Hakkında',
                        subtitle: 'Versiyon bilgileri ve lisans',
                        icon: Icons.info_outline_rounded,
                        onTap: () => _showAboutDialog(),
                      ),
                      const SizedBox(height: 16),
                      _buildPremiumSettingTile(
                        title: 'Yardım ve Destek',
                        subtitle: 'SSS ve iletişim bilgileri',
                        icon: Icons.help_outline_rounded,
                        onTap: () {
                          // Yardım sayfasına git
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildPremiumSettingTile(
                        title: 'Uygulamayı Puanla',
                        subtitle: 'App Store\'da değerlendirin',
                        icon: Icons.star_outline_rounded,
                        onTap: () {
                          // Puanlama sayfasına git
                        },
                      ),
                      
                      const SizedBox(height: 100), // Bottom navigation padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSectionHeader(String title, IconData icon) {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [themeOption.primary, themeOption.accent],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B),
            ),
          ),
      ],
    );
  }

  Widget _buildPremiumSettingSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Function(bool) onChanged,
  }) {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return NeumorphismContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: value ? themeOption.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),            child: Icon(
              icon,
              color: value ? themeOption.primary : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 60,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: value
                  ? LinearGradient(
                      colors: [themeOption.primary, themeOption.accent],
                    )
                  : LinearGradient(
                      colors: [Colors.grey[300]!, Colors.grey[400]!],
                    ),
              boxShadow: [
                BoxShadow(
                  color: value ? themeOption.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: value ? 28 : 4,
                  top: 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => onChanged(!value),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return NeumorphismContainer(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeOption.primary.withOpacity(0.1),
                    themeOption.accent.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: themeOption.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeOption.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: themeOption.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumColorSelector() {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return GlassmorphismContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [themeOption.primary, themeOption.accent],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.color_lens_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),              Text(
                'Renk Teması',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              _themeColors.length,
              (index) => GestureDetector(                onTap: () {
                  setState(() {
                    _selectedColorIndex = index;
                  });
                  
                  // Tema rengini değiştir (notifyListeners çağrılacak)
                  AppTheme.instance.setThemeOption(AppTheme.themeOptions[index]);
                  
                  // Ayarları kaydet
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  userProvider.saveSettings({'themeIndex': index});
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _selectedColorIndex == index ? 50 : 40,
                  height: _selectedColorIndex == index ? 50 : 40,
                  decoration: BoxDecoration(
                    color: _themeColors[index],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColorIndex == index
                          ? Colors.white
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _themeColors[index].withOpacity(0.5),
                        spreadRadius: _selectedColorIndex == index ? 4 : 0,
                        blurRadius: _selectedColorIndex == index ? 12 : 4,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _selectedColorIndex == index
                      ? ShimmerEffect(
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
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

  Widget _buildPremiumLanguageSelector() {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return NeumorphismContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeOption.primary.withOpacity(0.1),
                  themeOption.accent.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.language_rounded,
              color: themeOption.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,              children: [
                Text(
                  'Dil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),                Text(
                  _selectedLanguage,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.instance.isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: themeOption.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: themeOption.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: DropdownButton<String>(
              value: _selectedLanguage,
              isDense: true,
              underline: Container(),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: themeOption.primary,
              ),
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
                  child: Text(
                    value,
                    style: TextStyle(
                      color: themeOption.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }  void _showReminderDialog() {
    final themeOption = AppTheme.instance.currentThemeOption;
    String reminderFrequency = Provider.of<UserProvider>(context, listen: false)
        .reminderFrequency;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphismContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [themeOption.primary, themeOption.accent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),                  Text(
                    'Görev Hatırlatmaları',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...[
                {'value': 'hourly', 'title': 'Her saat'},
                {'value': 'frequent', 'title': 'Günde 3 kez'},
                {'value': 'daily', 'title': 'Günde 1 kez'},
                {'value': 'important_only', 'title': 'Sadece önemli görevler'},
              ].map((option) => _buildPremiumRadioTile(
                title: option['title']!,
                value: option['value']!,
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
              )).toList(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeumorphismContainer(
                    onTap: () => Navigator.of(context).pop(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'Kapat',
                      style: TextStyle(
                        color: themeOption.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumRadioTile({
    required String title,
    required String value,
    required String groupValue,
    required Function(String?) onChanged,
  }) {
    final themeOption = AppTheme.instance.currentThemeOption;
    final isSelected = value == groupValue;
    
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? themeOption.primary.withOpacity(0.1) : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? themeOption.primary : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? themeOption.primary : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? themeOption.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
            const SizedBox(width: 12),            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? themeOption.primary : (AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B)),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showDifficultySelector() {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphismContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [themeOption.primary, themeOption.accent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),                  Text(
                    'Varsayılan Zorluk',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...[
                {'value': '1', 'title': 'Kolay', 'color': Colors.green},
                {'value': '2', 'title': 'Orta', 'color': Colors.orange},
                {'value': '3', 'title': 'Zor', 'color': Colors.red},
              ].map((option) => _buildPremiumDifficultyTile(
                title: option['title']! as String,
                value: option['value']! as String,
                color: option['color']! as Color,
                onTap: () => Navigator.pop(context),
              )).toList(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeumorphismContainer(
                    onTap: () => Navigator.of(context).pop(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'Kapat',
                      style: TextStyle(
                        color: themeOption.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumDifficultyTile({
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showBackupDialog() {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphismContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [themeOption.primary, themeOption.accent],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.backup_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),                  Text(
                    'Veri Yedekleme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                    width: 1,
                  ),
                ),                child: Text(
                  'Şu anda tüm verileriniz yerel olarak saklanıyor. '
                  'Çevrimiçi yedekleme özelliği yakında eklenecek.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeumorphismContainer(
                    onTap: () => Navigator.of(context).pop(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'Anladım',
                      style: TextStyle(
                        color: themeOption.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _showAboutDialog() {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphismContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [themeOption.primary, themeOption.accent],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.cleaning_services_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),                  Expanded(
                    child: Text(
                      'Temizlik Asistanı',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [                        Text(
                          'Versiyon:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: themeOption.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: themeOption.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),                    Text(
                      'Temizlik Asistanı, ev işlerinizi eğlenceli hale getirmek ve '
                      'motivasyonunuzu artırmak için tasarlanmış bir uygulamadır.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.instance.isDark ? Colors.white : Color(0xFF1E293B),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Copyright © 2025',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  NeumorphismContainer(
                    onTap: () => Navigator.of(context).pop(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      'Kapat',
                      style: TextStyle(
                        color: themeOption.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
