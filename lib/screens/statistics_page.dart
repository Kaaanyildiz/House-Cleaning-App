import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:house_cleaning/models/task_model.dart';
import 'package:house_cleaning/services/user_provider.dart';
import 'package:house_cleaning/widgets/premium_effects.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  // İstatistik verileri
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
  }

  @override
  Widget build(BuildContext context) {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isLoaded || _isLoading) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeOption.primary.withOpacity(0.1),
                    themeOption.accent.withOpacity(0.1),
                  ],
                ),
              ),
              child: const Center(
                child: ShimmerEffect(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          );
        }        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppTheme.instance.isDark
                    ? [
                        const Color(0xFF1F2937).withOpacity(0.9),
                        const Color(0xFF111827).withOpacity(0.95),
                        const Color(0xFF0F172A),
                      ]
                    : [
                        themeOption.primary.withOpacity(0.05),
                        themeOption.accent.withOpacity(0.05),
                        Colors.white,
                      ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
              slivers: [
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: AnimatedGradientContainer(
                      colors: [
                        themeOption.primary,
                        themeOption.accent,
                      ],
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              themeOption.primary,
                              themeOption.accent,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 40),
                              Text(
                                '📊 İstatistikler',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Temizlik Performansın',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NeumorphismContainer(
                        padding: const EdgeInsets.all(8),
                        child: IconButton(
                          icon: Icon(Icons.date_range, color: themeOption.primary),
                          onPressed: () {
                            _showDateRangeSelector();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummarySection() {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedGradientContainer(
          colors: [
            themeOption.primary,
            themeOption.accent,
          ],
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Text(
            '📊 Özet İstatistikler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPremiumSummaryCard(
                icon: Icons.check_circle_rounded,
                title: 'Tamamlanan',
                subtitle: 'Görev',
                value: '$_totalCompletedTasks',
                gradient: [Colors.green[400]!, Colors.green[600]!],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPremiumSummaryCard(
                icon: Icons.local_fire_department_rounded,
                title: 'Gün',
                subtitle: 'Serisi',
                value: '$_streakDays',
                gradient: [Colors.orange[400]!, Colors.orange[600]!],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPremiumSummaryCard(
                icon: Icons.star_rounded,
                title: 'Toplam',
                subtitle: 'Puan',
                value: '$_totalPoints',
                gradient: [Colors.purple[400]!, Colors.purple[600]!],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPremiumSummaryCard(
                icon: Icons.access_time_rounded,
                title: 'Günlük Ort.',
                subtitle: 'Süre',
                value: '${_averageTimePerDay.toInt()} dk',
                gradient: [Colors.blue[400]!, Colors.blue[600]!],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumSummaryCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<Color> gradient,
  }) {
    return GlassmorphismContainer(
      padding: const EdgeInsets.all(16.0),
      borderRadius: 16,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ShimmerEffect(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: gradient[1],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartSection() {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedGradientContainer(
          colors: [
            themeOption.primary,
            themeOption.accent,
          ],
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Text(
            '🍕 Görev Dağılımı',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassmorphismContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: 20,
          child: Column(
            children: [
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                    sections: _getCategorySections(),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildCategoryLegend(),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _getCategorySections() {
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blueAccent,    // Mutfak
      Colors.redAccent,     // Banyo
      Colors.greenAccent,   // Genel
      Colors.purpleAccent,  // Özel
    ];
    
    int index = 0;
    _categoryDistribution.forEach((key, value) {
      sections.add(
        PieChartSectionData(
          color: colors[index % colors.length],
          value: value,
          title: '${value.toStringAsFixed(0)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      index++;
    });
    
    return sections;
  }

  Widget _buildCategoryLegend() {
    final List<Color> colors = [
      Colors.blueAccent,    // Mutfak
      Colors.redAccent,     // Banyo
      Colors.greenAccent,   // Genel
      Colors.purpleAccent,  // Özel
    ];
    
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem('Mutfak', colors[0]),
        _buildLegendItem('Banyo', colors[1]),
        _buildLegendItem('Genel', colors[2]),
        _buildLegendItem('Özel', colors[3]),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
        Text(title),
      ],
    );
  }

  Widget _buildWeeklyActivitySection() {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedGradientContainer(
          colors: [
            themeOption.primary,
            themeOption.accent,
          ],
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Text(
            '📈 Haftalık Aktivite',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassmorphismContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: 20,
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxCompletedTasksByDay() * 1.2,
                    barGroups: _getBarGroups(),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 1,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.grey[300],
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const SizedBox();
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final weekDays = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];
                            if (value >= 0 && value < weekDays.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  weekDays[value.toInt()],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Son 7 günde tamamlanan görevler',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _getMaxCompletedTasksByDay() {
    double max = 0;
    for (var count in _completedTasksByDay.values) {
      if (count > max) max = count.toDouble();
    }
    return max == 0 ? 5 : max; // En az 5 göster
  }

  List<BarChartGroupData> _getBarGroups() {
    final List<BarChartGroupData> barGroups = [];
    final List<String> weekDays = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    
    for (int i = 0; i < weekDays.length; i++) {
      final value = _completedTasksByDay[weekDays[i]] ?? 0;
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value.toDouble(),
              color: AppTheme.primaryColor,
              width: 20,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: _getMaxCompletedTasksByDay(),
                color: Colors.grey[200],
              ),
            ),
          ],
        ),
      );
    }
    
    return barGroups;
  }

  Widget _buildHabitsSection() {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedGradientContainer(
          colors: [
            themeOption.primary,
            themeOption.accent,
          ],
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Text(
            '✨ Alışkanlıklar ve Başarımlar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassmorphismContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: 20,
          child: Column(
            children: [
              _buildHabitProgressIndicator(
                title: 'Temizlik düzeni',
                subtitle: 'Her gün en az bir görev tamamla',
                progress: _streakDays / 30,
                value: '$_streakDays/30 gün',
              ),
              const SizedBox(height: 24),
              _buildHabitProgressIndicator(
                title: 'Temizlik uzmanı',
                subtitle: 'En az 100 görev tamamla',
                progress: _totalCompletedTasks / 100,
                value: '$_totalCompletedTasks/100 görev',
              ),
              const SizedBox(height: 24),
              _buildHabitProgressIndicator(
                title: 'Puan avcısı',
                subtitle: '1000 puan kazan',
                progress: _totalPoints / 1000,
                value: '$_totalPoints/1000 puan',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHabitProgressIndicator({
    required String title,
    required String subtitle,
    required double progress,
    required String value,
  }) {
    final themeOption = AppTheme.instance.currentThemeOption;
    // 0 ile 1 arasına sınırla
    progress = progress.clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.instance.isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            ShimmerEffect(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeOption.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Flexible(
                flex: (progress * 100).toInt(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        themeOption.primary,
                        themeOption.accent,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Flexible(
                flex: ((1 - progress) * 100).toInt(),
                child: Container(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDateRangeSelector() {
    // Bu özellik henüz aktif değil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu özellik henüz geliştirme aşamasındadır.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}