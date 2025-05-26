import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:house_cleaning/services/user_provider.dart';
import 'package:house_cleaning/models/task_model.dart';
import 'package:house_cleaning/widgets/premium_effects.dart';

class WeeklyPlannerPage extends StatefulWidget {
  const WeeklyPlannerPage({Key? key}) : super(key: key);

  @override
  _WeeklyPlannerPageState createState() => _WeeklyPlannerPageState();
}

class _WeeklyPlannerPageState extends State<WeeklyPlannerPage> {
  // Haftanın günleri
  final List<String> _weekDays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];
  
  // Şimdiki tarih ve seçili gün
  late DateTime _selectedDate;
  int _selectedDayIndex = 0;
  
  // Günlere göre görev sayısı
  Map<int, int> _taskCountByDay = {};
  
  @override
  void initState() {
    super.initState();
    _selectedDate = _getStartOfWeek(DateTime.now());
    _selectedDayIndex = DateTime.now().weekday - 1; // 0=Pazartesi, 6=Pazar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTaskCounts();
    });
  }
  
  // Görev sayılarını güncelle
  void _updateTaskCounts() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _taskCountByDay = userProvider.getTaskCountByWeekday(_selectedDate);
    });
  }

  // Haftanın başlangıç gününü döndürür (Pazartesi)
  DateTime _getStartOfWeek(DateTime date) {
    int difference = date.weekday - 1;
    return date.subtract(Duration(days: difference));
  }

  @override
  Widget build(BuildContext context) {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isLoaded) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    themeOption.primary.withOpacity(0.1),
                    themeOption.accent.withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShimmerEffect(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [themeOption.primary, themeOption.accent],
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Haftalık Planlayıcı Yükleniyor...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: themeOption.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeOption.primary.withOpacity(0.05),
                  themeOption.accent.withOpacity(0.03),
                  themeOption.secondary.withOpacity(0.02),
                  Colors.white,
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 200,
                      floating: false,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NeumorphismContainer(
                          width: 40,
                          height: 40,
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 18,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: NeumorphismContainer(
                            width: 40,
                            height: 40,
                            onTap: () {
                              // TODO: Add calendar settings
                            },
                            child: Icon(
                              Icons.settings_rounded,
                              size: 20,
                              color: themeOption.primary,
                            ),
                          ),
                        ),
                      ],
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
                            'Haftalık Planlayıcı 📅',
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
                            // Floating calendar icons
                            Positioned(
                              top: 30,
                              right: 30,
                              child: ShimmerEffect(
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  child: Icon(
                                    Icons.calendar_view_week_rounded,
                                    color: Colors.white.withOpacity(0.3),
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 60,
                              left: 40,
                              child: Transform.rotate(
                                angle: -0.2,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Icon(
                                    Icons.event_note_rounded,
                                    color: Colors.white.withOpacity(0.4),
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 40,
                              right: 60,
                              child: Transform.rotate(
                                angle: 0.3,
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Icon(
                                    Icons.schedule_rounded,
                                    color: Colors.white.withOpacity(0.3),
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Premium Week Selector
                      _buildPremiumWeekSelector(),
                      const SizedBox(height: 20),
                      // Premium Day Selector
                      _buildPremiumDaySelector(),
                      const SizedBox(height: 20),
                      // Premium Task List
                      _buildPremiumTaskList(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButtonWithAnimation(
            onPressed: () {
              _showAddTaskDialog();
            },
            child: const Icon(
              Icons.add_rounded,
              size: 28,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumWeekSelector() {
    final themeOption = AppTheme.instance.currentThemeOption;
    final weekEnd = _selectedDate.add(const Duration(days: 6));
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GlassmorphismContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous Week Button
            NeumorphismContainer(
              width: 50,
              height: 50,
              onTap: () {
                setState(() {
                  _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                  _updateTaskCounts();
                });
              },
              child: Icon(
                Icons.chevron_left_rounded,
                color: themeOption.primary,
                size: 24,
              ),
            ),
            // Week Range
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Hafta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [themeOption.primary.withOpacity(0.1), themeOption.accent.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} - ${weekEnd.day} ${_getMonthName(weekEnd.month)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: themeOption.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // Next Week Button
            NeumorphismContainer(
              width: 50,
              height: 50,
              onTap: () {
                setState(() {
                  _selectedDate = _selectedDate.add(const Duration(days: 7));
                  _updateTaskCounts();
                });
              },
              child: Icon(
                Icons.chevron_right_rounded,
                color: themeOption.primary,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumDaySelector() {
    final themeOption = AppTheme.instance.currentThemeOption;
    
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = _selectedDate.add(Duration(days: index));
          final isSelected = _selectedDayIndex == index;
          final isToday = day.year == DateTime.now().year &&
              day.month == DateTime.now().month &&
              day.day == DateTime.now().day;
          final taskCount = _taskCountByDay[index] ?? 0;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },
            child: Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Stack(
                children: [
                  // Main container
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [themeOption.primary, themeOption.accent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [Colors.white, Colors.grey[50]!],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected 
                              ? themeOption.primary.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _weekDays[index].substring(0, 3),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isToday
                                ? (isSelected ? Colors.white.withOpacity(0.2) : themeOption.primary.withOpacity(0.1))
                                : (isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent),
                            borderRadius: BorderRadius.circular(20),
                            border: isToday && !isSelected
                                ? Border.all(color: themeOption.primary, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                        ? themeOption.primary
                                        : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$taskCount görev',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white.withOpacity(0.8) : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Task count indicator
                  if (taskCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : themeOption.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$taskCount',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? themeOption.primary : Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPremiumTaskList() {
    final themeOption = AppTheme.instance.currentThemeOption;
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final selectedDay = _selectedDate.add(Duration(days: _selectedDayIndex));
    final tasksForSelectedDay = userProvider.getTasksForDate(selectedDay);

    if (tasksForSelectedDay.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: GlassmorphismContainer(
          padding: const EdgeInsets.all(40),
          borderRadius: 20,
          child: Column(
            children: [
              ShimmerEffect(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [themeOption.primary.withOpacity(0.1), themeOption.accent.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    Icons.event_note_rounded,
                    size: 60,
                    color: themeOption.primary.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '${_weekDays[_selectedDayIndex]} günü için',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Henüz görev yok',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 16),
              NeumorphismContainer(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                onTap: () {
                  _showAddTaskDialog();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 18,
                      color: themeOption.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Görev Ekle',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: themeOption.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Task count header
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.task_alt_rounded,
                  color: themeOption.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_weekDays[_selectedDayIndex]} Görevleri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [themeOption.primary.withOpacity(0.2), themeOption.accent.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    '${tasksForSelectedDay.length} görev',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: themeOption.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Task list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasksForSelectedDay.length,
            itemBuilder: (context, index) {
              final task = tasksForSelectedDay[index];
              
              String time = "Tüm gün";
              if (task.dueDate != null) {
                final hour = task.dueDate!.hour.toString().padLeft(2, '0');
                final minute = task.dueDate!.minute.toString().padLeft(2, '0');
                time = "$hour:$minute";
              }
              
              IconData icon = IconData(task.iconCode, fontFamily: 'MaterialIcons');

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: GlassmorphismContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 20,
                  child: Row(
                    children: [
                      // Task Icon
                      NeumorphismContainer(
                        width: 60,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: task.isCompleted 
                                  ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                                  : [themeOption.primary.withOpacity(0.8), themeOption.accent.withOpacity(0.6)],
                            ),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            icon,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Task Info
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
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  time,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFF59E0B).withOpacity(0.2),
                                        const Color(0xFFFBBF24).withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 12,
                                        color: Color(0xFFF59E0B),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${task.points}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFF59E0B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Complete Button
                      NeumorphismContainer(
                        width: 50,
                        height: 50,
                        onTap: () {
                          if (!task.isCompleted) {
                            // TODO: Complete task functionality
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: task.isCompleted 
                                ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)])
                                : LinearGradient(colors: [Colors.grey[300]!, Colors.grey[400]!]),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Icon(
                            task.isCompleted ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                            color: task.isCompleted ? Colors.white : Colors.grey[600],
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Görev Ekle'),
        content: const Text('Bu özellik henüz geliştirme aşamasındadır.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    return months[month - 1];
  }
}
