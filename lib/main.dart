import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:house_cleaning/screens/home_page.dart';
import 'package:house_cleaning/services/user_provider.dart';
import 'package:house_cleaning/services/motivation_provider.dart';
import 'package:house_cleaning/services/notification_service.dart';
import 'package:house_cleaning/models/user_model.dart';
import 'package:house_cleaning/models/task_model.dart';
import 'package:house_cleaning/models/badge_model.dart' as app_badge;
import 'package:house_cleaning/models/task_adapter_fix.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Sistem UI rengini ayarla
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  
  // Ekran yönlendirmesini portre moduna sabitle
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Hive veritabanını başlat
  await Hive.initFlutter();
  
  // Hive adaptörlerini kaydet
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(TaskCategoryAdapter());
  Hive.registerAdapter(TaskDifficultyAdapter());
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(app_badge.BadgeAdapter());
  Hive.registerAdapter(IconDataAdapter());
  Hive.registerAdapter(DateTimeAdapter());
  
  // Hive kutularını aç
  await Hive.openBox<User>('users');
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<app_badge.Badge>('badges');
  await Hive.openBox('motivation_settings');
  
  // Bildirimleri başlat
  await NotificationService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Tema değişikliklerini dinlemek için
  late ThemeData _currentTheme;
  
  @override
  void initState() {
    super.initState();
    // İlk tema değerini al
    _currentTheme = AppTheme.instance.currentTheme;
    // Tema değişikliklerini dinle
    AppTheme.instance.addListener(_onThemeChanged);
  }
  
  @override
  void dispose() {
    // Listener'ı temizle
    AppTheme.instance.removeListener(_onThemeChanged);
    super.dispose();
  }
  
  // Tema değiştiğinde UI'ı güncelle
  void _onThemeChanged() {
    setState(() {
      _currentTheme = AppTheme.instance.currentTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, MotivationProvider>(
          create: (_) => MotivationProvider(),
          update: (_, userProvider, motivationProvider) {
            if (motivationProvider != null) {
              motivationProvider.updatePremiumStatus(userProvider.showPremiumQuotes);
            }
            return motivationProvider ?? MotivationProvider();
          },
        ),
        // AppTheme için değeri sağla
        ChangeNotifierProvider.value(value: AppTheme.instance),
      ],
      child: MaterialApp(
        title: 'Ev Temizlik Asistanı',
        theme: _currentTheme, // Dinamik tema
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
