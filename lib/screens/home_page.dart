import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:house_cleaning/constants/motivation_quotes.dart';
import 'package:house_cleaning/screens/tasks_page.dart';
import 'package:house_cleaning/screens/weekly_planner_page.dart';
import 'package:house_cleaning/screens/badges_page.dart';
import 'package:house_cleaning/screens/statistics_page.dart';
import 'package:house_cleaning/screens/settings_page.dart';
import 'package:house_cleaning/models/task_model.dart';
import 'package:house_cleaning/services/user_provider.dart';
import 'package:house_cleaning/services/notification_service.dart';

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
    const BadgesPage(),
    const StatisticsPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Görevler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Planlayıcı',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Rozetler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'İstatistik',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _motivationQuote = MotivationQuotes.getRandomQuote();

  @override
  void initState() {
    super.initState();
    
    // 5 saniye sonra bildirim göster
    Future.delayed(const Duration(seconds: 5), () {
      NotificationService.instance.showNotification(
        id: 1,
        title: 'Temizlik Asistanına Hoşgeldiniz!',
        body: 'Bugünkü temizlik görevleriniz sizi bekliyor.',
      );
    });
  }

  void _completeTask(Task task) {
    // UserProvider'dan görev tamamlama fonksiyonunu çağır
    Provider.of<UserProvider>(context, listen: false).completeTask(task);

    // Başarı bildirimi göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${task.title} görevi tamamlandı! +${task.points} puan kazandınız.'),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Bildirimi göster
    NotificationService.instance.showNotification(
      id: 2,
      title: 'Görev Tamamlandı!',
      body: '${task.title} görevini başarıyla tamamladınız! +${task.points} puan kazandınız.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isLoaded) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Normal widget ağacını oluştur
        final user = userProvider.currentUser;
        final todaysTasks = userProvider.todayTasks;
        final progressPercentage = userProvider.todayProgress;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Temizlik Asistanı'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Bildirim sayfasına git
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Motivasyon mesajı kartı
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: AppTheme.primaryColor,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _motivationQuote,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Seviye ve puan bilgisi
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          title: 'Seviye',
                          value: '${user.level}',
                          icon: Icons.trending_up,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          title: 'Toplam Puan',
                          value: '${user.points}',
                          icon: Icons.star,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // İlerleme çubuğu
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bugünün İlerlemesi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progressPercentage,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progressPercentage * 100).toInt()}% tamamlandı',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bugünün görevleri
                  const Text(
                    'Bugünün Görevleri',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  todaysTasks.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.task_alt,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Bugün için görev bulunmuyor',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: todaysTasks.length,
                          itemBuilder: (context, index) {
                            final task = todaysTasks[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: task.isCompleted
                                      ? AppTheme.successColor
                                      : AppTheme.primaryColor,
                                  child: Icon(
                                    task.icon,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    fontWeight: task.isCompleted
                                        ? FontWeight.normal
                                        : FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${task.estimatedMinutes} dk. | ${task.points} puan',
                                ),
                                trailing: task.isCompleted
                                    ? const Icon(Icons.check_circle, color: AppTheme.successColor)
                                    : OutlinedButton(
                                        onPressed: () => _completeTask(task),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppTheme.primaryColor),
                                        ),
                                        child: const Text('Tamamla'),
                                      ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppTheme.primaryColor,
            onPressed: () {
              // Yeni görev ekle
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
