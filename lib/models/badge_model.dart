import 'package:hive/hive.dart';

part 'badge_model.g.dart';

@HiveType(typeId: 4)
class Badge {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  @HiveField(3)
  final String imagePath;
  
  @HiveField(4)
  final int requiredTaskCount;
  
  @HiveField(5)
  final String unlockCondition;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.requiredTaskCount,
    required this.unlockCondition,
  });

  static List<Badge> getDefaultBadges() {
    return [
      Badge(
        id: 'first_task',
        name: 'İlk Görev',
        description: 'İlk görevinizi tamamladınız!',
        imagePath: 'assets/badges/first_task.png',
        requiredTaskCount: 1,
        unlockCondition: 'İlk görevinizi tamamlayın',
      ),
      Badge(
        id: 'week_champion',
        name: 'Hafta Şampiyonu',
        description: 'Bir hafta boyunca her gün en az bir görev tamamladınız!',
        imagePath: 'assets/badges/week_champion.png',
        requiredTaskCount: 7,
        unlockCondition: 'Bir haftada her gün en az bir görev tamamlayın',
      ),
      Badge(
        id: 'kitchen_master',
        name: 'Mutfak Ustası',
        description: 'Mutfak kategorisinde 10 görev tamamladınız!',
        imagePath: 'assets/badges/kitchen_master.png',
        requiredTaskCount: 10,
        unlockCondition: 'Mutfak kategorisinde 10 görev tamamlayın',
      ),
      Badge(
        id: 'bathroom_hero',
        name: 'Banyo Kahramanı',
        description: 'Banyo kategorisinde 10 görev tamamladınız!',
        imagePath: 'assets/badges/bathroom_hero.png',
        requiredTaskCount: 10,
        unlockCondition: 'Banyo kategorisinde 10 görev tamamlayın',
      ),
      Badge(
        id: 'cleaning_expert',
        name: 'Temizlik Uzmanı',
        description: 'Toplam 50 görev tamamladınız!',
        imagePath: 'assets/badges/cleaning_expert.png',
        requiredTaskCount: 50,
        unlockCondition: 'Toplam 50 görev tamamlayın',
      ),
    ];
  }
}
