import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:house_cleaning/models/user_model.dart';
import 'package:house_cleaning/models/task_model.dart';
import 'package:house_cleaning/models/badge_model.dart' as app_badge;
import 'package:house_cleaning/services/task_service.dart';
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:house_cleaning/services/notification_service.dart';

class UserProvider extends ChangeNotifier {
  // Hive kutuları
  late Box<User> _userBox;
  late Box<Task> _taskBox;
  late Box<app_badge.Badge> _badgeBox;
  Box? _settingsBox; // Nullable olarak değiştirildi

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

    try {
      _userBox = await Hive.openBox<User>('users');
      _taskBox = await Hive.openBox<Task>('tasks');
      _badgeBox = await Hive.openBox<app_badge.Badge>('badges');
      _settingsBox = await Hive.openBox('settings');
      
      // Badge kutusunu kullanarak örnek rozetleri yükle (boş kutu kontrolü)
      if (_badgeBox.isEmpty) {
        _badgeBox.addAll(app_badge.Badge.getDefaultBadges());
      }
      
      await _loadData();
      
      // Ayarları yükle ve uygula
      _loadSettings();

      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Hive başlatma hatası: $e');
      // Temel özellikleri çalıştırmaya devam et
      _isLoaded = true;
      notifyListeners();
    }
  }
  
  // Verileri Hive'dan yükle
  Future<void> _loadData() async {
    try {
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
    } catch (e) {
      debugPrint('Veri yükleme hatası: $e');
    }
  }
  
  // Verileri Hive'a kaydet
  void _saveData() {
    try {
      // Kullanıcı verilerini kaydet
      _userBox.putAt(0, _currentUser);
      
      // Görev verilerini kaydet
      _taskBox.clear();
      _taskBox.addAll(_allTasks);
    } catch (e) {
      debugPrint('Veri kaydetme hatası: $e');
    }
  }

  // Getters
  User get currentUser => _currentUser;
  List<Task> get allTasks => _allTasks;
  List<Task> get todayTasks => _todayTasks;
  
  // Bildirim sıklığını getir - şimdi null güvenli
  String get reminderFrequency => _settingsBox?.get('reminderFrequency', defaultValue: 'daily') ?? 'daily';
  
  // Tamamlanan görev sayısı
  int get completedTasksCount => _todayTasks.where((task) => task.isCompleted).length;
  
  // Bu hafta tamamlanan görev sayısı
  int get weeklyCompletedTasks {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    int count = 0;
    for (var date in _currentUser.completedTasks.keys) {
      if (date.isAfter(startOfWeek.subtract(const Duration(days: 1))) && 
          date.isBefore(endOfWeek.add(const Duration(days: 1)))) {
        count += _currentUser.completedTasks[date]?.length ?? 0;
      }
    }
    return count;
  }
  
  // Mevcut seri (gün sayısı)
  int get currentStreak {
    final now = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 30; i++) { // Son 30 günü kontrol et
      final date = DateTime(
        now.year,
        now.month,
        now.day - i,
      );
      
      if (_currentUser.completedTasks.containsKey(date) && 
          _currentUser.completedTasks[date]!.isNotEmpty) {
        streak++;
      } else {
        break; // Seri bozuldu
      }
    }
    
    return streak;
  }

  // Bugünkü ilerleme yüzdesi
  double get todayProgress => _todayTasks.isEmpty 
    ? 0.0 
    : completedTasksCount / _todayTasks.length;
  
  // Görev yönetimi metodları
  void completeTask(Task task) {
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
  
  void deleteTask(String taskId) {
    _allTasks.removeWhere((task) => task.id == taskId);
    _todayTasks.removeWhere((task) => task.id == taskId);
    
    // Verileri kaydet
    _saveData();
    
    notifyListeners();
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

  // Kullanıcı verilerini güncelle
  void addPoints(int points) {
    _currentUser.addPoints(points);
    _saveData();
    notifyListeners();
  }
  void addBadge(String badge) {
    _currentUser.addBadge(badge);
    _saveData();
    notifyListeners();
  }
  
  // Meydan okuma tamamlandı
  void completeChallenge() {
    _currentUser.completeChallenge();
    _saveData();
    notifyListeners();
  }

  // Rozet kontrolü
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
      var task = _allTasks.firstWhere(
        (t) => t.id == taskId,
        orElse: () => _allTasks.isEmpty 
          ? Task(
              id: '0',
              title: 'Boş Görev',
              description: '',
              category: TaskCategory.general,
              difficulty: TaskDifficulty.easy,
              iconCode: Icons.help.codePoint,
              estimatedMinutes: 0
            )
          : _allTasks.first
      );
      
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
      var task = _allTasks.firstWhere(
        (t) => t.id == taskId,
        orElse: () => _allTasks.isEmpty 
          ? Task(
              id: '0',
              title: 'Boş Görev',
              description: '',
              category: TaskCategory.general,
              difficulty: TaskDifficulty.easy,
              iconCode: Icons.help.codePoint,
              estimatedMinutes: 0
            )
          : _allTasks.first
      );
      
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
      notifyListeners();
    }
  }

  // Kullanıcı ayarlarını yükle ve uygula - null güvenli
  void _loadSettings() {
    if (_settingsBox == null) return;
    
    try {
      final isDarkMode = _settingsBox?.get('isDarkMode', defaultValue: false) ?? false;
      final themeIndex = _settingsBox?.get('themeIndex', defaultValue: 0) ?? 0;
      
      // Tema ayarlarını uygula
      if (themeIndex >= 0 && themeIndex < AppTheme.themeOptions.length) {
        AppTheme.instance.setThemeOption(AppTheme.themeOptions[themeIndex]);
      }
      
      AppTheme.instance.setDarkMode(isDarkMode);
    } catch (e) {
      debugPrint('Ayarları yükleme hatası: $e');
    }
  }
  // Kullanıcı ayarlarını kaydet - null güvenli
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      // Ayarları Hive'a kaydet
      if (_settingsBox != null) {
        await _settingsBox!.putAll(settings);
      }
      
      // Tema ayarlarını uygula - doğrudan AppTheme üzerinde değişiklik yap
      if (settings.containsKey('isDarkMode')) {
        AppTheme.instance.setDarkMode(settings['isDarkMode']);
      }
      
      if (settings.containsKey('themeIndex')) {
        final themeIndex = settings['themeIndex'];
        if (themeIndex >= 0 && themeIndex < AppTheme.themeOptions.length) {
          AppTheme.instance.setThemeOption(AppTheme.themeOptions[themeIndex]);
        }
      }
    } catch (e) {
      debugPrint('Ayarları kaydetme hatası: $e');
    }
    
    notifyListeners();
  }

  // Bildirim ayarlarını kaydet
  Future<void> saveNotificationSettings({
    required bool notificationsEnabled,
    bool? soundEnabled,
    String? reminderFrequency,
  }) async {
    final settings = <String, dynamic>{
      'notificationsEnabled': notificationsEnabled,
    };
    
    if (soundEnabled != null) {
      settings['soundEffectsEnabled'] = soundEnabled;
    }
    
    if (reminderFrequency != null) {
      settings['reminderFrequency'] = reminderFrequency;
    }
    
    await saveSettings(settings);
    
    try {
      if (notificationsEnabled) {
        // Varsayılan bildirimleri etkinleştir
        await _scheduleDefaultNotifications();
      } else {
        // Tüm bildirimleri iptal et
        await _cancelAllNotifications();
      }
    } catch (e) {
      debugPrint('Bildirimleri ayarlama hatası: $e');
    }
  }
    
  // Varsayılan bildirimleri zamanla - null güvenli
  Future<void> _scheduleDefaultNotifications() async {
    try {
      final reminderFrequency = _settingsBox?.get('reminderFrequency', defaultValue: 'daily') ?? 'daily';
      
      // Tüm sıklık ayarları için günlük motivasyon bildirimi (sabah 9'da)
      await NotificationService.instance.scheduleDailyNotification(
        id: 1,
        title: 'Günün Motivasyonu',
        body: 'Bugünkü motivasyon sözünüzü görüntülemek için tıklayın!',
        scheduledTime: const TimeOfDay(hour: 9, minute: 0),
      );
      
      // Bildirim sıklığına göre görev hatırlatıcıları
      switch (reminderFrequency) {
        case 'hourly':
          // Her saat başı bildirim (9:00 - 21:00 arası)
          for (int i = 9; i <= 21; i++) {
            await NotificationService.instance.scheduleDailyNotification(
              id: 100 + i,
              title: 'Saatlik Hatırlatıcı',
              body: 'Görevlerinizi kontrol etmeyi unutmayın!',
              scheduledTime: TimeOfDay(hour: i, minute: 0),
            );
          }
          break;
          
        case 'frequent':
          // Günde 3 kez bildirim (sabah, öğle, akşam)
          await NotificationService.instance.scheduleDailyNotification(
            id: 2,
            title: 'Sabah Hatırlatıcısı',
            body: 'Bugünkü görevlerinizi planlamak için harika bir zaman!',
            scheduledTime: const TimeOfDay(hour: 10, minute: 0),
          );
          
          await NotificationService.instance.scheduleDailyNotification(
            id: 3,
            title: 'Öğle Hatırlatıcısı',
            body: 'Bugünkü görevlerinizin yarısını tamamladınız mı?',
            scheduledTime: const TimeOfDay(hour: 14, minute: 0),
          );
          
          await NotificationService.instance.scheduleDailyNotification(
            id: 4,
            title: 'Akşam Hatırlatıcısı',
            body: 'Gününüzü tamamlamadan önce yapılacak görevlerinizi kontrol edin!',
            scheduledTime: const TimeOfDay(hour: 18, minute: 0),
          );
          break;
          
        case 'daily':
          // Günde tek bildirim (öğleden sonra 2'de)
          await NotificationService.instance.scheduleDailyNotification(
            id: 2,
            title: 'Günlük Görev Hatırlatıcısı',
            body: 'Bugünkü görevleriniz sizi bekliyor. İlerlemenizi kontrol edin!',
            scheduledTime: const TimeOfDay(hour: 14, minute: 0),
          );
          break;
          
        case 'important_only':
          // Sadece önemli görevler için bildirim (öncelik yüksek görevler)
          await NotificationService.instance.scheduleDailyNotification(
            id: 2,
            title: 'Önemli Görevler',
            body: 'Bugün için önemli görevlerinizi kontrol etmeyi unutmayın!',
            scheduledTime: const TimeOfDay(hour: 10, minute: 0),
          );
          break;
      }
    } catch (e) {
      debugPrint('Bildirimleri zamanlama hatası: $e');
    }
  }
  
  // Tüm bildirimleri iptal et
  Future<void> _cancelAllNotifications() async {
    try {
      await NotificationService.instance.cancelAllNotifications();
    } catch (e) {
      debugPrint('Bildirimleri iptal etme hatası: $e');
    }
  }

  // Belirli bir tarih için görevleri getir
  List<Task> getTasksForDate(DateTime date) {
    // Tarih karşılaştırması için sadece yıl, ay, gün gerekiyor
    final compareDate = DateTime(date.year, date.month, date.day);
    
    // Tüm görevler içinden bu tarihe ait olanları filtrele
    return _allTasks.where((task) {
      if (task.dueDate == null) return false;
      
      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );
      
      return taskDate.isAtSameMomentAs(compareDate);
    }).toList();
  }
  
  // Belirli bir haftadaki görevleri tarihlere göre gruplayarak getir
  Map<DateTime, List<Task>> getWeeklyTasks(DateTime weekStartDate) {
    final Map<DateTime, List<Task>> weeklyTasks = {};
    
    // Haftanın her günü için
    for (int i = 0; i < 7; i++) {
      final currentDate = weekStartDate.add(Duration(days: i));
      final tasksForDay = getTasksForDate(currentDate);
      weeklyTasks[currentDate] = tasksForDay;
    }
    
    return weeklyTasks;
  }
  
  // Belirli bir haftada her gün için görev sayısını getir
  Map<int, int> getTaskCountByWeekday(DateTime weekStartDate) {
    final weeklyTasks = getWeeklyTasks(weekStartDate);
    final Map<int, int> counts = {};
    
    for (int i = 0; i < 7; i++) {
      final date = weekStartDate.add(Duration(days: i));
      final tasksForDay = weeklyTasks[date] ?? [];
      counts[i] = tasksForDay.length;
    }
    
    return counts;
  }

  // Premium durumunu kontrol et - null güvenli
  bool get isPremium => _settingsBox?.get('isPremium', defaultValue: false) ?? false;
  
  // Premium durumunu güncelle - null güvenli
  Future<void> setPremiumStatus(bool isPremium) async {
    try {
      if (_settingsBox != null) {
        await _settingsBox!.put('isPremium', isPremium);
      }
    } catch (e) {
      debugPrint('Premium durumu ayarlama hatası: $e');
    }
    notifyListeners();
  }

  // Premium alıntıları gösterme durumunu kontrol et - null güvenli
  bool get showPremiumQuotes => isPremium || (_settingsBox?.get('showPremiumQuotes', defaultValue: false) ?? false);
  
  // Premium alıntıları gösterme durumunu güncelle - null güvenli
  Future<void> setShowPremiumQuotes(bool show) async {
    try {
      if (_settingsBox != null) {
        await _settingsBox!.put('showPremiumQuotes', show);
      }
    } catch (e) {
      debugPrint('Premium alıntı ayarları hatası: $e');
    }
    notifyListeners();
  }
  
  // Kullanıcı adını güncelle
  void updateUserName(String name) {
    _currentUser.name = name;
    _saveData();
    notifyListeners();
  }
}
