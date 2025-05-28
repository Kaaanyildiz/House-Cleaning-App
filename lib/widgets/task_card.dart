import 'package:flutter/material.dart';
import 'package:house_cleaning/models/task_model.dart';
import 'package:house_cleaning/widgets/premium_effects.dart';
import 'package:house_cleaning/constants/app_theme.dart';

/// Bu widget, koyu tema için optimize edilmiş bir görev kartı oluşturur
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  
  const TaskCard({
    Key? key, 
    required this.task, 
    this.onTap, 
    this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Temayı kontrol et
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final themeOption = AppTheme.instance.currentThemeOption;
    
    // İkon rengini ve arka plan rengini ayarla
    final iconBgColors = task.isCompleted 
      ? [const Color(0xFF10B981), const Color(0xFF34D399)]
      : isDarkMode
        ? [themeOption.primary.withOpacity(0.6), themeOption.accent.withOpacity(0.4)]
        : [themeOption.primary.withOpacity(0.8), themeOption.accent.withOpacity(0.6)];
    
    final textColor = task.isCompleted 
      ? Colors.grey[500] 
      : isDarkMode
        ? Colors.white
        : const Color(0xFF1E293B);
    
    final descriptionTextColor = isDarkMode
      ? Colors.grey[300]
      : Colors.grey[700];
    
    final iconColor = Colors.white;
    
    final cardBgColor = isDarkMode
      ? Colors.grey[900]!.withOpacity(0.5)
      : Colors.white.withOpacity(0.7);
      
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassmorphismContainer(
        padding: const EdgeInsets.all(20),
        color: cardBgColor,
        borderRadius: 20,
        child: Row(
          children: [
            // Görev İkonu
            NeumorphismContainer(
              width: 50,
              height: 50,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: iconBgColors,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  IconData(
                    task.iconCode,
                    fontFamily: 'MaterialIcons',
                  ),
                  color: iconColor,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Görev Bilgileri
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
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${task.estimatedMinutes} dakika',
                        style: TextStyle(
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Tamamlanma Düğmesi
            NeumorphismContainer(
              width: 40,
              height: 40,
              onTap: onComplete,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: task.isCompleted 
                      ? const [Color(0xFF10B981), Color(0xFF34D399)]
                      : isDarkMode
                        ? [Colors.grey[700]!, Colors.grey[800]!]
                        : [Colors.grey[300]!, Colors.grey[400]!],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  task.isCompleted 
                    ? Icons.check_rounded 
                    : Icons.radio_button_unchecked_rounded,
                  color: task.isCompleted 
                    ? Colors.white 
                    : isDarkMode
                      ? Colors.white
                      : Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Zorluk seviyesine göre rengi döndürür
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
  
  // Zorluk seviyesine göre ikonu döndürür
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
}
