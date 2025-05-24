import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:house_cleaning/models/task_model.dart';
import 'package:house_cleaning/services/user_provider.dart';
import 'package:house_cleaning/services/notification_service.dart';

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
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isLoaded) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final tasks = userProvider.allTasks;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Görevler'),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(Icons.all_inclusive),
                  text: 'Tümü',
                ),
                Tab(
                  icon: Icon(Icons.kitchen),
                  text: 'Mutfak',
                ),
                Tab(
                  icon: Icon(Icons.bathroom),
                  text: 'Banyo',
                ),
                Tab(
                  icon: Icon(Icons.home),
                  text: 'Genel',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tüm görevler
              _buildTaskList(tasks),
              // Mutfak görevleri
              _buildTaskList(_getTasksByCategory(tasks, TaskCategory.kitchen)),
              // Banyo görevleri
              _buildTaskList(_getTasksByCategory(tasks, TaskCategory.bathroom)),
              // Genel görevler
              _buildTaskList(_getTasksByCategory(tasks, TaskCategory.general)),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppTheme.primaryColor,
            onPressed: () {
              _showAddTaskDialog();
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('Bu kategoride görev bulunmuyor.'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: task.isCompleted
                  ? AppTheme.successColor
                  : AppTheme.primaryColor,
              child: Icon(task.icon, color: Colors.white),
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
                fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.bold,
              ),
            ),
            subtitle: Row(
              children: [
                Icon(
                  _getDifficultyIcon(task.difficulty),
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(_getDifficultyText(task.difficulty)),
                const SizedBox(width: 8),
                Text('${task.estimatedMinutes} dk'),
                const SizedBox(width: 8),
                Text('${task.points} puan'),
              ],
            ),
            trailing: task.isCompleted
                ? const Icon(Icons.check_circle, color: AppTheme.successColor)
                : OutlinedButton(
                    onPressed: () {
                      _completeTask(task);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryColor),
                    ),
                    child: const Text('Tamamla'),
                  ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detay:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(task.description),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // Takvime ekle işlevselliği
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Takvime Ekle'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getDifficultyIcon(TaskDifficulty difficulty) {
    switch (difficulty) {
      case TaskDifficulty.easy:
        return Icons.sentiment_satisfied;
      case TaskDifficulty.medium:
        return Icons.sentiment_neutral;
      case TaskDifficulty.hard:
        return Icons.sentiment_very_dissatisfied;
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

  void _completeTask(Task task) {
    // Provider'dan görev tamamlamayı çağır
    Provider.of<UserProvider>(context, listen: false).completeTask(task);

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

  void _showAddTaskDialog() {
    // Task oluşturmak için gereken alanlar
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    TaskCategory selectedCategory = TaskCategory.general;
    TaskDifficulty selectedDifficulty = TaskDifficulty.medium;
    int estimatedMinutes = 15;
    IconData selectedIcon = Icons.home_work;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Yeni Görev Ekle'),
          content: SingleChildScrollView(
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
                        // Kategoriye göre varsayılan icon seç
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
                  // Yeni görev oluştur
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
                  
                  // Provider'a görev ekle
                  Provider.of<UserProvider>(context, listen: false)
                      .addTask(newTask);
                  
                  // Diyaloğu kapat
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
}
