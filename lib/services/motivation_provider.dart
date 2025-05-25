import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../constants/motivation_quotes.dart';

class MotivationProvider extends ChangeNotifier {
  Box<dynamic>? _settingsBox;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  // Premium durumu artık UserProvider üzerinden kontrol ediliyor
  bool _showPremiumQuotes = false;
  bool get showPremiumQuotes => _showPremiumQuotes;

  // Son gösterilen motivasyon alıntısı
  String? _lastQuoteId;
  DateTime? _lastQuoteDate;

  // Motivasyon tercihleri
  Set<QuoteCategory> _preferredCategories = {
    QuoteCategory.daily,
    QuoteCategory.cleaning,
  };

  // Başlatma sırasında gösterilecek varsayılan alıntı
  Quote get defaultQuote => MotivationQuotes.quotes.first;

  MotivationProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      _settingsBox = await Hive.openBox('motivation_settings');
      await _loadData();
    } catch (e) {
      debugPrint('MotivationProvider init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> _loadData() async {
    if (_settingsBox == null) return;

    try {
      _showPremiumQuotes = _settingsBox?.get('showPremiumQuotes', defaultValue: false) ?? false;
      _lastQuoteId = _settingsBox?.get('lastQuoteId');
      
      final lastQuoteDateStr = _settingsBox?.get('lastQuoteDate');
      if (lastQuoteDateStr != null) {
        _lastQuoteDate = DateTime.parse(lastQuoteDateStr);
      }
      
      final preferredCategoriesStr = _settingsBox?.get('preferredCategories');
      if (preferredCategoriesStr != null) {
        _preferredCategories = Set.from(
          preferredCategoriesStr.split(',').map((e) => QuoteCategory.values.firstWhere(
            (cat) => cat.toString() == e,
            orElse: () => QuoteCategory.daily,
          )),
        );
      }
    } catch (e) {
      debugPrint('MotivationProvider loadData error: $e');
      // Hata durumunda varsayılan değerleri koru
    }
  }
  Future<void> _saveData() async {
    if (_settingsBox == null) return;

    try {
      await _settingsBox?.put('showPremiumQuotes', _showPremiumQuotes);
      if (_lastQuoteId != null) {
        await _settingsBox?.put('lastQuoteId', _lastQuoteId);
      }
      if (_lastQuoteDate != null) {
        await _settingsBox?.put('lastQuoteDate', _lastQuoteDate!.toIso8601String());
      }
      await _settingsBox?.put('preferredCategories', 
        _preferredCategories.map((e) => e.toString()).join(','));
    } catch (e) {
      debugPrint('MotivationProvider saveData error: $e');
    }
  }
  // Premium durumunu güncelle
  void updatePremiumStatus(bool showPremium) {
    _showPremiumQuotes = showPremium;
    _saveData();
    notifyListeners();
  }

  // Motivasyon kategorisi tercihlerini güncelle
  void updatePreferredCategories(Set<QuoteCategory> categories) {
    _preferredCategories = categories;
    _saveData();
    notifyListeners();
  }

  // Günlük alıntı kontrolü
  bool get canShowNewQuote {
    if (_lastQuoteDate == null) return true;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      _lastQuoteDate!.year,
      _lastQuoteDate!.month,
      _lastQuoteDate!.day,
    );
    
    return !today.isAtSameMomentAs(lastDate);
  }

  // Alıntı gösterildi bilgisini kaydet
  void markQuoteAsShown(String quoteId) {
    _lastQuoteId = quoteId;
    _lastQuoteDate = DateTime.now();
    _saveData();
    notifyListeners();
  }

  // Kullanıcının tercih ettiği kategorileri getir
  Set<QuoteCategory> get preferredCategories => _preferredCategories;
  // Rastgele bir alıntı getir
  Quote getRandomQuote({QuoteCategory? category}) {
    if (_isLoading) {
      return defaultQuote;
    }

    final quote = MotivationQuotes.getRandomQuote(
      category: category,
      includePremium: _showPremiumQuotes,
    );
    
    if (quote.id != _lastQuoteId) {
      _lastQuoteId = quote.id;
      _lastQuoteDate = DateTime.now();
      _saveData(); // async çağrı arka planda yapılacak
    }
    
    return quote;
  }
  // Belirli bir kategorideki tüm alıntıları getir
  List<Quote> getQuotesByCategory(QuoteCategory category) {
    return MotivationQuotes.getQuotesByCategory(
      category,
      includePremium: _showPremiumQuotes,
    );
  }
}
