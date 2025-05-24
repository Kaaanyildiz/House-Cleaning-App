
class MotivationQuotes {
  static List<String> quotes = [
    'Temiz bir ev, huzurlu bir zihin demektir!',
    'Her küçük görev, büyük bir başarıya giden adımdır.',
    'Bugün 5 dakikalık bir görev, yarın temiz bir ev anlamına gelir.',
    'Temizlik, kendi kendine hediye vermek gibidir.',
    'Düzenli bir ev, düzenli bir hayatın ilk adımıdır.',
    'Her gün küçük bir görev, büyük bir fark yaratır.',
    'Temiz bir ev için her gün bir küçük adım at!',
    'Temizlik yaptıkça kendinizi daha iyi hissedeceksiniz.',
    'Bugün yaptığınız her görev, yarın için teşekkür edeceğiniz bir şeydir.',
    'Her temizlik görevi, başarının bir parçasıdır.',
    'Ev temizliği, kendine gösterdiğin özendir.',
    'Küçük adımlarla büyük başarılar elde edebilirsiniz!',
    'Her bir görev sizi amacınıza bir adım daha yaklaştırır.',
    'Bir şeyi 21 gün boyunca yaparsanız, bu bir alışkanlık haline gelir.',
    'Bugün temiz bir ev için atacağın her adım, yarın sana huzur getirecek.',
  ];

  static String getRandomQuote() {
    quotes.shuffle();
    return quotes.first;
  }
}
