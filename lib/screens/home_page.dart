import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:house_cleaning/screens/tasks_page.dart';
import 'package:house_cleaning/screens/weekly_planner_page.dart';
import 'package:house_cleaning/screens/statistics_page.dart';
import 'package:house_cleaning/screens/profile_page.dart';
import 'package:house_cleaning/services/user_provider.dart';
import 'package:house_cleaning/services/motivation_provider.dart';
import 'package:house_cleaning/widgets/motivation_card.dart';
import 'package:house_cleaning/widgets/premium_effects.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    const DashboardPage(),
    const TasksPage(),
    const WeeklyPlannerPage(),
    const StatisticsPage(), // Rozetler yerine İstatistikler
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }  @override
  Widget build(BuildContext context) {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _pages[_selectedIndex],
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.9),
                ],
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              selectedItemColor: themeOption.primary,
              unselectedItemColor: Colors.grey[400],
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
              onTap: _onItemTapped,
              items: [
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(_selectedIndex == 0 ? 8 : 4),
                    decoration: _selectedIndex == 0 
                        ? BoxDecoration(
                            color: themeOption.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: Icon(
                      _selectedIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                      size: _selectedIndex == 0 ? 26 : 22,
                    ),
                  ),
                  label: 'Ana Sayfa',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(_selectedIndex == 1 ? 8 : 4),
                    decoration: _selectedIndex == 1 
                        ? BoxDecoration(
                            color: themeOption.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: Icon(
                      _selectedIndex == 1 ? Icons.task_alt_rounded : Icons.task_alt_outlined,
                      size: _selectedIndex == 1 ? 26 : 22,
                    ),
                  ),
                  label: 'Görevler',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(_selectedIndex == 2 ? 8 : 4),
                    decoration: _selectedIndex == 2 
                        ? BoxDecoration(
                            color: themeOption.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: Icon(
                      _selectedIndex == 2 ? Icons.calendar_month_rounded : Icons.calendar_month_outlined,
                      size: _selectedIndex == 2 ? 26 : 22,
                    ),
                  ),
                  label: 'Planlayıcı',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(_selectedIndex == 3 ? 8 : 4),
                    decoration: _selectedIndex == 3 
                        ? BoxDecoration(
                            color: themeOption.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: Icon(
                      _selectedIndex == 3 ? Icons.analytics_rounded : Icons.analytics_outlined,
                      size: _selectedIndex == 3 ? 26 : 22,
                    ),
                  ),
                  label: 'İstatistikler',
                ),
                BottomNavigationBarItem(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(_selectedIndex == 4 ? 8 : 4),
                    decoration: _selectedIndex == 4 
                        ? BoxDecoration(
                            color: themeOption.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: Icon(
                      _selectedIndex == 4 ? Icons.person_rounded : Icons.person_outline_rounded,
                      size: _selectedIndex == 4 ? 26 : 22,
                    ),
                  ),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final motivationProvider = Provider.of<MotivationProvider>(context);
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              themeOption.surface,
              Colors.white,
              Colors.white,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium App Bar
              SliverAppBar(
                expandedHeight: 160,
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
                    child: Text(
                      'Merhaba, ${userProvider.currentUser.name}! 👋',
                      style: const TextStyle(
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
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              Icons.cleaning_services_rounded,
                              color: Colors.white.withOpacity(0.2),
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 30,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        right: 80,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
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
                      // Premium İstatistik Kartları
                      _buildPremiumStatsCards(userProvider, context),
                      
                      const SizedBox(height: 32),
                      
                      // Günlük Motivasyon Kartı
                      if (!motivationProvider.isLoading && motivationProvider.canShowNewQuote)
                        _buildPremiumMotivationSection(motivationProvider),
                      
                      const SizedBox(height: 32),
                      
                      // Premium Hızlı Aksiyonlar
                      _buildPremiumQuickActions(context),
                      
                      const SizedBox(height: 32),
                      
                      // Premium Günlük İlerleme
                      _buildPremiumProgressSection(userProvider, context),
                      
                      const SizedBox(height: 32),
                      
                      // Premium Bugünün Görevleri
                      _buildPremiumTodayTasksSection(userProvider, context),
                      
                      const SizedBox(height: 100), // Bottom navigation padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButtonWithAnimation(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TasksPage(),
            ),
          );
        },
        backgroundColor: themeOption.primary,
        tooltip: 'Yeni Görev Ekle',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }  Widget _buildPremiumStatsCards(UserProvider userProvider, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPremiumStatCard(
            icon: Icons.today_rounded,
            title: 'Bugün',
            value: '${userProvider.completedTasksCount}',
            subtitle: 'tamamlandı',
            colors: [
              const Color(0xFF10B981),
              const Color(0xFF34D399),
            ],
            context: context,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPremiumStatCard(
            icon: Icons.trending_up_rounded,
            title: 'Bu Hafta',
            value: '${userProvider.weeklyCompletedTasks}',
            subtitle: 'görev',
            colors: [
              const Color(0xFF3B82F6),
              const Color(0xFF60A5FA),
            ],
            context: context,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPremiumStatCard(
            icon: Icons.local_fire_department_rounded,
            title: 'Seri',
            value: '${userProvider.currentStreak}',
            subtitle: 'gün',
            colors: [
              const Color(0xFFF59E0B),
              const Color(0xFFFBBF24),
            ],
            context: context,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required List<Color> colors,
    required BuildContext context,
  }) {
    return NeumorphismContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colors[0].withOpacity(0.3),
                  blurRadius: 8,
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
          const SizedBox(height: 12),
          ShimmerEffect(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumMotivationSection(MotivationProvider motivationProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.psychology_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Günün Motivasyonu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassmorphismContainer(
          padding: const EdgeInsets.all(24),
          child: MotivationCard(
            quote: motivationProvider.getRandomQuote(),
            showCategory: true,
            onTap: () {
              motivationProvider.getRandomQuote();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumQuickActions(BuildContext context) {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return Column(
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.flash_on_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Hızlı Aksiyonlar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPremiumActionButton(
                icon: Icons.cleaning_services_rounded,
                title: 'Hızlı Temizlik',
                subtitle: '15 dakika',
                colors: [
                  const Color(0xFF8B5CF6),
                  const Color(0xFFA78BFA),
                ],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TasksPage()),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildPremiumActionButton(
                icon: Icons.calendar_view_week_rounded,
                title: 'Haftalık Plan',
                subtitle: 'Görüntüle',
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                ],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WeeklyPlannerPage()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return NeumorphismContainer(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.map((c) => c.withOpacity(0.1)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumProgressSection(UserProvider userProvider, BuildContext context) {
    final progressPercent = (userProvider.todayProgress * 100).round();
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
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Günlük İlerleme',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [themeOption.primary.withOpacity(0.2), themeOption.accent.withOpacity(0.2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '%$progressPercent',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: themeOption.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: userProvider.todayProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [themeOption.primary, themeOption.accent],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: themeOption.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.celebration_rounded,
                color: themeOption.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Bugün ${userProvider.completedTasksCount} görev tamamladınız! Harika iş çıkarıyorsunuz! 🎉',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumTodayTasksSection(UserProvider userProvider, BuildContext context) {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Icons.task_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Bugünün Görevleri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            NeumorphismContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TasksPage()),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tümünü Gör',
                    style: TextStyle(
                      color: themeOption.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: themeOption.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (userProvider.todayTasks.isEmpty)
          GlassmorphismContainer(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.task_alt_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Harika! Bugün için görev yok 🎉',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dinlenme zamanı veya yeni görevler ekleyebilirsiniz',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: userProvider.todayTasks.length > 3 ? 3 : userProvider.todayTasks.length,
            itemBuilder: (context, index) {
              final task = userProvider.todayTasks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: GlassmorphismContainer(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      NeumorphismContainer(
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [themeOption.primary.withOpacity(0.8), themeOption.accent.withOpacity(0.6)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            IconData(
                              task.iconCode,
                              fontFamily: 'MaterialIcons',
                            ),
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: task.isCompleted ? Colors.grey[500] : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${task.estimatedMinutes} dakika',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      NeumorphismContainer(
                        width: 40,
                        height: 40,
                        onTap: () {
                          if (!task.isCompleted) {
                            userProvider.completeTask(task);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: task.isCompleted 
                                ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)])
                                : LinearGradient(colors: [Colors.grey[300]!, Colors.grey[400]!]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            task.isCompleted ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                            color: task.isCompleted ? Colors.white : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        
        if (userProvider.todayTasks.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: NeumorphismContainer(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TasksPage()),
                ),
                child: Text(
                  '+${userProvider.todayTasks.length - 3} görev daha',
                  style: TextStyle(
                    color: themeOption.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
