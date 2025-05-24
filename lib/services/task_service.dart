import 'package:flutter/material.dart';
import 'package:house_cleaning/models/task_model.dart';

class TaskService {
  // Örnek görevleri getir
  static List<Task> getSampleTasks() {
    return [
      Task(
        id: '1',
        title: 'Bulaşık Yıkama',
        description: 'Tüm bulaşıkları yıkayıp yerleştirin',
        category: TaskCategory.kitchen,
        difficulty: TaskDifficulty.easy,
        iconCode: Icons.wash.codePoint,
        estimatedMinutes: 15,
      ),
      Task(
        id: '2',
        title: 'Ocak Temizleme',
        description: 'Ocağı ve fırını temizleyin',
        category: TaskCategory.kitchen,
        difficulty: TaskDifficulty.medium,
        iconCode: Icons.countertops.codePoint,
        estimatedMinutes: 20,
      ),
      Task(
        id: '3',
        title: 'Buzdolabı Düzenleme',
        description: 'Buzdolabını düzenleyip temizleyin',
        category: TaskCategory.kitchen,
        difficulty: TaskDifficulty.medium,
        iconCode: Icons.kitchen.codePoint,
        estimatedMinutes: 25,
      ),
      Task(
        id: '4',
        title: 'Banyo Temizliği',
        description: 'Banyonun genel temizliği ve dezenfeksiyonu',
        category: TaskCategory.bathroom,
        difficulty: TaskDifficulty.hard,
        iconCode: Icons.bathroom.codePoint,
        estimatedMinutes: 30,
      ),
      Task(
        id: '5',
        title: 'Duş/Küvet Temizliği',
        description: 'Duş veya küvetin derinlemesine temizliği',
        category: TaskCategory.bathroom,
        difficulty: TaskDifficulty.medium,
        iconCode: Icons.bathtub.codePoint,
        estimatedMinutes: 20,
      ),
      Task(
        id: '6',
        title: 'Toz Alma',
        description: 'Tüm yüzeylerin tozunu alın',
        category: TaskCategory.general,
        difficulty: TaskDifficulty.easy,
        iconCode: Icons.cleaning_services.codePoint,
        estimatedMinutes: 15,
      ),
      Task(
        id: '7',
        title: 'Yerleri Süpürme',
        description: 'Tüm odaların yerleri süpürülecek',
        category: TaskCategory.general,
        difficulty: TaskDifficulty.easy,
        iconCode: Icons.cleaning_services_outlined.codePoint,
        estimatedMinutes: 15,
      ),
      Task(
        id: '8',
        title: 'Yerleri Silme',
        description: 'Tüm odaların yerleri nemli olarak paspaslanacak',
        category: TaskCategory.general,
        difficulty: TaskDifficulty.medium,
        iconCode: Icons.cleaning_services.codePoint,
        estimatedMinutes: 25,
      ),
      Task(
        id: '9',
        title: 'Çamaşır Yıkama',
        description: 'Çamaşırları toplayıp yıkayın',
        category: TaskCategory.general,
        difficulty: TaskDifficulty.medium,
        iconCode: Icons.local_laundry_service.codePoint,
        estimatedMinutes: 40,
      ),
      Task(
        id: '10',
        title: 'Pencere Temizliği',
        description: 'Tüm pencereleri içten ve dıştan temizleyin',
        category: TaskCategory.special,
        difficulty: TaskDifficulty.hard,
        iconCode: Icons.window.codePoint,
        estimatedMinutes: 45,
      ),
    ];
  }

  // Bugün için planlanmış görevleri getir
  static List<Task> getTodayTasks() {
    final today = DateTime.now();
    final tasks = getSampleTasks();
    
    // Örnekte rastgele 3 görevi bugün için planla
    tasks.shuffle();
    final selectedTasks = tasks.take(4).toList();
    
    // Görevlere bugün için vade tarihi ekle
    for (var i = 0; i < selectedTasks.length; i++) {
      selectedTasks[i] = selectedTasks[i].copyWith(dueDate: today);
    }
    
    return selectedTasks;
  }
  
  // Belirli bir kategorideki görevleri getir
  static List<Task> getTasksByCategory(TaskCategory category) {
    final tasks = getSampleTasks();
    return tasks.where((task) => task.category == category).toList();
  }
  
  // Haftalık görevleri getir
  static Map<int, List<Task>> getWeeklyTasks() {
    final Map<int, List<Task>> weeklyTasks = {};
    final tasks = getSampleTasks();
    final today = DateTime.now();
    
    for (var i = 0; i < 7; i++) {
      final day = today.add(Duration(days: i));
      // Her gün için rastgele 0-3 görev seç
      tasks.shuffle();
      final count = i == 6 ? 0 : (1 + (i % 3)); // Pazar günü 0, diğer günler 1-3
      
      final selectedTasks = tasks.take(count).map((task) {
        return task.copyWith(dueDate: day);
      }).toList();
      
      weeklyTasks[i] = selectedTasks;
    }
    
    return weeklyTasks;
  }
}
