import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:house_cleaning/models/user_model.dart';
import 'package:house_cleaning/models/task_model.dart';
import 'package:house_cleaning/models/badge_model.dart' as app_badge;
import 'package:house_cleaning/services/task_service.dart';

class UserProvider extends ChangeNotifier {
  // Hive kutuları
  late Box<User> _userBox;
  late Box<Task> _taskBox;
  late Box<app_badge.Badge> _badgeBox;

  // Kullanıcı örneği
  User _currentUser = User(
    id: '1',
    name: 'Ev Temizlik Kullanıcısı',
    points: 0,
    level: 1,
    badges: [],
  );

  // Görevler listesi
  List<Task> _allTasks = [];
  List<Task> _todayTasks = [];
  
  // Yükleme durumu
  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;
  
  // Constructor
  UserProvider() {
    _initHive();
  }

  // Hive kutularını yükle
  Future<void> _initHive() async {
    if (_isLoaded) return;

    _userBox = await Hive.openBox<User>('users');
    _taskBox = await Hive.openBox<Task>('tasks');
    _badgeBox = await Hive.openBox<app_badge.Badge>('badges');
    
    // Badge kutusunu kullanarak örnek rozetleri yükle (boş kutu kontrolü)
    if (_badgeBox.isEmpty) {
      _badgeBox.addAll(app_badge.Badge.getDefaultBadges());
    }
    
    await _loadData();
    _isLoaded = true;
    notifyListeners();
  }
  
  // Verileri Hive'dan yükle
  Future<void> _loadData() async {
    // Kullanıcı verilerini yükle
    if (_userBox.isNotEmpty) {
      _currentUser = _userBox.getAt(0)!;
    } else {
      // Varsayılan kullanıcıyı kaydet
      await _userBox.add(_currentUser);
    }
    
    // Görev verilerini yükle
    if (_taskBox.isNotEmpty) {
      _allTasks = _taskBox.values.toList();
    } else {
      // Örnek görevleri yükle
      _allTasks = TaskService.getSampleTasks();
      _taskBox.addAll(_allTasks);
    }
    
    // Bugünkü görevleri belirle
    _updateTodayTasks();
    
    // Rozetleri kontrol et
    _checkForBadges();
  }
  
  // Bugünkü görevleri güncelle
  void _updateTodayTasks() {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    
    _todayTasks = _allTasks.where((task) {
      if (task.dueDate == null) return false;
      
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      
      return taskDate.isAtSameMomentAs(today);
    }).toList();
    
    // Planlanmamış görevleri de ekleyebiliriz
    if (_todayTasks.isEmpty) {
      _todayTasks = TaskService.getTodayTasks();
    }
  }
  
  // Verileri Hive'a kaydet
  void _saveData() {
    // Kullanıcı verilerini kaydet
    _userBox.putAt(0, _currentUser);
    
    // Görev verilerini kaydet
    _taskBox.clear();
    _taskBox.addAll(_allTasks);
  }

  // Getters
  User get currentUser => _currentUser;
  List<Task> get allTasks => _allTasks;
  List<Task> get todayTasks => _todayTasks;
  
  // Tamamlanan görev sayısı
  int get completedTasksCount => _todayTasks.where((task) => task.isCompleted).length;
  
  // Bugünkü ilerleme yüzdesi
  double get todayProgress => _todayTasks.isEmpty 
    ? 0.0 
    : completedTasksCount / _todayTasks.length;
  // Puan ekle
  void addPoints(int points) {
    _currentUser.addPoints(points);
    _saveData();
    notifyListeners();
  }

  // Rozet ekle
  void addBadge(String badge) {
    _currentUser.addBadge(badge);
    _saveData();
    notifyListeners();
  }

  // Görev tamamla
  void completeTask(Task task) {
    // Görevi güncelle
    int index = -1;
    
    // Bugünkü görevler içinde ara
    index = _todayTasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _todayTasks[index] = task.copyWith(isCompleted: true);
    }
    
