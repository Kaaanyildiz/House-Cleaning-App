import 'package:hive/hive.dart';
part 'user_model.g.dart';

@HiveType(typeId: 0)
class User {
  @HiveField(0)
  String id;
  
  @HiveField(1)
  String name;
  
  @HiveField(2)
  int points;
  
  @HiveField(3)
  int level;
  
  @HiveField(4)
  List<String> badges;
  
  @HiveField(5)
  Map<DateTime, List<String>> completedTasks; // Tarih ve tamamlanan görev id'leri
  
  @HiveField(6)
  int completedChallengeCount;

  User({
    required this.id,
    required this.name,
    this.points = 0,
    this.level = 1,
    List<String>? badges,
    Map<DateTime, List<String>>? completedTasks,
    this.completedChallengeCount = 0,
  })  : badges = badges ?? [],
        completedTasks = completedTasks ?? {};

  int get totalCompletedTasks {
    int total = 0;
    for (var tasks in completedTasks.values) {
      total += tasks.length;
    }
    return total;
  }

  void addPoints(int points) {
    this.points += points;
    // Her 100 puanda seviye atlama
    level = (this.points / 100).floor() + 1;
  }

  void addBadge(String badge) {
    if (!badges.contains(badge)) {
      badges.add(badge);
    }
  }
  void completeTask(String taskId) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    if (completedTasks.containsKey(today)) {
      completedTasks[today]!.add(taskId);
    } else {
      completedTasks[today] = [taskId];
    }
  }
  
  void completeChallenge() {
    completedChallengeCount++;
  }
}
