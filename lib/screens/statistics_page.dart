import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:house_cleaning/models/task_model.dart';
import 'package:house_cleaning/services/user_provider.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {  // İstatistik verileri
  // Varsayılan değerlerle başlatıyoruz, böylece late error olmaz
  Map<String, double> _categoryDistribution = {
    'Mutfak': 25, 
    'Banyo': 25, 
    'Genel': 25, 
    'Özel': 25
  };
  Map<String, int> _completedTasksByDay = {
    'Pazartesi': 0,
    'Salı': 0,
    'Çarşamba': 0,
    'Perşembe': 0,
    'Cuma': 0,
    'Cumartesi': 0,
    'Pazar': 0,
  };
  int _totalCompletedTasks = 0;
  int _streakDays = 0;
  int _totalPoints = 0;
  double _averageTimePerDay = 0.0; // dakika olarak
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    // Hemen çağırıyoruz, postFrameCallback'e gerek yok
    _loadStatistics();
  }
    // İstatistikleri yükle
  void _loadStatistics() {
    // İlk başta yükleme durumunu true yapıyoruz
    setState(() {
      _isLoading = true;
    });
    
    // Provider mevcut değilse erken çıkış yap
    if (!mounted) return;
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      // Kategori dağılımını hesapla
      _categoryDistribution = _calculateCategoryDistribution(userProvider);
      
      // Günlere göre tamamlanan görevleri hesapla
      _completedTasksByDay = _calculateCompletedTasksByDay(userProvider);
      
      // Toplam tamamlanan görev sayısı
      _totalCompletedTasks = userProvider.currentUser.totalCompletedTasks;
      
      // Mevcut seri (gün sayısı)
      _streakDays = userProvider.currentStreak;
      
      // Toplam puanlar
      _totalPoints = userProvider.currentUser.points;
      
      // Ortalama günlük süre
      _averageTimePerDay = _calculateAverageTimePerDay(userProvider);
    } catch (e) {
      // Hata durumunda varsayılan değerleri koruyoruz ve hata mesajı gösterilebilir
      print('İstatistik yüklenirken hata: $e');
    } finally {
      // Mounted kontrolü yaparak güvenli bir şekilde setState çağırıyoruz
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Kategori dağılımını hesapla
  Map<String, double> _calculateCategoryDistribution(UserProvider userProvider) {
    final Map<TaskCategory, int> categoryCounts = {
      TaskCategory.kitchen: 0,
      TaskCategory.bathroom: 0,
      TaskCategory.general: 0,
      TaskCategory.special: 0,
    };
    
    int totalTasks = 0;
    
    // Tamamlanan görevleri kategorilere göre say
    for (var tasksOfDay in userProvider.currentUser.completedTasks.values) {
      for (var taskId in tasksOfDay) {
        final task = userProvider.allTasks.firstWhere(
          (t) => t.id == taskId,
          orElse: () => userProvider.allTasks.first,
        );
        
        categoryCounts[task.category] = (categoryCounts[task.category] ?? 0) + 1;
        totalTasks++;
      }
    }
    
    // Yüzdelikleri hesapla
    final Map<String, double> distribution = {};
    if (totalTasks > 0) {
      distribution['Mutfak'] = (categoryCounts[TaskCategory.kitchen] ?? 0) * 100 / totalTasks;
      distribution['Banyo'] = (categoryCounts[TaskCategory.bathroom] ?? 0) * 100 / totalTasks;
      distribution['Genel'] = (categoryCounts[TaskCategory.general] ?? 0) * 100 / totalTasks;
      distribution['Özel'] = (categoryCounts[TaskCategory.special] ?? 0) * 100 / totalTasks;
    } else {
      // Görev yoksa eşit dağıtım
      distribution['Mutfak'] = 25;
      distribution['Banyo'] = 25;
      distribution['Genel'] = 25;
      distribution['Özel'] = 25;
    }
    
    return distribution;
  }
  
  // Günlere göre tamamlanan görev sayısını hesapla
  Map<String, int> _calculateCompletedTasksByDay(UserProvider userProvider) {
    final Map<String, int> tasksByDay = {
      'Pazartesi': 0,
      'Salı': 0,
      'Çarşamba': 0,
      'Perşembe': 0,
      'Cuma': 0,
      'Cumartesi': 0,
      'Pazar': 0,
    };
    
    // Son 7 gün için görevleri say
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final taskList = userProvider.currentUser.completedTasks[date] ?? [];
      
      // Haftanın günü (1=Pazartesi, 7=Pazar)
      int weekday = date.weekday;
      
      // Günlere göre say
      switch (weekday) {
        case 1:
          tasksByDay['Pazartesi'] = (tasksByDay['Pazartesi'] ?? 0) + taskList.length;
          break;
        case 2:
          tasksByDay['Salı'] = (tasksByDay['Salı'] ?? 0) + taskList.length;
          break;
        case 3:
          tasksByDay['Çarşamba'] = (tasksByDay['Çarşamba'] ?? 0) + taskList.length;
          break;
        case 4:
          tasksByDay['Perşembe'] = (tasksByDay['Perşembe'] ?? 0) + taskList.length;
          break;
        case 5:
          tasksByDay['Cuma'] = (tasksByDay['Cuma'] ?? 0) + taskList.length;
          break;
        case 6:
          tasksByDay['Cumartesi'] = (tasksByDay['Cumartesi'] ?? 0) + taskList.length;
          break;
        case 7:
          tasksByDay['Pazar'] = (tasksByDay['Pazar'] ?? 0) + taskList.length;
          break;
      }
    }
    
    return tasksByDay;
  }
  
  // Ortalama günlük süreyi hesapla (dakika)
  double _calculateAverageTimePerDay(UserProvider userProvider) {
    int totalMinutes = 0;
    int totalDaysWithTasks = 0;
    
    // Tüm tamamlanan görevleri dolaş
    for (var entry in userProvider.currentUser.completedTasks.entries) {
      if (entry.value.isNotEmpty) {
        int minutesForDay = 0;
        
        // Bu gün için tamamlanan tüm görevleri say
        for (var taskId in entry.value) {
          final task = userProvider.allTasks.firstWhere(
            (t) => t.id == taskId,
            orElse: () => userProvider.allTasks.isNotEmpty 
              ? userProvider.allTasks.first 
              : Task(
                  id: '0',
                  title: 'Boş Görev',
                  description: '',
                  category: TaskCategory.general,
                  difficulty: TaskDifficulty.easy,
                  iconCode: Icons.help.codePoint,
                  estimatedMinutes: 0,
                ),
          );
          
          minutesForDay += task.estimatedMinutes;
        }
        
        totalMinutes += minutesForDay;
        totalDaysWithTasks++;
      }
    }
    
    // Ortalamayı hesapla
    return totalDaysWithTasks > 0 ? totalMinutes / totalDaysWithTasks : 0;
  }  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isLoaded || _isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('İstatistikler'),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: () {
                  // Tarih aralığı seçimi
                  _showDateRangeSelector();
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
                  // Özet kartları
                  _buildSummarySection(),
                  
                  const SizedBox(height: 24),
                  
                  // Görev dağılımı pasta grafiği
                  _buildPieChartSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Haftalık aktivite grafiği
                  _buildWeeklyActivitySection(),

                  const SizedBox(height: 24),

                  // Alışkanlıklar ve başarımlar
                  _buildHabitsSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Özet İstatistikler',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.check_circle,
                title: 'Tamamlanan Görev',
                value: '$_totalCompletedTasks',
                color: Colors.green[700]!,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.local_fire_department,
                title: 'Gün Serisi',
                value: '$_streakDays',
                color: Colors.orange[700]!,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.star,
                title: 'Toplam Puan',
                value: '$_totalPoints',
                color: Colors.purple[700]!,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.access_time,
                title: 'Günlük Ortalama Süre',
                value: '$_averageTimePerDay dk',
                color: Colors.blue[700]!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Görev Dağılımı',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: _buildSimplePieChart(),
              ),
              Expanded(
                flex: 2,
                child: _buildPieChartLegend(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimplePieChart() {
    return CustomPaint(
      size: const Size(150, 150),
      painter: _PieChartPainter(_categoryDistribution),
    );
  }

  Widget _buildPieChartLegend() {
    final List<Color> colors = [
      Colors.blue[400]!,
      Colors.green[400]!,
      Colors.red[400]!,
      Colors.amber[400]!,
    ];

    int index = 0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _categoryDistribution.entries.map((entry) {
        final color = colors[index % colors.length];
        index++;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${entry.key}: %${entry.value.round()}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeeklyActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Haftalık Aktivite',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: _buildBarChart(),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final List<String> days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final List<int> values = _completedTasksByDay.values.toList();
    final int maxValue = values.reduce(math.max);

    return Row(
      children: List.generate(days.length, (index) {
        final int currentValue = values[index];
        final double percentage = maxValue > 0 ? currentValue / maxValue : 0;

        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                currentValue.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Container(
                  width: 20,
                  height: 150 * percentage,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.5 + 0.5 * percentage),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(days[index]),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHabitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alışkanlıklar ve Başarımlar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildHabitItem(
                  icon: Icons.auto_awesome,
                  title: 'En iyi olduğun kategori',
                  value: 'Mutfak',
                  progress: 0.7,
                ),
                const Divider(),
                _buildHabitItem(
                  icon: Icons.whatshot,
                  title: 'En verimli gün',
                  value: 'Cumartesi',
                  progress: 0.9,
                ),
                const Divider(),
                _buildHabitItem(
                  icon: Icons.access_time_filled,
                  title: 'En çok görev yapılan saat',
                  value: '10:00 - 12:00',
                  progress: 0.6,
                ),
                const Divider(),
                _buildHabitItem(
                  icon: Icons.trending_up,
                  title: 'Gelişim Trendi',
                  value: 'Yükseliyor',
                  progress: 0.8,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitItem({
    required IconData icon,
    required String title,
    required String value,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 32),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryColor.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDateRangeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tarih Aralığı'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Bu Hafta'),
              onTap: () {
                Navigator.pop(context);
                // Bu haftanın verilerini göster
              },
            ),
            ListTile(
              title: const Text('Bu Ay'),
              onTap: () {
                Navigator.pop(context);
                // Bu ayın verilerini göster
              },
            ),
            ListTile(
              title: const Text('Son 3 Ay'),
              onTap: () {
                Navigator.pop(context);
                // Son 3 ayın verilerini göster
              },
            ),
            ListTile(
              title: const Text('Tüm Zamanlar'),
              onTap: () {
                Navigator.pop(context);
                // Tüm zamanların verilerini göster
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final Map<String, double> data;

  _PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.fill;

    double startAngle = 0;
    int index = 0;
    
    final colors = [
      Colors.blue[400]!,
      Colors.green[400]!,
      Colors.red[400]!,
      Colors.amber[400]!,
    ];
    
    final total = data.values.fold<double>(0, (sum, value) => sum + value);
    
    data.forEach((category, value) {
      final sweepAngle = value * 2 * math.pi / total;
      
      paint.color = colors[index % colors.length];
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
      index++;
    });
    
    // Orta kısımda boşluk oluştur (isteğe bağlı)
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.5, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