    // Tüm görevler içinde ara
    index = _allTasks.indexWhere((t) => t.id == task.id);
    if (index >= 0) {
      _allTasks[index] = task.copyWith(isCompleted: true);
    }
    
    // Kullanıcı verilerini güncelle
    _currentUser.completeTask(task.id);
    _currentUser.addPoints(task.points);
    
    // Rozetleri kontrol et
    _checkForBadges();
    
    // Verileri kaydet
    _saveData();
    
    notifyListeners();
  }
    // Yeni görev ekle
  void addTask(Task task) {
    _allTasks.add(task);
    
    if (task.dueDate != null) {
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );
      
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      
      if (taskDate.isAtSameMomentAs(today)) {
        _todayTasks.add(task);
      }
    }
    
    // Verileri kaydet
    _saveData();
    
    notifyListeners();
  }
  
  // Görev güncelleme
  void updateTask(Task task) {
    int index = _allTasks.indexWhere((t) => t.id == task.id);
    
    if (index >= 0) {
      _allTasks[index] = task;
      
      // Bugünkü görevler listesini de güncelle
      int todayIndex = _todayTasks.indexWhere((t) => t.id == task.id);
      if (todayIndex >= 0) {
        _todayTasks[todayIndex] = task;
      }
      
      // Verileri kaydet
      _saveData();
      
      notifyListeners();
    }
  }
  
  // Görev silme
  void deleteTask(String taskId) {
    _allTasks.removeWhere((task) => task.id == taskId);
    _todayTasks.removeWhere((task) => task.id == taskId);
    
    // Verileri kaydet
    _saveData();
    
    notifyListeners();
  }
    // Rozet kazanma koşullarını kontrol et
  void _checkForBadges() {
    bool badgeEarned = false;
    
    // İlk görev rozeti
    if (_currentUser.totalCompletedTasks == 1 && !_currentUser.badges.contains('first_task')) {
      _currentUser.addBadge('first_task');
      badgeEarned = true;
    }
    
    // Mutfak ustası rozeti (10 mutfak görevi)
    int kitchenCount = 0;
    for (var taskId in _currentUser.completedTasks.values.expand((e) => e)) {
      var task = _allTasks.firstWhere((t) => t.id == taskId, orElse: () => _allTasks.isEmpty ? 
          Task(
            id: '0',
            title: 'Boş Görev',
            description: '',
            category: TaskCategory.general,
            difficulty: TaskDifficulty.easy,
            iconCode: Icons.help.codePoint,
            estimatedMinutes: 0
          ) : _allTasks.first);
      
      if (task.category == TaskCategory.kitchen) {
        kitchenCount++;
      }
    }
    
    if (kitchenCount >= 10 && !_currentUser.badges.contains('kitchen_master')) {
      _currentUser.addBadge('kitchen_master');
      badgeEarned = true;
    }
    
    // Banyo kahramanı rozeti (10 banyo görevi)
    int bathroomCount = 0;
    for (var taskId in _currentUser.completedTasks.values.expand((e) => e)) {
      var task = _allTasks.firstWhere((t) => t.id == taskId, orElse: () => _allTasks.isEmpty ? 
          Task(
            id: '0',
            title: 'Boş Görev',
            description: '',
            category: TaskCategory.general,
            difficulty: TaskDifficulty.easy,
            iconCode: Icons.help.codePoint,
            estimatedMinutes: 0
          ) : _allTasks.first);
      
      if (task.category == TaskCategory.bathroom) {
        bathroomCount++;
      }
    }
    
    if (bathroomCount >= 10 && !_currentUser.badges.contains('bathroom_hero')) {
      _currentUser.addBadge('bathroom_hero');
      badgeEarned = true;
    }
    
    // Temizlik uzmanı rozeti (50 görev toplam)
    if (_currentUser.totalCompletedTasks >= 50 && !_currentUser.badges.contains('cleaning_expert')) {
      _currentUser.addBadge('cleaning_expert');
      badgeEarned = true;
    }
    
    // Eğer yeni rozet kazanıldıysa verileri kaydet
    if (badgeEarned) {
      _saveData();
    }
    
    notifyListeners();
  }
}
