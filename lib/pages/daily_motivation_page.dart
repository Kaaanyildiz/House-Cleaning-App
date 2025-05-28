import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/motivation_quotes.dart';
import '../services/user_provider.dart';
import '../widgets/motivation_card.dart';

class DailyMotivationPage extends StatefulWidget {
  const DailyMotivationPage({Key? key}) : super(key: key);

  @override
  State<DailyMotivationPage> createState() => _DailyMotivationPageState();
}

class _DailyMotivationPageState extends State<DailyMotivationPage> {
  late Quote _currentQuote;
  
  @override
  void initState() {
    super.initState();
    _updateQuote();
  }
  void _updateQuote() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    setState(() {
      _currentQuote = MotivationQuotes.getRandomQuote(
        category: QuoteCategory.daily,
        includePremium: userProvider.showPremiumQuotes,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Motivasyon'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _updateQuote,
            tooltip: 'Yeni alıntı getir',
          ),
        ],
      ),      body: Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MotivationCard(
                quote: _currentQuote,
                onTap: _updateQuote,
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _updateQuote,
                icon: const Icon(Icons.refresh),
                label: const Text('Yeni Alıntı'),
              ),
              const SizedBox(height: 16),
              Text(
                'Her gün yeni bir motivasyon!',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
