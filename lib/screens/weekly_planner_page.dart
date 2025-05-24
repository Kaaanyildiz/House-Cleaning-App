import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_cleaning/constants/app_theme.dart';
import 'package:house_cleaning/services/user_provider.dart';
import 'package:house_cleaning/models/task_model.dart';

class WeeklyPlannerPage extends StatefulWidget {
  const WeeklyPlannerPage({Key? key}) : super(key: key);

  @override
  _WeeklyPlannerPageState createState() => _WeeklyPlannerPageState();
}

class _WeeklyPlannerPageState extends State<WeeklyPlannerPage> {
  // Haftanın günleri
  final List<String> _weekDays = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  // Şimdiki tarih ve seçili gün
  late DateTime _selectedDate;
  int _selectedDayIndex = 0;

  // Test verisi: Günlere göre görev sayısı
  final Map<int, int> _taskCountByDay = {
    0: 3, // Pazartesi
    1: 2, // Salı
    2: 4, // Çarşamba
    3: 1, // Perşembe
    4: 2, // Cuma
    5: 5, // Cumartesi
    6: 0, // Pazar
  };

  @override
  void initState() {
    super.initState();
    _selectedDate = _getStartOfWeek(DateTime.now());
    _selectedDayIndex = DateTime.now().weekday - 1; // 0=Pazartesi, 6=Pazar
  }

  // Haftanın başlangıç gününü döndürür (Pazartesi)
  DateTime _getStartOfWeek(DateTime date) {
    int difference = date.weekday - 1;
    return date.subtract(Duration(days: difference));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (!userProvider.isLoaded) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Haftalık Planlayıcı'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Hafta seçici
              _buildWeekSelector(),
              // Gün seçici
              _buildDaySelector(),
              // Görev listesi
              Expanded(
                child: _buildTaskList(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppTheme.primaryColor,
            onPressed: () {
              _showAddTaskDialog();
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildWeekSelector() {
    // Hafta başlangıcı ve bitişi
    DateTime weekEnd = _selectedDate.add(const Duration(days: 6));
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 7));
              });
            },
          ),
          Text(
            '${_selectedDate.day} ${_getMonthName(_selectedDate.month)} - ${weekEnd.day} ${_getMonthName(weekEnd.month)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 7));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          DateTime day = _selectedDate.add(Duration(days: index));
          bool isSelected = _selectedDayIndex == index;
          bool isToday = day.year == DateTime.now().year &&
              day.month == DateTime.now().month &&
              day.day == DateTime.now().day;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDayIndex = index;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : isToday
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : null,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday ? AppTheme.primaryColor : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekDays[index].substring(0, 3),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isSelected
                        ? Colors.white
                        : isToday
                            ? AppTheme.primaryColor.withOpacity(0.4)
                            : Colors.grey[200],
                    child: Text(
                      day.day.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : isToday
                                ? Colors.white
                                : Colors.grey[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (_taskCountByDay.containsKey(index) &&
                      _taskCountByDay[index]! > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_taskCountByDay[index]}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? AppTheme.primaryColor : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Ocak';
      case 2:
        return 'Şubat';
      case 3:
        return 'Mart';
      case 4:
        return 'Nisan';
      case 5:
        return 'Mayıs';
      case 6:
        return 'Haziran';
      case 7:
        return 'Temmuz';
      case 8:
        return 'Ağustos';
      case 9:
        return 'Eylül';
      case 10:
        return 'Ekim';
      case 11:
        return 'Kasım';
      case 12:
        return 'Aralık';
      default:
        return '';
    }
  }
  Widget _buildTaskList() {
    // Provider'dan görevleri al - Şimdilik _taskCountByDay ile devam ediyoruz
    // İlerleyen adımlarda provider entegrasyonu tamamlanacak
    
    // Seçili günde görev yoksa
    if (_taskCountByDay[_selectedDayIndex] == null ||
        _taskCountByDay[_selectedDayIndex] == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Bu gün için planlanmış göreviniz yok.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _showAddTaskDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('Görev Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    // Seçili gün için görevler (örnek veri)
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _taskCountByDay[_selectedDayIndex],
      itemBuilder: (context, index) {
        // Her gün için örnek görev verileri oluştur
        String title = 'Görev ${index + 1}';
        String time = '${9 + index}:00';
        IconData icon = Icons.cleaning_services;

        if (_selectedDayIndex == 0) {
          if (index == 0) {
            title = 'Toz Alma';
            time = '09:00';
            icon = Icons.cleaning_services;
          } else if (index == 1) {
            title = 'Çamaşır Yıkama';
            time = '10:30';
            icon = Icons.local_laundry_service;
          } else if (index == 2) {
            title = 'Yemek Hazırlama';
            time = '17:00';
            icon = Icons.restaurant;
          }
        } else if (_selectedDayIndex == 2) {
          if (index == 0) {
            title = 'Banyo Temizliği';
            time = '09:30';
            icon = Icons.bathroom;
          } else if (index == 1) {
            title = 'Ütü';
            time = '14:00';
            icon = Icons.iron;
          }
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: Icon(icon, color: Colors.white),
              ),
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Row(
                children: [
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(time),
                  const SizedBox(width: 16),
                  const Icon(Icons.star, size: 16),
                  const SizedBox(width: 4),
                  const Text('10 puan'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: () {
                      // Düzenleme işlevi
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      _showDeleteConfirmation(index);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Görev Ekle'),
        content: const Text('Bu özellik henüz geliştirme aşamasındadır.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(int taskIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Görevi Sil'),
        content: const Text('Bu görevi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              // Görevi silme işlevi
              setState(() {
                if (_taskCountByDay.containsKey(_selectedDayIndex)) {
                  _taskCountByDay[_selectedDayIndex] = 
                      _taskCountByDay[_selectedDayIndex]! - 1;
                }
              });
              Navigator.of(context).pop();
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
