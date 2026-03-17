import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/network_service.dart';
import '../services/theme_provider.dart';
import 'subject_detail_screen.dart';

class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key});

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen> {
  final NetworkService _networkService = NetworkService();
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;

  late int _selectedYear;
  late int _selectedSemester;
  late List<int> _availableYears;

  @override
  void initState() {
    super.initState();
    _initCurrentAcademicDates();
    _loadSubjects(useFilters: false);
  }

  void _initCurrentAcademicDates() {
    final now = DateTime.now();
    int currentAcademicYearStart;

    if (now.month >= 9) {
      currentAcademicYearStart = now.year;
      _selectedSemester = 1;
    } else {
      currentAcademicYearStart = now.year - 1;
      _selectedSemester = now.month == 1 ? 1 : 2;
    }

    _selectedYear = currentAcademicYearStart;

    _availableYears = [
      currentAcademicYearStart,
      currentAcademicYearStart - 1,
      currentAcademicYearStart - 2,
      currentAcademicYearStart - 3,
    ];
  }

  Future<void> _loadSubjects({bool useFilters = true}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final subjects = await _networkService.getSubjects(
        year: useFilters ? _selectedYear : null,
        semester: useFilters ? _selectedSemester : null,
      );
      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildGlassContainer({required Widget child, EdgeInsetsGeometry? padding}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withOpacity(isDark ? 0.3 : 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
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
          Column(
            children: [
              SizedBox(height: 80 + topPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildGlassContainer(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _selectedYear,
                            dropdownColor: isDark ? const Color(0xFF16213E) : Colors.white,
                            items: _availableYears.map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text('$year-${year + 1} год', style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedYear = val);
                                _loadSubjects(useFilters: true);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _selectedSemester,
                            dropdownColor: isDark ? const Color(0xFF16213E) : Colors.white,
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('1-ый семестр', style: TextStyle(fontSize: 14))),
                              DropdownMenuItem(value: 2, child: Text('2-ой семестр', style: TextStyle(fontSize: 14))),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedSemester = val);
                                _loadSubjects(useFilters: true);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => _loadSubjects(useFilters: true),
                        backgroundColor: themeProvider.primaryColor,
                        color: Colors.white,
                        child: _subjects.isEmpty
                            ? const Center(child: Text('Нет данных о предметах'))
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                                itemCount: _subjects.length,
                                itemBuilder: (context, index) {
                                  final subject = _subjects[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SubjectDetailScreen(
                                              subjectId: subject['id'],
                                              subjectTitle: subject['title'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: _buildGlassContainer(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                subject['title'],
                                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right_rounded,
                                              color: isDark ? Colors.white38 : Colors.black26,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
              ),
            ],
          ),

          // Glassy Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.only(top: topPadding, bottom: 15),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.black : Colors.white).withOpacity(0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Успеваемость',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
