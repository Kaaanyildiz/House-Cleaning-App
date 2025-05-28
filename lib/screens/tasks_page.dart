import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:house_cleaning/models/task_model.dart';
import 'package:house_cleaning/services/user_provider.dart';
import 'package:house_cleaning/services/notification_service.dart';
import 'package:house_cleaning/widgets/premium_effects.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Task> _getTasksByCategory(List<Task> tasks, TaskCategory category) {
    return tasks.where((task) => task.category == category).toList();
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
                          Icons.task_alt_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Görevler Yükleniyor...',
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

        final tasks = userProvider.allTasks;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppTheme.instance.isDark
                  ? [
                      const Color(0xFF1F2937).withOpacity(0.9),
                      const Color(0xFF111827).withOpacity(0.95),
                    ]
                  : [
                      themeOption.primary.withOpacity(0.05),
                      themeOption.accent.withOpacity(0.03),
                      themeOption.secondary.withOpacity(0.02),
                      Colors.white,
                    ],
                stops: AppTheme.instance.isDark 
                  ? [0.0, 1.0]
                  : const [0.0, 0.3, 0.7, 1.0],
              ),
            ),            child: SafeArea(
              child: NestedScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [                    SliverAppBar(
                      expandedHeight: 200,
                      floating: false,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Colors.transparent, 
                      collapsedHeight: 85, // Arttırılmış minimum yükseklik - tab bar ile çakışmaması için
                      leading: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: NeumorphismContainer(
                          width: 40,
                          height: 40,
                          onTap: () => Navigator.pop(context),                          child: Icon(
                            Icons.arrow_back_ios_rounded,
                            size: 18,
                            color: AppTheme.instance.isDark ? Colors.white : const Color(0xFF1E293B),
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
                              // TODO: Task filters/settings
                            },
                            child: Icon(
                              Icons.tune_rounded,
                              size: 20,
                              color: themeOption.primary,
                            ),
                          ),
                        ),
                      ],                      flexibleSpace: FlexibleSpaceBar(
                        title: Container(
                          margin: const EdgeInsets.only(bottom: 26), // Tab bar ile çakışmasın diye boşluk arttırıldı
                          child: AnimatedGradientContainer(
                            colors: [
                              themeOption.primary,
                              themeOption.accent,
                              themeOption.secondary,
                            ],
                            duration: const Duration(seconds: 4),
                            borderRadius: BorderRadius.circular(12),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: const Text(
                              'Görevlerim 📝',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        titlePadding: const EdgeInsets.only(left: 16, bottom: 50), // Tab bar için daha fazla boşluk bırakıldı
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
                            // Floating task icons
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
                                    Icons.task_alt_rounded,
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
                                    Icons.check_circle_outline_rounded,
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
                                    Icons.star_rounded,
                                    color: Colors.white.withOpacity(0.3),
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(60),                        child: Container(                          
                          margin: const EdgeInsets.only(bottom: 10, left: 12, right: 12),
                          height: 48, // Sabit yükseklik eklendi
                          child: GlassmorphismContainer(
                            borderRadius: 25,
                            padding: const EdgeInsets.all(2),
                            child: TabBar(
                              controller: _tabController,
                              isScrollable: false, // Kaydırma devre dışı bırakılıp yayılacak
                              labelPadding: EdgeInsets.zero, // Tab'ların tüm alanı kullanması için sıfırlandı
                              indicator: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [themeOption.primary, themeOption.accent],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab, // Tam tab genişliğini kapsayacak
                              indicatorPadding: EdgeInsets.zero, // İndikatörün kenar boşlukları kaldırıldı
                              labelColor: Colors.white,
                              unselectedLabelColor: const Color(0xFF64748B),
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14, // Font boyutu arttırıldı
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13, // Font boyutu arttırıldı
                              ),                              tabs: const [
                                Tab(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8), 
                                    child: Text('Tümü', maxLines: 1),
                                  ),
                                ),
                                Tab(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8), 
                                    child: Text('Mutfak', maxLines: 1),
                                  ),
                                ),
                                Tab(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8), 
                                    child: Text('Banyo', maxLines: 1),
                                  ),
                                ),
                                Tab(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8), 
                                    child: Text('Genel', maxLines: 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPremiumTaskList(tasks),
                    _buildPremiumTaskList(_getTasksByCategory(tasks, TaskCategory.kitchen)),
                    _buildPremiumTaskList(_getTasksByCategory(tasks, TaskCategory.bathroom)),
                    _buildPremiumTaskList(_getTasksByCategory(tasks, TaskCategory.general)),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButtonWithAnimation(
            onPressed: () {
              _showAddTaskDialog();
            },
            tooltip: 'Yeni Görev Ekle',
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        );
      },
    );
  }

  Widget _buildPremiumTaskList(List<Task> tasks) {
    final themeOption = AppTheme.instance.currentThemeOption;
    final isDarkMode = AppTheme.instance.isDark;
    
    if (tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerEffect(
                baseColor: isDarkMode ? const Color(0xFF303030) : const Color(0xFFE0E0E0),
                highlightColor: isDarkMode ? const Color(0xFF505050) : const Color(0xFFF5F5F5),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDarkMode
                          ? [themeOption.primary.withOpacity(0.3), themeOption.accent.withOpacity(0.2)]
                          : [themeOption.primary.withOpacity(0.1), themeOption.accent.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: Icon(
                    Icons.task_alt_rounded,
                    size: 60,
                    color: isDarkMode
                        ? themeOption.primary.withOpacity(0.4)
                        : themeOption.primary.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),              Text(
                'Bu kategoride görev yok',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.instance.isDark ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Yeni görev eklemek için + butonuna tıklayın',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.instance.isDark ? Colors.grey[300] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: GlassmorphismContainer(
            padding: const EdgeInsets.all(20),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                          IconData(
                            task.iconCode,
                            fontFamily: 'MaterialIcons',
                          ),
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
                        children: [                          Text(
                            task.title,
                            style: TextStyle(
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              // Karanlık modda metin rengi beyaz veya gri, tamamlanmışsa daha soluk
                              color: task.isCompleted 
                                ? Colors.grey[500] 
                                : AppTheme.instance.isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _getDifficultyColor(task.difficulty).withOpacity(0.2),
                                      _getDifficultyColor(task.difficulty).withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getDifficultyIcon(task.difficulty),
                                      size: 14,
                                      color: _getDifficultyColor(task.difficulty),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getDifficultyText(task.difficulty),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: _getDifficultyColor(task.difficulty),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 14,                                    // Karanlık modda ikon rengi daha açık
                                    color: AppTheme.instance.isDark ? Colors.grey[300] : Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${task.estimatedMinutes} dk',
                                    style: TextStyle(
                                      // Karanlık modda metin rengi daha açık
                                      color: AppTheme.instance.isDark ? Colors.grey[300] : Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
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
                          _completeTask(task);
                        }
                      },
                      child: Container(                        decoration: BoxDecoration(
                          gradient: task.isCompleted 
                              ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)])
                              : AppTheme.instance.isDark
                                  ? LinearGradient(colors: [Colors.grey[700]!, Colors.grey[800]!])
                                  : LinearGradient(colors: [Colors.grey[300]!, Colors.grey[400]!]),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Icon(
                          task.isCompleted ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                          color: task.isCompleted 
                              ? Colors.white 
                              : AppTheme.instance.isDark ? Colors.white : Colors.grey[600],
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Task Description
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppTheme.instance.isDark 
                      ? [
                          Colors.grey[800]!.withOpacity(0.6),
                          Colors.grey[900]!.withOpacity(0.3),
                        ]
                      : [
                          themeOption.surface.withOpacity(0.3),
                          themeOption.surface.withOpacity(0.1),
                        ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Açıklama',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          // Başlık rengini tema rengiyle eşleştir, ama karanlık modda daha parlak
                          color: AppTheme.instance.isDark 
                              ? themeOption.primary.withOpacity(0.9)
                              : themeOption.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 14,
                          // Karanlık modda açık gri renk, açık modda koyu gri
                          color: AppTheme.instance.isDark ? Colors.grey[300] : Colors.grey[700],
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Bottom Actions
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFF59E0B).withOpacity(0.2),
                            const Color(0xFFFBBF24).withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${task.points} puan',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (!task.isCompleted)
                      NeumorphismContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        onTap: () {
                          // TODO: Add to calendar functionality
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 16,
                              color: themeOption.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Takvime Ekle',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: themeOption.primary,
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
        );
      },
    );
  }

  void _completeTask(Task task) {
    Provider.of<UserProvider>(context, listen: false).completeTask(task);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${task.title} görevi tamamlandı! +${task.points} puan kazandınız.'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    
    NotificationService.instance.showNotification(
      id: 2,
      title: 'Görev Tamamlandı!',
      body: '${task.title} görevini başarıyla tamamladınız! +${task.points} puan kazandınız.',
    );
  }

  void _showAddTaskDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    TaskCategory selectedCategory = TaskCategory.general;
    TaskDifficulty selectedDifficulty = TaskDifficulty.medium;
    int estimatedMinutes = 15;
    IconData selectedIcon = Icons.home_work;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(          title: const Text('Yeni Görev Ekle'),
          content: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Görev Adı',
                    hintText: 'Örn: Bulaşıkları Yıka',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    hintText: 'Görevin detaylarını yazın',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskCategory>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                  ),
                  items: TaskCategory.values.map((category) {
                    String categoryName = '';
                    IconData categoryIcon;
                    
                    switch (category) {
                      case TaskCategory.kitchen:
                        categoryName = 'Mutfak';
                        categoryIcon = Icons.kitchen;
                        break;
                      case TaskCategory.bathroom:
                        categoryName = 'Banyo';
                        categoryIcon = Icons.bathroom;
                        break;
                      case TaskCategory.general:
                        categoryName = 'Genel';
                        categoryIcon = Icons.home;
                        break;
                      case TaskCategory.special:
                        categoryName = 'Özel';
                        categoryIcon = Icons.star;
                        break;
                    }
                    
                    return DropdownMenuItem<TaskCategory>(
                      value: category,
                      child: Row(
                        children: [
                          Icon(categoryIcon, size: 20),
                          const SizedBox(width: 8),
                          Text(categoryName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedCategory = value;
                        switch (value) {
                          case TaskCategory.kitchen:
                            selectedIcon = Icons.kitchen;
                            break;
                          case TaskCategory.bathroom:
                            selectedIcon = Icons.bathroom;
                            break;
                          case TaskCategory.general:
                            selectedIcon = Icons.home;
                            break;
                          case TaskCategory.special:
                            selectedIcon = Icons.star;
                            break;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TaskDifficulty>(
                  value: selectedDifficulty,
                  decoration: const InputDecoration(
                    labelText: 'Zorluk Seviyesi',
                  ),
                  items: TaskDifficulty.values.map((difficulty) {
                    String difficultyName = '';
                    IconData difficultyIcon;
                    
                    switch (difficulty) {
                      case TaskDifficulty.easy:
                        difficultyName = 'Kolay';
                        difficultyIcon = Icons.sentiment_satisfied;
                        break;
                      case TaskDifficulty.medium:
                        difficultyName = 'Orta';
                        difficultyIcon = Icons.sentiment_neutral;
                        break;
                      case TaskDifficulty.hard:
                        difficultyName = 'Zor';
                        difficultyIcon = Icons.sentiment_very_dissatisfied;
                        break;
                    }
                    
                    return DropdownMenuItem<TaskDifficulty>(
                      value: difficulty,
                      child: Row(
                        children: [
                          Icon(difficultyIcon, size: 20),
                          const SizedBox(width: 8),
                          Text(difficultyName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedDifficulty = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Tahmini Süre: '),
                    Expanded(
                      child: Slider(
                        value: estimatedMinutes.toDouble(),
                        min: 5,
                        max: 60,
                        divisions: 11,
                        label: '$estimatedMinutes dakika',
                        onChanged: (value) {
                          setDialogState(() {
                            estimatedMinutes = value.toInt();
                          });
                        },
                      ),
                    ),
                    Text('$estimatedMinutes dk'),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final newTask = Task(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    description: descriptionController.text.isNotEmpty 
                        ? descriptionController.text 
                        : 'Açıklama yok',
                    category: selectedCategory,
                    difficulty: selectedDifficulty,
                    iconCode: selectedIcon.codePoint,
                    estimatedMinutes: estimatedMinutes,
                  );
                  
                  Provider.of<UserProvider>(context, listen: false)
                      .addTask(newTask);
                  
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return const Color(0xFF10B981);
      case TaskDifficulty.medium:
        return const Color(0xFFF59E0B);
      case TaskDifficulty.hard:
        return const Color(0xFFEF4444);
    }
  }

  IconData _getDifficultyIcon(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return Icons.sentiment_satisfied_rounded;
      case TaskDifficulty.medium:
        return Icons.sentiment_neutral_rounded;
      case TaskDifficulty.hard:
        return Icons.sentiment_very_dissatisfied_rounded;
    }
  }

  String _getDifficultyText(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return 'Kolay';
      case TaskDifficulty.medium:
        return 'Orta';
      case TaskDifficulty.hard:
        return 'Zor';
    }
  }
}
