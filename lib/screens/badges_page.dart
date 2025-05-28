import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:house_cleaning/models/badge_model.dart' as app_badge;
import 'package:house_cleaning/services/user_provider.dart';

class BadgesPage extends StatefulWidget {
  const BadgesPage({Key? key}) : super(key: key);

  @override
  _BadgesPageState createState() => _BadgesPageState();
}

class _BadgesPageState extends State<BadgesPage> {
  // Tüm rozetleri al
  final List<app_badge.Badge> _allBadges = app_badge.Badge.getDefaultBadges();
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isLoaded) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final user = userProvider.currentUser;
        final unlockedBadgeIds = user.badges;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Rozetler'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              _buildBadgeHeader(unlockedBadgeIds),
              Expanded(
                child: _buildBadgeList(unlockedBadgeIds),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgeHeader(List<String> unlockedBadgeIds) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Rozet ilerleme durumu
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: unlockedBadgeIds.length / _allBadges.length,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${unlockedBadgeIds.length} / ${_allBadges.length} rozet açıldı',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'Rozetler temizlik görevlerini tamamlayarak kazanılır. Her rozet özel bir başarıyı simgeler!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildBadgeList(List<String> unlockedBadgeIds) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _allBadges.length,
      itemBuilder: (context, index) {
        final badge = _allBadges[index];
        final bool isUnlocked = unlockedBadgeIds.contains(badge.id);

        return GestureDetector(
          onTap: () {
            _showBadgeDetails(badge, isUnlocked);
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Rozet resmi
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isUnlocked 
                              ? AppTheme.primaryColor.withOpacity(0.1) 
                              : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: isUnlocked
                            ? Icon(
                                Icons.emoji_events,
                                size: 40,
                                color: Colors.amber[600],
                              )
                            : Icon(
                                Icons.lock,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                      ),
                      if (isUnlocked)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Rozet adı
                  Text(
                    badge.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Rozet durumu
                  Text(
                    isUnlocked ? 'Kazanıldı' : 'Kilitli',
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnlocked ? AppTheme.successColor : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showBadgeDetails(app_badge.Badge badge, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isUnlocked ? Icons.emoji_events : Icons.lock,
              color: isUnlocked ? Colors.amber : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(badge.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Kazanmak için:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isUnlocked ? Icons.check_circle : Icons.info,
                  color: isUnlocked ? AppTheme.successColor : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(badge.unlockCondition),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!isUnlocked)
              Text(
                'İlerleme: 0/${badge.requiredTaskCount}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
