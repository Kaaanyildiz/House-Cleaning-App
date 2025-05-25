import 'package:flutter/material.dart';
import '../constants/motivation_quotes.dart';
import '../constants/app_theme.dart';

class MotivationCard extends StatelessWidget {
  final Quote quote;
  final VoidCallback? onTap;
  final bool showCategory;

  const MotivationCard({
    Key? key,
    required this.quote,
    this.onTap,
    this.showCategory = true,
  }) : super(key: key);

  String _getCategoryEmoji(QuoteCategory category) {
    switch (category) {
      case QuoteCategory.daily:
        return '🌟';
      case QuoteCategory.cleaning:
        return '🧹';
      case QuoteCategory.habit:
        return '⭐';
      case QuoteCategory.success:
        return '🎯';
      case QuoteCategory.mindfulness:
        return '🍃';
    }
  }  @override
  Widget build(BuildContext context) {
    final themeOption = AppTheme.instance.currentThemeOption;    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeOption.primary.withOpacity(0.8),
            themeOption.accent.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: themeOption.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),          child: Container(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (showCategory)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getCategoryEmoji(quote.category),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getCategoryDisplayName(quote.category),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    if (quote.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.amber.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.amber,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Premium',
                              style: TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),                const SizedBox(height: 12),
                Icon(
                  Icons.format_quote,
                  color: Colors.white.withOpacity(0.3),
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  quote.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    letterSpacing: 0.1,
                  ),
                  textAlign: TextAlign.left,
                ),
                if (quote.author != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 1,
                        width: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        quote.author!,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),                ],
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh,
                          color: Colors.white.withOpacity(0.9),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Yeni Alıntı',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCategoryDisplayName(QuoteCategory category) {
    switch (category) {
      case QuoteCategory.daily:
        return 'GÜNLÜK';
      case QuoteCategory.cleaning:
        return 'TEMİZLİK';
      case QuoteCategory.habit:
        return 'ALIŞKANLIK';
      case QuoteCategory.success:
        return 'BAŞARI';
      case QuoteCategory.mindfulness:
        return 'DİKKAT';
    }
  }
}
