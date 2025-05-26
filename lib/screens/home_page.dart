import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:house_cleaning/screens/tasks_page.dart';
import 'package:house_cleaning/screens/weekly_planner_page.dart';
import 'package:house_cleaning/screens/statistics_page.dart'; // İstatistikler sayfası için import
import 'package:house_cleaning/screens/profile_page.dart';
import 'package:house_cleaning/services/user_provider.dart';
import 'package:house_cleaning/services/motivation_provider.dart';
import 'package:house_cleaning/widgets/motivation_card.dart';

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
    final themeOption = AppTheme.instance.currentThemeOption;    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: themeOption.primary,
        unselectedItemColor: Colors.grey[500],
        backgroundColor: Colors.white,
        elevation: 4,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 9,
        ),
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 0 ? Icons.home : Icons.home_outlined,
              size: 20,
            ),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 1 ? Icons.task_alt : Icons.task_alt_outlined,
              size: 20,
            ),
            label: 'Görevler',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 2 ? Icons.calendar_month : Icons.calendar_month_outlined,
              size: 20,
            ),
            label: 'Planlayıcı',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 3 ? Icons.bar_chart : Icons.bar_chart_outlined,
              size: 20,
            ),
            label: 'İstatistikler',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _selectedIndex == 4 ? Icons.person : Icons.person_outline,
              size: 20,
            ),
            label: 'Profil',
          ),
        ],
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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Merhaba, ${userProvider.currentUser.name}! 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                centerTitle: false,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: themeOption.getGradientBackground(),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 20,
                        right: 20,
                        child: Icon(
                          Icons.cleaning_services,
                          color: Colors.white.withOpacity(0.08),
                          size: 80,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      themeOption.primary.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // İstatistik Kartları
                      _buildStatsCards(userProvider, context),
                      
                      const SizedBox(height: 24),
                      
                      // Günlük Motivasyon Kartı
                      if (!motivationProvider.isLoading && motivationProvider.canShowNewQuote)
                        _buildMotivationSection(motivationProvider),
                      
                      const SizedBox(height: 24),
                      
                      // Hızlı Aksiyonlar
                      _buildQuickActions(context),
                      
                      const SizedBox(height: 24),
                      
                      // Günlük İlerleme
                      _buildProgressSection(userProvider, context),
                      
                      const SizedBox(height: 24),
                      
                      // Bugünün Görevleri
                      _buildTodayTasksSection(userProvider, context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TasksPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Görev'),
        backgroundColor: themeOption.primary,
      ),
    );
  }

  Widget _buildStatsCards(UserProvider userProvider, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.today,
            title: 'Bugün',
            value: '${userProvider.completedTasksCount}',
            subtitle: 'tamamlandı',
            color: Colors.green,
            context: context,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.schedule,
            title: 'Bu Hafta',
            value: '${userProvider.weeklyCompletedTasks}',
            subtitle: 'görev',
            color: Colors.blue,
            context: context,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events,
            title: 'Seri',
            value: '${userProvider.currentStreak}',
            subtitle: 'gün',
            color: Colors.orange,
            context: context,
          ),
        ),
      ],
    );
  }
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationSection(MotivationProvider motivationProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💡 Günün Motivasyonu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        MotivationCard(
          quote: motivationProvider.getRandomQuote(),
          showCategory: true,
          onTap: () {
            motivationProvider.getRandomQuote();
          },
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '⚡ Hızlı Aksiyonlar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.cleaning_services,
                title: 'Hızlı Temizlik',
                subtitle: '15 dakika',
                color: Colors.purple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TasksPage()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.calendar_today,
                title: 'Haftalık Plan',
                subtitle: 'Görüntüle',
                color: Colors.indigo,
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
  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(UserProvider userProvider, BuildContext context) {
    final progressPercent = (userProvider.todayProgress * 100).round();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📊 Günlük İlerleme',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '%$progressPercent',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: userProvider.todayProgress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bugün ${userProvider.completedTasksCount} görev tamamladınız! 🎉',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTasksSection(UserProvider userProvider, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '📋 Bugünün Görevleri',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TasksPage()),
              ),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('Tümünü Gör'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (userProvider.todayTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Harika! Bugün için görev yok 🎉',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dinlenme zamanı veya yeni görevler ekleyebilirsiniz',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
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
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CheckboxListTile(
                  value: task.isCompleted,
                  onChanged: (bool? value) {
                    if (value == true) {
                      userProvider.completeTask(task);
                    }
                  },
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${task.estimatedMinutes} dakika',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      IconData(
                        task.iconCode,
                        fontFamily: 'MaterialIcons',
                      ),
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              );
            },
          ),
        
        if (userProvider.todayTasks.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TasksPage()),
                ),
                child: Text(
                  '+${userProvider.todayTasks.length - 3} görev daha',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
