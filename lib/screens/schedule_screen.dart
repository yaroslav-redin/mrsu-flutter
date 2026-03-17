import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../services/network_service.dart';
import '../services/theme_provider.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final NetworkService _networkService = NetworkService();
  List<Lesson> _lessons = [];
  List<Map<String, String>> _dateList = [];
  String _selectedDate = '';
  bool _isLoading = false;
  DateTime _currentWeekStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));

  final Map<int, String> _lessonTimes = {
    1: '08:00 - 09:30',
    2: '09:45 - 11:15',
    3: '11:35 - 13:05',
    4: '13:20 - 14:50',
    5: '15:00 - 16:30',
    6: '16:40 - 18:10',
    7: '18:15 - 19:45',
    8: '19:50 - 21:20',
  };

  @override
  void initState() {
    super.initState();
    _initSchedule();
  }

  void _initSchedule() {
    final now = DateTime.now();
    _currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    _generateDateList();
    
    _selectedDate = DateFormat('yyyy-MM-dd').format(now);
    _fetchSchedule(_selectedDate);
  }

  void _generateDateList() {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final dayFormat = DateFormat('E', 'ru_RU');

    _dateList = List.generate(7, (index) {
      final date = _currentWeekStart.add(Duration(days: index));
      return {
        'day': dayFormat.format(date),
        'date': dateFormat.format(date),
      };
    });
  }

  void _changeWeek(int weeks) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: weeks * 7));
      _generateDateList();
      // Optionally select the first day of the new week or keep selection if it fits
      _selectedDate = _dateList[0]['date']!;
      _fetchSchedule(_selectedDate);
    });
  }

  Future<void> _fetchSchedule(String date) async {
    setState(() {
      _isLoading = true;
      _selectedDate = date;
    });

    try {
      final response = await _networkService.makeAuthorizedRequest('StudentTimeTable?date=$date');
      if (response != null) {
        final List<dynamic> jsonList = response;
        List<Lesson> fetchedLessons = [];

        for (var scheduleObject in jsonList) {
          final timeTable = scheduleObject['TimeTable'];
          if (timeTable != null && timeTable['Lessons'] != null) {
            for (var lessonJson in timeTable['Lessons']) {
              fetchedLessons.add(Lesson.fromJson(lessonJson));
            }
          }
        }
        setState(() {
          _lessons = fetchedLessons;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка получения расписания: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Content that scrolls under the glassy header
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  backgroundColor: themeProvider.primaryColor,
                  color: Colors.white,
                  edgeOffset: 180 + topPadding,
                  onRefresh: () => _fetchSchedule(_selectedDate),
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: 190 + topPadding, // Header height
                      bottom: 120, // Space for bottom bar
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      final lessonNumber = index + 1;
                      final lesson = _lessons.firstWhere(
                        (l) => l.number == lessonNumber,
                        orElse: () => Lesson(number: lessonNumber, disciplines: []),
                      );
                      return _buildLessonItemGlass(lesson, lessonNumber);
                    },
                  ),
                ),

          // Glassy Header (Title + Dates)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.only(top: topPadding),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withOpacity(0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        'Расписание',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 100,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => _changeWeek(-1),
                              icon: Icon(Icons.chevron_left_rounded, color: isDark ? Colors.white70 : Colors.black54),
                            ),
                            Expanded(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _dateList.length,
                                itemBuilder: (context, index) {
                                  final dateItem = _dateList[index];
                                  final isSelected = _selectedDate == dateItem['date'];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6),
                                    child: GestureDetector(
                                      onTap: () => _fetchSchedule(dateItem['date']!),
                                      child: _buildDateItemGlass(
                                        isSelected: isSelected,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              dateItem['day']!.toUpperCase(),
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              dateItem['date']!.substring(8),
                                              style: TextStyle(
                                                color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () => _changeWeek(1),
                              icon: Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white70 : Colors.black54),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItemGlass({required Widget child, bool isSelected = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 65,
          decoration: BoxDecoration(
            color: isSelected 
                ? theme.primaryColor.withOpacity(0.8) 
                : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? Colors.white.withOpacity(0.4) 
                  : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildLessonItemGlass(Lesson lesson, int number) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isNoLessons = lesson.disciplines.isEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white).withOpacity(isDark ? 0.3 : 0.4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.15),
                width: 1.5,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: isNoLessons ? (isDark ? Colors.white24 : Colors.black12) : theme.primaryColor,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isNoLessons 
                                  ? (isDark ? Colors.white10 : Colors.black12) 
                                  : theme.primaryColor.withOpacity(isDark ? 0.4 : 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$number',
                                style: TextStyle(
                                  color: isNoLessons 
                                      ? (isDark ? Colors.white38 : Colors.black26) 
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _lessonTimes[number] ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                isNoLessons
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'Нет занятий',
                                          style: TextStyle(color: isDark ? Colors.white30 : Colors.black26),
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: lesson.disciplines.map((d) => Padding(
                                          padding: const EdgeInsets.only(bottom: 12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                d.title,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: isDark ? Colors.white : theme.primaryColor,
                                                  height: 1.2,
                                                  shadows: isDark ? [
                                                    const Shadow(
                                                      color: Colors.black54,
                                                      offset: Offset(0, 1),
                                                      blurRadius: 2,
                                                    )
                                                  ] : [],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.location_on_rounded, size: 14, color: isDark ? Colors.white70 : Colors.black54),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    d.auditorium,
                                                    style: TextStyle(
                                                      color: isDark ? Colors.white : Colors.black87, 
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 2),
                                                    child: Icon(Icons.person_rounded, size: 14, color: isDark ? Colors.white54 : Colors.black38),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      d.teacher,
                                                      style: TextStyle(
                                                        color: isDark ? Colors.white70 : Colors.black54,
                                                        fontSize: 13,
                                                      ),
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        )).toList(),
                                      ),
                              ],
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
      ),
    );
  }
}
