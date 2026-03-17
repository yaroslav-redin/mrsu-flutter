import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../services/network_service.dart';
import '../services/theme_provider.dart';

class SubjectDetailScreen extends StatefulWidget {
  final int subjectId;
  final String subjectTitle;

  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
    required this.subjectTitle,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  final NetworkService _networkService = NetworkService();
  SubjectDetail? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final response = await _networkService.makeAuthorizedRequest('StudentRatingPlan/${widget.subjectId}');
      if (response != null) {
        final Map<String, dynamic> jsonMap = response;
        setState(() {
          _detail = SubjectDetail.fromJson(jsonMap);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
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

    final displayTitle = (_detail?.title.isNotEmpty == true) ? _detail!.title : widget.subjectTitle;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                    : [
                        themeProvider.primaryColor.withOpacity(0.05),
                        Colors.white,
                        themeProvider.primaryColor.withOpacity(0.1),
                      ],
              ),
            ),
          ),

          // Fluid "liquid" elements
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    themeProvider.primaryColor.withOpacity(0.2),
                    themeProvider.primaryColor.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    themeProvider.primaryColor.withOpacity(0.15),
                    themeProvider.primaryColor.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          _isLoading && _detail == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: EdgeInsets.only(
                    top: 100 + topPadding,
                    left: 20,
                    right: 20,
                    bottom: 40,
                  ),
                  children: [
                    _buildGlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        displayTitle,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : themeProvider.primaryColor,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_detail != null) ...[
                      ..._detail!.sections.map((section) => _buildSection(section)),
                      const SizedBox(height: 8),
                      _buildGlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            if (_detail!.zeroSessionMark != null) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Нулевая сессия:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark ? Colors.white70 : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '${_detail!.zeroSessionMark}/5.0',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                height: 32,
                                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                              ),
                            ],
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Всего:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  '${_detail!.totalScore.toStringAsFixed(2)}/100.0',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: themeProvider.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () => Navigator.pop(context),
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      Expanded(
                        child: Text(
                          'Детали предмета',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                            letterSpacing: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
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

  Widget _buildSection(Section section) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            '${section.title}:',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ),
        ...section.controlDots.map((dot) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildGlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    ' - ${dot.title}:',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${dot.mark}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : themeProvider.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 12),
      ],
    );
  }
}
