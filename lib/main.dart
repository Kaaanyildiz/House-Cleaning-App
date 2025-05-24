import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:house_cleaning/screens/home_page.dart';
import 'package:house_cleaning/services/user_provider.dart';
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
  
  // Bildirimleri başlat
  await NotificationService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Temizlik Asistanı',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Sistemin tema ayarını kullan
        home: const HomePage(),
      ),
    );
  }
}
