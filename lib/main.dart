import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/subject_list_screen.dart';
import 'screens/splash_screen.dart';
import 'services/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'MRSU App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeProvider.primaryColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeProvider.themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const MainNavigationScreen(),
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    ScheduleScreen(),
    SubjectListScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Important for glass bottom bar
      body: Stack(
        children: [
          // Global background gradient for glass effect
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF1A1A2E),
                        const Color(0xFF16213E),
                        themeProvider.primaryColor.withOpacity(0.1),
                      ]
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
          IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: (isDark ? Colors.black : Colors.white).withOpacity(0.4),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.calendar_today_rounded),
                    label: 'Расписание',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.grade_rounded),
                    label: 'Успеваемость',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded),
                    label: 'Профиль',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: themeProvider.primaryColor,
                unselectedItemColor: isDark ? Colors.white60 : Colors.black45,
                onTap: _onItemTapped,
                backgroundColor: Colors.transparent,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: true,
                showUnselectedLabels: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
