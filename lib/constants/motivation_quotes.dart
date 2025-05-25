import 'dart:math';

enum QuoteCategory {
  daily,
  cleaning,
  habit,
  success,
  mindfulness,
}

class Quote {
  final String id;
  final String text;
  final QuoteCategory category;
  final String? author;
  final bool isPremium;

  Quote({
    String? id,
    required this.text,
    required this.category,
    this.author,
    this.isPremium = false,
  }) : this.id = id ?? _generateId(text, category);

  static String _generateId(String text, QuoteCategory category) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${category.name}_${text.length}_$timestamp';
  }
}

class MotivationQuotes {
  static final List<Quote> quotes = [
    // Günlük Motivasyon
    Quote(
      text: 'Temiz bir ev, huzurlu bir zihin demektir!',
      category: QuoteCategory.daily,
    ),
    Quote(
      text: 'Her yeni gün, taze bir başlangıçtır.',
      category: QuoteCategory.daily,
      author: 'Anonim',
    ),
    
    // Temizlik Motivasyonu
    Quote(
      text: 'Temizlik, kendi kendine hediye vermek gibidir.',
      category: QuoteCategory.cleaning,
    ),
    Quote(
      text: 'Düzenli bir ev, düzenli bir hayatın ilk adımıdır.',
      category: QuoteCategory.cleaning,
    ),
    
    // Alışkanlık Oluşturma
    Quote(
      text: 'Bir şeyi 21 gün boyunca yaparsanız, bu bir alışkanlık haline gelir.',
      category: QuoteCategory.habit,
      author: 'Dr. Maxwell Maltz',
    ),
    Quote(
      text: 'Her gün küçük bir görev, büyük bir fark yaratır.',
      category: QuoteCategory.habit,
    ),
    
    // Başarı Motivasyonu
    Quote(
      text: 'Her küçük görev, büyük bir başarıya giden adımdır.',
      category: QuoteCategory.success,
    ),
    Quote(
      text: 'Bugün yaptığınız her görev, yarın için teşekkür edeceğiniz bir şeydir.',
      category: QuoteCategory.success,
    ),
    
    // Bilinçli Yaşam
    Quote(
      text: 'Ev temizliği, kendine gösterdiğin özendir.',
      category: QuoteCategory.mindfulness,
    ),
    Quote(
      text: 'Temiz bir çevre, temiz bir zihin yaratır.',
      category: QuoteCategory.mindfulness,
      isPremium: true,
    ),
  ];

  static Quote getRandomQuote({QuoteCategory? category, bool includePremium = false}) {
    final availableQuotes = quotes.where((quote) {
      if (!includePremium && quote.isPremium) return false;
      if (category != null && quote.category != category) return false;
      return true;
    }).toList();

    if (availableQuotes.isEmpty) {
      return quotes.first; // Varsayılan alıntıyı döndür
    }

    final random = Random();
    return availableQuotes[random.nextInt(availableQuotes.length)];
  }

  static List<Quote> getQuotesByCategory(QuoteCategory category, {bool includePremium = false}) {
    return quotes.where((quote) => 
      quote.category == category && 
      (includePremium || !quote.isPremium)
    ).toList();
  }

  static int getTotalQuoteCount({bool includePremium = false}) {
    return quotes.where((quote) => includePremium || !quote.isPremium).length;
  }
}
