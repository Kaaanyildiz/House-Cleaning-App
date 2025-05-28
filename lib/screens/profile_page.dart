import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../constants/app_theme.dart';
import '../models/user_model.dart';
import '../services/user_provider.dart';
import '../widgets/premium_effects.dart';
import 'badges_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePagePremiumState createState() => _ProfilePagePremiumState();
}

class _ProfilePagePremiumState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  bool _isEditing = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        _nameController.text = user.name;
          return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppTheme.instance.isDark 
                  ? [
                      const Color(0xFF1a1a1a),
                      const Color(0xFF2d2d2d),
                      const Color(0xFF1a1a1a),
                    ]
                  : [
                      Colors.grey[50]!,
                      Colors.white,
                      Colors.grey[100]!,
                    ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
            child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(user.name, 
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(
                        color: Colors.black38,
                        blurRadius: 4,
                        offset: Offset(1, 1),
                      )],
                    ),
                  ),
                  background: AnimatedGradientContainer(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.8),
                      AppTheme.primaryColor.withOpacity(0.6),
                      AppTheme.primaryColor.withOpacity(0.9),
                    ],
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(_isEditing ? Icons.check : Icons.edit),
                    onPressed: () {
                      setState(() {
                        if (_isEditing) {
                          _saveUserChanges(userProvider);
                        }
                        _isEditing = !_isEditing;
                      });
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(user),
                      const SizedBox(height: 24),
                      _buildActionButtons(context),
                      const SizedBox(height: 24),
                      _buildStatisticsSection(userProvider),
                      const SizedBox(height: 24),                      _buildPremiumSection(userProvider),
                    ],
                  ),
                ),
              ),
            ],
            ),
          ),
          floatingActionButton: FloatingActionButtonWithAnimation(
            onPressed: () {
              // Profil ayarlarına git
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            child: const Icon(Icons.settings),
            backgroundColor: AppTheme.primaryColor,
            tooltip: 'Ayarlar',
          ),
        );
      },
    );
  }
  
  // Premium Action Buttons
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GlassmorphismContainer(
            padding: const EdgeInsets.all(2),
            color: Colors.amber.withOpacity(0.2),
            child: NeumorphismContainer(
              backgroundColor: Colors.amber[600]!.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BadgesPage()),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Rozetler',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassmorphismContainer(
            padding: const EdgeInsets.all(2),
            color: Colors.blueGrey.withOpacity(0.2),
            child: NeumorphismContainer(
              backgroundColor: Colors.blueGrey[700]!.withOpacity(0.8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsPage()),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.settings, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Ayarlar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Premium Profile Card
  Widget _buildProfileCard(User user) {
    return GlassmorphismContainer(
      borderRadius: 24,
      blur: 20,
      padding: const EdgeInsets.all(20.0),
      color: Colors.white.withOpacity(0.1),
      child: Column(
        children: [
          // İsim düzenleme
          if (_isEditing)
            ShimmerEffect(
              baseColor: AppTheme.primaryColor.withOpacity(0.2),
              highlightColor: AppTheme.primaryColor.withOpacity(0.5),
              child: TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'İsim',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            
          // Seviye bilgisi kartı
          const SizedBox(height: 16),
          AnimatedGradientContainer(
            colors: [
              AppTheme.primaryColor.withOpacity(0.8),
              AppTheme.primaryColor.withOpacity(0.6),
              Color.fromARGB(255, 76, 175, 137).withOpacity(0.9),
            ],
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Seviye ve puan
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seviye ${user.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amberAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user.points} Puan',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // İlerleme göstergesi
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Doluluk oranı daire grafiği
                      CircularProgressIndicator(
                        value: user.points / (user.level * 100), // Örnek ilerleme
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      // İlerleme yüzdesi
                      Text(
                        "${((user.points % (user.level * 100)) / (user.level * 100) * 100).toInt()}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Rozet bilgileri
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [              _buildUserBadge(Icons.timer, "5 gün", "Seri"),
              const SizedBox(width: 8),
              _buildUserBadge(Icons.task_alt, "${user.totalCompletedTasks}", "Görev"),
              const SizedBox(width: 8),
              _buildUserBadge(Icons.emoji_events, "${user.completedChallengeCount}", "Meydan Okuma"),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserBadge(IconData icon, String value, String label) {
    return Expanded(
      child: NeumorphismContainer(
        borderRadius: 16,
        backgroundColor: Colors.white.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        height: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.instance.isDark ? Colors.white : Colors.black87,
              ),
            ),Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.instance.isDark ? Colors.grey[300] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Premium Statistics Section
  Widget _buildStatisticsSection(UserProvider userProvider) {
    final user = userProvider.currentUser;
    final totalCompletedTasks = user.totalCompletedTasks;
    final streakDays = userProvider.currentStreak;
    final todayProgress = userProvider.todayProgress;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedGradientContainer(
          colors: [
            AppTheme.primaryColor.withOpacity(0.7),
            Color.fromARGB(255, 75, 170, 135).withOpacity(0.8),
            AppTheme.primaryColor.withOpacity(0.6),
          ],
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: const Text(
            'İstatistikler',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GlassmorphismContainer(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildPremiumStatisticItem(
                icon: Icons.check_circle,
                title: 'Tamamlanan Görevler',
                value: totalCompletedTasks.toString(),
                gradient: [Colors.green.shade300, Colors.green.shade700],
              ),
              const Divider(height: 24, thickness: 1, color: Colors.white24),
              _buildPremiumStatisticItem(
                icon: Icons.local_fire_department,
                title: 'Mevcut Seri',
                value: '$streakDays gün',
                gradient: [Colors.orange.shade300, Colors.deepOrange.shade700],
              ),
              const Divider(height: 24, thickness: 1, color: Colors.white24),
              _buildPremiumStatisticItem(
                icon: Icons.watch_later,
                title: 'Bu Haftaki İlerleme',
                value: '${(todayProgress * 100).toStringAsFixed(0)}%',
                gradient: [Colors.blue.shade300, Colors.blue.shade700],
                showProgress: true,
                progress: todayProgress,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPremiumStatisticItem({
    required IconData icon,
    required String title,
    required String value,
    List<Color>? gradient,
    bool showProgress = false,
    double progress = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradient ?? [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
              ),
              boxShadow: [
                BoxShadow(
                  color: (gradient?.first ?? AppTheme.primaryColor).withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.instance.isDark ? Colors.grey[300] : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.instance.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    
                    if (showProgress) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 8,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.grey.withOpacity(0.2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradient ?? [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Premium Status Section
  Widget _buildPremiumSection(UserProvider userProvider) {
    final isPremium = userProvider.currentUser.points > 1000;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedGradientContainer(
          colors: [
            Colors.purple.withOpacity(0.7),
            Colors.deepPurple.withOpacity(0.8),
            Colors.purple.withOpacity(0.6),
          ],
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: const Text(
            'Premium Durum',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GlassmorphismContainer(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShimmerEffect(
                    baseColor: isPremium ? Colors.amber.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
                    highlightColor: isPremium ? Colors.amber.withOpacity(0.8) : Colors.grey.withOpacity(0.4),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPremium ? Colors.amber.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                        border: Border.all(
                          color: isPremium ? Colors.amber : Colors.grey.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        isPremium ? Icons.star : Icons.star_border,
                        color: isPremium ? Colors.amber : Colors.grey,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [                        Text(
                          isPremium ? 'Premium Üye' : 'Standart Üye',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isPremium 
                              ? Colors.amber 
                              : (AppTheme.instance.isDark ? Colors.white : Colors.black87),
                          ),
                        ),Text(
                          isPremium
                              ? 'Tüm özelliklere erişebilirsiniz'
                              : 'Özel özelliklere erişmek için yükseltin',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.instance.isDark ? Colors.grey[300] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),                AnimatedGradientContainer(
                  colors: isPremium 
                    ? const [
                        Color(0xFFFFD700),
                        Color(0xFFFFA500),
                        Color(0xFFFF8C00),
                      ]
                    : const [
                        Color(0xFF9C27B0),
                        Color(0xFF673AB7),
                        Color(0xFF3F51B5),
                      ],
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.all(2),                  child: NeumorphismContainer(
                    backgroundColor: (isPremium ? Colors.amber : Colors.purple).withOpacity(0.1),
                    borderRadius: 10,
                    onTap: () {
                      if (!isPremium) {
                        // Premium'a yükselt - puan ekle
                        userProvider.addPoints(2000);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tebrikler! Premium üye oldunuz.'))
                        );
                      } else {
                        // Tamamlanan meydan okuma sayısını artır
                        userProvider.completeChallenge();
                        // Bonus puan ekle
                        userProvider.addPoints(50);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Meydan okuma tamamlandı! 50 bonus puan kazandınız.'))
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        isPremium ? 'Meydan Okuma Tamamla' : 'Premium\'a Yükselt',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
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
}
