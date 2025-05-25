import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../models/user_model.dart';
import '../services/user_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'statistics_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  bool _isEditing = false;
  late TabController _tabController;
  
  // Ayarlar için değişkenler
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
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 sekme olacak şekilde güncellendi
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
    
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        
        _nameController.text = user.name;
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profil'),
            centerTitle: true,
            actions: [
              if (_tabController.index == 0)
                IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  onPressed: () {
                    setState(() {
                      if (_isEditing) {
                        // Değişiklikleri kaydet
                        _saveUserChanges(userProvider);
                      }
                      _isEditing = !_isEditing;
                    });
                  },
                ),
            ],            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryColor,
              labelColor: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Colors.black,
              tabs: const [
                Tab(
                  icon: Icon(Icons.person),
                  text: 'Profil',
                ),
                Tab(
                  icon: Icon(Icons.settings),
                  text: 'Ayarlar',
                ),
                Tab(
                  icon: Icon(Icons.bar_chart),
                  text: 'İstatistikler',
                ),
              ],
            ),
          ),          body: TabBarView(
            controller: _tabController,
            children: [
              // Profil sekmesi
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profil kartı
                    _buildProfileCard(user),
                    
                    const SizedBox(height: 24),
                    
                    // Özet istatistikler
                    _buildStatisticsSection(userProvider),
                    
                    const SizedBox(height: 24),
                    
                    // Rozetler
                    _buildBadgesSection(user),
                    
                    const SizedBox(height: 24),
                    
                    // Premium durumu
                    _buildPremiumSection(userProvider),
                  ],
                ),
              ),
                // Ayarlar sekmesi
              ListView(
                children: [
                  const SizedBox(height: 16),
                  
                  // Tema Ayarları
                  _buildSectionHeader('Tema Ayarları'),
                  _buildSettingSwitch(
                    title: 'Karanlık Mod',
                    subtitle: 'Uygulamayı koyu renk temasıyla görüntüle',
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                      });
                      // Tema değiştirme fonksiyonunu çağır
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
                      userProvider.saveNotificationSettings(notificationsEnabled: value);
                    },
                  ),
                  _buildSettingSwitch(
                    title: 'Ses Efektleri',
                    subtitle: 'Görev tamamlama ve rozet kazanma sesi',
                    value: _soundEffectsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _soundEffectsEnabled = value;
                      });
                      
                      // Ses ayarlarını kaydet
                      userProvider.saveNotificationSettings(
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
            ],
          ),
        );
      },
    );
  }
  
  // ProfilePage widget'ları
  Widget _buildProfileCard(User user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profil resmi
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
              child: const Icon(
                Icons.person,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // İsim
            _isEditing
                ? TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'İsim',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            
            const SizedBox(height: 8),
            
            // Seviye bilgisi
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Seviye ${user.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${user.points} Puan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
    Widget _buildStatisticsSection(UserProvider userProvider) {
    // Doğrudan UserProvider'dan değerleri alarak kullan, late değişkenler yok
    final user = userProvider.currentUser;
    final totalCompletedTasks = user.totalCompletedTasks;
    final streakDays = userProvider.currentStreak;
    final todayProgress = userProvider.todayProgress;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İstatistikler',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildStatisticItem(
                  icon: Icons.check_circle,
                  title: 'Tamamlanan Görevler',
                  value: totalCompletedTasks.toString(),
                ),
                const Divider(),
                _buildStatisticItem(
                  icon: Icons.local_fire_department,
                  title: 'Mevcut Seri',
                  value: '$streakDays gün',
                ),
                const Divider(),
                _buildStatisticItem(
                  icon: Icons.watch_later,
                  title: 'Bu Haftaki İlerleme',
                  value: '${(todayProgress * 100).toStringAsFixed(0)}%',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatisticItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBadgesSection(User user) {
    // Tamamlanan rozetlerin listesi
    final List<Map<String, dynamic>> badges = [
      {
        'name': 'Başlangıç',
        'icon': Icons.play_circle,
        'description': 'İlk görevi tamamladınız',
        'unlocked': true,
      },
      {
        'name': 'Çalışkan',
        'icon': Icons.work,
        'description': '10 görev tamamlandı',
        'unlocked': user.totalCompletedTasks >= 10,
      },
      {
        'name': 'Uzman Temizlikçi',
        'icon': Icons.cleaning_services,
        'description': '50 görev tamamlandı',
        'unlocked': user.totalCompletedTasks >= 50,
      },
      {
        'name': 'Seri Oluşturucu',
        'icon': Icons.local_fire_department,
        'description': '7 günlük seri',
        'unlocked': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rozetler',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: badge['unlocked'] ? AppTheme.primaryColor : Colors.grey[300],
                        shape: BoxShape.circle,
                        boxShadow: badge['unlocked'] ? [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                          ),
                        ] : null,
                      ),
                      child: Icon(
                        badge['icon'],
                        color: badge['unlocked'] ? Colors.white : Colors.grey[600],
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      badge['name'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: badge['unlocked'] ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
    Widget _buildPremiumSection(UserProvider userProvider) {
    // User model içerisinde isPremium alanı olmadığını varsayarak şimdilik
    // bir kontrol ekleyelim, gerçek uygulamada kullanıcı modelinde olmalıdır
    final isPremium = userProvider.currentUser.points > 1000;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Premium Durum',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isPremium ? Icons.star : Icons.star_border,
                      color: isPremium ? Colors.amber : Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPremium ? 'Premium Üye' : 'Standart Üye',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          isPremium
                              ? 'Tüm özelliklere erişebilirsiniz'
                              : 'Özel özelliklere erişmek için yükseltin',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!isPremium)
                  ElevatedButton(
                    onPressed: () {
                      // Premium'a yükselt
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Premium\'a Yükselt',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
    void _saveUserChanges(UserProvider userProvider) {
    if (_nameController.text.isNotEmpty) {
      userProvider.updateUserName(_nameController.text);
    }
  }
  
  void _showPremiumDialog(UserProvider userProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('Premium Abonelik'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bu özellik henüz geliştirme aşamasındadır.'),
            SizedBox(height: 16),
            Text('Premium abonelik, uygulamadaki reklamsız deneyim, özel temalar, premium motivasyon alıntıları ve daha fazlasını sunar.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('İptal'),
          ),
          // Demo özelliği: Test için Premium durumunu değiştir
          TextButton(
            onPressed: () {
              userProvider.setPremiumStatus(!userProvider.isPremium);
              Navigator.of(context).pop();
            },
            child: const Text('Test Et', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }
  
  String _getBadgeName(String badgeId) {
    switch (badgeId) {
      case 'first_task':
        return 'İlk Görev';
      case 'kitchen_master':
        return 'Mutfak Ustası';
      case 'bathroom_hero':
        return 'Banyo Kahramanı';
      case 'cleaning_expert':
        return 'Temizlik Uzmanı';
      default:
        return 'Rozet';
    }
  }
  
  // SettingsPage widget'ları
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
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
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      activeColor: AppTheme.primaryColor,
      onChanged: onChanged,
    );
  }
  
  Widget _buildColorSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tema Rengi',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _themeColors.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedColorIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColorIndex = index;
                    });
                    
                    // Tema rengi değiştirme fonksiyonunu çağır
                    final userProvider = Provider.of<UserProvider>(context, listen: false);
                    userProvider.saveSettings({'themeIndex': index});
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: _themeColors[index],
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: _themeColors[index].withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 7,
                              )
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                          )
                        : null,
                  ),
                );
              },
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
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showLanguageSelector();
      },
    );
  }
  
  // Dialog fonksiyonları
  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dil Seçin'),
        content: SizedBox(
          width: double.minPositive,
          height: 200,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_languages[index]),
                trailing: _languages[index] == _selectedLanguage
                    ? const Icon(
                        Icons.check,
                        color: AppTheme.primaryColor,
                      )
                    : null,
                onTap: () {
                  setState(() {
                    _selectedLanguage = _languages[index];
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }
  
  void _showReminderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hatırlatma Sıklığı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Günde bir kez'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: const Text('Günde iki kez'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: const Text('Sadece eksik görevler için'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              title: const Text('Hatırlatma yok'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDifficultySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Varsayılan Zorluk Seviyesi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.sentiment_satisfied, color: Colors.green),
              title: const Text('Kolay'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.sentiment_neutral, color: Colors.orange),
              title: const Text('Orta'),
              onTap: () => Navigator.of(context).pop(),
            ),
            ListTile(
              leading: const Icon(Icons.sentiment_dissatisfied, color: Colors.red),
              title: const Text('Zor'),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Veri Yedekleme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.cloud_upload),
              title: const Text('Verileri Yedekle'),
              onTap: () {
                // Veri yedekleme işlemi
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.cloud_download),
              title: const Text('Yedekten Geri Yükle'),
              onTap: () {
                // Veri geri yükleme işlemi
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Ev Temizlik Asistanı',
        applicationVersion: '1.0.0',
        applicationIcon: const Icon(
          Icons.cleaning_services,
          size: 36,
          color: AppTheme.primaryColor,
        ),
        applicationLegalese: '© 2023 Ev Temizlik Asistanı',
        children: [
          const SizedBox(height: 16),
          const Text(
            'Ev temizliği alışkanlıklarınızı geliştirmek için tasarlanmış bir uygulama.',
          ),
          const SizedBox(height: 8),
          const Text(
            'Bu uygulama, ev temizliğini daha eğlenceli ve motive edici hale getirmek için özellikler sunar.',
          ),
        ],
      ),
    );
  }
}
